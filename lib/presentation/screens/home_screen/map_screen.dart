import 'dart:async'; // Для Completer
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart'; // Нужен для Position
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart'; // ИМПОРТ YANDEX MAPKIT
import '../../providers/location_provider.dart';

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  // Контроллер для управления картой Yandex
  final Completer<YandexMapController> _mapControllerCompleter = Completer();
  // Список объектов на карте (маркер пользователя)
  final List<MapObject> _mapObjects = [];

  // Сохраняем последнюю позицию, чтобы не двигать карту без необходимости
  Position? _lastPosition;

  // Флаг, чтобы переместить камеру к начальной/текущей позиции только один раз
  bool _isInitialCameraPositionSet = false;

  @override
  void initState() {
    super.initState();
    _initMap(); // Инициализация разрешений при старте
  }

  // Запрашиваем разрешения заранее
  Future<void> _initMap() async {
    await ref.read(locationServiceProvider).handleLocationPermission();
  }

  // Функция для обновления маркера пользователя на карте
  Future<void> _updateUserMarker(Position position) async {
    // Не обновляем, если позиция та же
    if (_lastPosition != null &&
        _lastPosition!.latitude == position.latitude &&
        _lastPosition!.longitude == position.longitude) {
      return;
    }
    _lastPosition = position;

    // Создаем PlacemarkMapObject
    final userPlacemark = PlacemarkMapObject(
      mapId: const MapObjectId('user_placemark'), // Уникальный ID
      point: Point(latitude: position.latitude, longitude: position.longitude),
      icon: PlacemarkIcon.single(
        PlacemarkIconStyle(
          image: BitmapDescriptor.fromAssetImage(
              'assets/user_placemark.png'), // УБЕДИТЕСЬ, ЧТО ИКОНКА ЕСТЬ В assets/
          scale: 0.5, // Настройте размер иконки
        ),
      ),
      opacity: 1.0,
    );

    // Если контроллер карты уже готов и начальная позиция еще не установлена,
    // перемещаем камеру к текущей позиции пользователя
    if (!_isInitialCameraPositionSet && _mapControllerCompleter.isCompleted) {
      _moveToCurrentLocation(position, moveAnyway: true); // Перемещаем камеру при первом получении позиции
    }


    setState(() {
      // Удаляем старый маркер (если есть) и добавляем новый
      _mapObjects.removeWhere((obj) => obj.mapId == userPlacemark.mapId);
      _mapObjects.add(userPlacemark);
    });
  }

  // Функция для перемещения камеры карты
  // Добавлен флаг moveAnyway для принудительного перемещения при инициализации
  Future<void> _moveToCurrentLocation(Position position, {bool moveAnyway = false}) async {
    if (!_mapControllerCompleter.isCompleted) return; // Выход, если контроллер не готов

    // Если это установка начальной позиции или принудительное перемещение
    if (!_isInitialCameraPositionSet || moveAnyway) {
        final controller = await _mapControllerCompleter.future;
        controller.moveCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: Point(latitude: position.latitude, longitude: position.longitude),
              zoom: 15.0, // Уровень зума
            ),
          ),
          animation: const MapAnimation(type: MapAnimationType.smooth, duration: 1.0),
        );
        // Устанавливаем флаг, что начальная позиция задана
        // (даже если это было нажатие кнопки)
        _isInitialCameraPositionSet = true;
    }
  }


  @override
  Widget build(BuildContext context) {
    // Слушаем StreamProvider локации
    final locationAsyncValue = ref.watch(locationStreamProvider);

    // Когда получаем новую позицию, обновляем маркер
    locationAsyncValue.whenData((position) {
      // Обновляем маркер всегда
      _updateUserMarker(position);
    });

    return Scaffold(
      extendBodyBehindAppBar: true,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // При нажатии кнопки всегда перемещаем камеру на последнюю известную позицию
          if (_lastPosition != null) {
            _moveToCurrentLocation(_lastPosition!, moveAnyway: true);
          } else {
             // Если позиция еще неизвестна, можно переместить к дефолтной точке (Астана)
             _mapControllerCompleter.future.then((controller) {
                 controller.moveCamera(
                    CameraUpdate.newCameraPosition(
                      const CameraPosition(
                         target: Point(latitude: 51.1694, longitude: 71.4491), // Астана
                         zoom: 13.0,
                      )
                    ),
                    animation: const MapAnimation(type: MapAnimationType.smooth, duration: 1.0),
                 );
             });
          }
        },
        child: const Icon(Icons.my_location),
      ),
      body: YandexMap(
        // Передаем контроллер карте при её создании
        onMapCreated: (YandexMapController controller) {
           if (!_mapControllerCompleter.isCompleted) {
              _mapControllerCompleter.complete(controller);
           }
          // Устанавливаем начальную позицию (Астана), если геолокация еще не определилась
          if (!_isInitialCameraPositionSet) {
             controller.moveCamera(
                CameraUpdate.newCameraPosition(
                    const CameraPosition(
                       target: Point(latitude: 51.1694, longitude: 71.4491), // Астана
                       zoom: 13.0,
                    )
                ),
                // Можно без анимации для мгновенной установки
                // animation: const MapAnimation(type: MapAnimationType.smooth, duration: 1.0),
             );
             // НЕ ставим _isInitialCameraPositionSet = true здесь,
             // ждем первую геолокацию пользователя
          }
        },
        // УБРАЛИ initialCameraPosition
        // Отображаем объекты на карте (наш маркер)
        mapObjects: _mapObjects,
      ),
    );
  }
}