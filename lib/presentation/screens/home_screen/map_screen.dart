import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart'; // Нужен для Position
import 'package:latlong2/latlong.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/location_provider.dart'; // 1. Импорт провайдера локации

// 2. Меняем на ConsumerStatefulWidget, чтобы получить MapController
class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  // 3. Контроллер для управления картой (центрирование и т.д.)
  final MapController _mapController = MapController();

  @override
  Widget build(BuildContext context) {
    // 4. "Слушаем" StreamProvider локации
    final locationAsyncValue = ref.watch(locationStreamProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      
      // 5. Кнопка центрирования поверх карты
      floatingActionButton: FloatingActionButton(
        onPressed: () {
           // При нажатии перемещаем карту на последнюю известную позицию
           locationAsyncValue.whenData((position) {
             _mapController.move(
               LatLng(position.latitude, position.longitude),
               15.0, // Уровень зума
             );
           });
        },
        child: const Icon(Icons.my_location),
      ),
      
      body: FlutterMap(
        // 6. Передаем контроллер карте
        mapController: _mapController, 
        options: MapOptions(
          initialCenter: LatLng(51.1694, 71.4491), // Астана
          initialZoom: 13.0,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          ),

          // 7. Слой для маркера пользователя
          // Используем locationAsyncValue.when для обработки состояний
          locationAsyncValue.when(
            // --- Состояние Загрузки/Ожидания ---
            loading: () => const MarkerLayer(markers: []), // Пустой слой
            
            // --- Состояние Ошибки (например, нет разрешений) ---
            error: (err, stack) {
              // TODO: Показать пользователю сообщение об ошибке
              print('Location Error: $err');
              return const MarkerLayer(markers: []); // Пустой слой
            },
            
            // --- Состояние Успеха (позиция получена) ---
            data: (Position position) {
              // Создаем маркер в текущей позиции
              return MarkerLayer(
                markers: [
                  Marker(
                    width: 80.0,
                    height: 80.0,
                    point: LatLng(position.latitude, position.longitude),
                    child: const Icon( // Используем Icon вместо картинки для простоты
                      Icons.person_pin_circle, 
                      color: Colors.blueAccent, 
                      size: 40.0,
                    ),
                  ),
                ],
              );
            },
          ),
          
          // TODO: Сюда мы позже добавим маркеры точек из API
          // и полигон "тумана"
        ],
      ),
    );
  }
}
