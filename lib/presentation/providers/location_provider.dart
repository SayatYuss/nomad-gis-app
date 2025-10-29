import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import '../../core/location/location_service.dart'; // Наш сервис

// 1. Провайдер для самого LocationService
final locationServiceProvider = Provider<LocationService>((ref) {
  return LocationService();
});

// 2. StreamProvider, который будет выдавать обновления позиции
// StreamProvider.autoDispose автоматически отписывается, когда виджет не используется
final locationStreamProvider = StreamProvider.autoDispose<Position>((ref) async* {
  final locationService = ref.watch(locationServiceProvider);

  // Сначала проверяем разрешения
  final hasPermission = await locationService.handleLocationPermission();
  if (!hasPermission) {
    // Если нет разрешений, стрим завершается с ошибкой
    throw Exception('Location permission denied.');
    // Можно вернуть пустой стрим: yield* Stream.empty();
  }

  // Если разрешения есть, начинаем слушать стрим из сервиса
  await for (final position in locationService.getPositionStream()) {
    yield position; // Отправляем новую позицию подписчикам
  }
});