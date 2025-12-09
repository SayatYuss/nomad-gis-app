import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nomad_gis_lib/nomad_gis_lib.dart';
import '../config/providers.dart';

// Map Points Provider - кэшируется автоматически Riverpod
final mapPointsProvider = FutureProvider<List<MapPointRequest>>((ref) async {
  final apiService = ref.watch(apiServiceProvider);
  return apiService.client.mapPoints.getMapPoints();
});

// Single Map Point Provider - с autoDispose для экономии памяти
final mapPointProvider = FutureProvider.autoDispose
    .family<MapPointRequest, String>((ref, pointId) async {
      // Кэшируем на 5 минут
      ref.keepAlive();
      final link = ref.keepAlive();
      Future.delayed(const Duration(minutes: 5), () => link.close());

      final apiService = ref.watch(apiServiceProvider);
      return apiService.client.mapPoints.getMapPointById(pointId);
    });

// Check Location Provider - не кэшируем, каждый запрос уникален
final checkLocationProvider = FutureProvider.autoDispose
    .family<Map<String, dynamic>, (double, double)>((ref, coords) async {
      final apiService = ref.watch(apiServiceProvider);
      final (lat, lon) = coords;
      return apiService.client.game.checkLocation(
        latitude: lat,
        longitude: lon,
      );
    });
