import 'package:geolocator/geolocator.dart';

class LocationService {
  /// Проверяет и запрашивает разрешения на геолокацию.
  /// Возвращает true, если разрешение получено.
  Future<bool> handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    // 1. Проверяем, включены ли службы геолокации вообще
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Службы выключены, просим пользователя включить
      // TODO: Показать диалог, ведущий в настройки
      print('Location services are disabled. Please enable the services');
      return false;
    }

    // 2. Проверяем текущий статус разрешения
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      // Разрешение не запрашивалось или было отклонено, запрашиваем
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Пользователь отклонил запрос
        print('Location permissions are denied');
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Разрешение отклонено навсегда
      // TODO: Показать диалог, объясняющий, как включить в настройках
      print('Location permissions are permanently denied, we cannot request permissions.');
      return false;
    }

    // Если дошли сюда, разрешения есть
    return true;
  }

  /// Получает ОДИН раз текущую позицию
  Future<Position?> getCurrentPosition() async {
    final hasPermission = await handleLocationPermission();
    if (!hasPermission) return null; // Нет разрешения - нет позиции

    try {
      // accuracy: LocationAccuracy.high - для большей точности, но > расход батареи
      return await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.medium);
    } catch (e) {
      print('Error getting current position: $e');
      return null;
    }
  }

  /// Возвращает ПОТОК (Stream) с обновлениями позиции
  /// Срабатывает при смещении на `distanceFilter` метров.
  Stream<Position> getPositionStream({int distanceFilter = 50}) {
    // Настройки для фоновой работы (может потребоваться доп. настройка для iOS/Android)
    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high, // Высокая точность для игры
      distanceFilter: 50, // Срабатывать каждые N метров
    );
    return Geolocator.getPositionStream(locationSettings: locationSettings);
  }
}