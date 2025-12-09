import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:nomad_gis_lib/nomad_gis_lib.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';
import '../../providers/auth_provider.dart';
import '../../providers/map_provider.dart';
import '../../providers/profile_provider.dart';
import '../../services/location_service.dart';
import '../../services/notification_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/constants.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/common/custom_app_bar.dart';
import 'point_unlocked_screen.dart';

class MapScreen extends ConsumerStatefulWidget {
  final VoidCallback onProfileTap;
  final VoidCallback onLeaderboardTap;
  final Function(String pointId) onPointTap;

  const MapScreen({
    super.key,
    required this.onProfileTap,
    required this.onLeaderboardTap,
    required this.onPointTap,
  });

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  MapController? _mapController;
  List<Marker> _markers = [];
  List<CircleMarker> _circles = [];
  LatLng? _userLocation;
  Set<String> _unlockedPointIds = {};
  StreamSubscription<Position>? _positionStreamSubscription;
  List<MapPointRequest>? _cachedMapPoints;

  // Default location (Астана, Казахстан)
  static const _defaultLocation = LatLng(51.1694, 71.4491);

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _initializeLocation();
    _loadUnlockedPoints();
    // Загружаем точки карты при инициализации
    _loadMapPoints();
  }

  Future<void> _loadMapPoints() async {
    try {
      final points = await ref.read(mapPointsProvider.future);
      _cachedMapPoints = points;
      _updateMarkersAndCircles(points);
    } catch (e) {
      debugPrint('[MapScreen] Ошибка загрузки точек: $e');
    }
  }

  Future<void> _loadUnlockedPoints() async {
    try {
      final userPoints = await ref.read(userPointsProvider.future);
      if (mounted) {
        setState(() {
          _unlockedPointIds = userPoints.map((p) => p.id).toSet();
        });
      }
    } catch (e) {
      // Ignore error - will show all as locked
    }
  }

  Future<void> _initializeLocation() async {
    try {
      final hasPermission = await LocationService.requestLocationPermission();
      if (!hasPermission) {
        // Используем дефолтную локацию если нет разрешения
        if (mounted) {
          setState(() {
            _userLocation = _defaultLocation;
          });
        }
        return;
      }

      final position = await LocationService.getCurrentPosition();
      if (mounted) {
        setState(() {
          _userLocation = position != null
              ? LatLng(position.latitude, position.longitude)
              : _defaultLocation;
        });

        // Запускаем реальный мониторинг с потоком если есть позиция
        if (position != null) {
          _startLocationMonitoring();
        }
      }
    } catch (e) {
      // В случае ошибки используем дефолтную локацию
      if (mounted) {
        setState(() {
          _userLocation = _defaultLocation;
        });
      }
    }
  }

  void _startLocationMonitoring() async {
    try {
      debugPrint('[LocationMonitoring] Инициализация GPS потока');
      final positionStream = await LocationService.getPositionStream(
        accuracy: LocationAccuracy.best,
        distanceFilter:
            2, // обновляем при изменении на 2 метра для более частых проверок
      );

      if (positionStream == null) {
        debugPrint(
          '[LocationMonitoring] GPS поток недоступен, переходим на полинг',
        );
        // Fallback на периодический полинг если поток недоступен
        _startLocationPolling();
        return;
      }

      debugPrint('[LocationMonitoring] GPS поток успешно инициализирован');
      _positionStreamSubscription = positionStream.listen(
        (Position position) {
          debugPrint(
            '[LocationStream] Получено обновление: lat=${position.latitude}, lon=${position.longitude}',
          );
          if (mounted) {
            setState(() {
              _userLocation = LatLng(position.latitude, position.longitude);
            });

            // Проверяем локацию СРАЗУ при каждом изменении координат
            // так пользователь не пропустит открытие точки
            _checkLocation(position.latitude, position.longitude);
          }
        },
        onError: (e) {
          debugPrint('[LocationStream] Error: $e');
          // Fallback на полинг при ошибке потока
          _startLocationPolling();
        },
      );
    } catch (e) {
      debugPrint('[LocationMonitoring] Exception: $e');
      // Fallback на полинг при ошибке
      _startLocationPolling();
    }
  }

  void _startLocationPolling() {
    // Полинг каждые N секунд как резервный вариант
    debugPrint(
      '[LocationPolling] Запуск периодического полинга каждые ${AppConstants.locationCheckIntervalSeconds} секунд',
    );
    Future.doWhile(() async {
      await Future.delayed(
        Duration(seconds: AppConstants.locationCheckIntervalSeconds),
      );

      if (mounted) {
        try {
          final position = await LocationService.getCurrentPosition();
          if (position != null) {
            setState(() {
              _userLocation = LatLng(position.latitude, position.longitude);
            });
            await _checkLocation(position.latitude, position.longitude);
          }
        } catch (e) {
          debugPrint('[LocationPolling] Ошибка: $e');
        }
      }

      return mounted;
    });
  }

  Future<void> _checkLocation(double lat, double lon) async {
    try {
      debugPrint('[CheckLocation] Отправляю геолокацию: lat=$lat, lon=$lon');
      final result = await ref.read(checkLocationProvider((lat, lon)).future);
      debugPrint('[CheckLocation] Ответ от сервера: $result');

      // Проверяем если точка открыта
      if (result['unlockedPointId'] != null) {
        final pointId = result['unlockedPointId'] as String;
        final message = result['message'] as String?;
        final experienceGained = (result['experienceGained'] as int?) ?? 0;
        final leveledUp = (result['leveledUp'] as bool?) ?? false;
        final userData = result['userData'] as Map<String, dynamic>?;

        // Извлекаем название точки из сообщения
        // Сообщение формата: "Вы открыли точку: point2!"
        String pointName = 'Неизвестная точка';
        if (message != null && message.contains('точку:')) {
          final parts = message.split('точку: ');
          if (parts.length > 1) {
            pointName = parts[1].replaceAll('!', '').trim();
          }
        }

        // Обновляем уровень если произошел levelUp
        if (leveledUp && userData != null) {
          ref.invalidate(authProvider);
          ref.invalidate(profileProvider);
        }

        // Обновляем разблокированные точки
        _unlockedPointIds.add(pointId);
        ref.invalidate(userPointsProvider);
        ref.invalidate(mapPointsProvider);

        // Показываем красивый экран открытия точки
        if (mounted) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => PointUnlockedScreen(
              pointName: pointName,
              experienceGained: experienceGained,
              leveledUp: leveledUp,
              newLevel: leveledUp && userData != null
                  ? 'Уровень ${userData['level']}'
                  : null,
              onClose: () {
                // Обновляем маркеры при закрытии диалога
                ref.read(mapPointsProvider.future).then((points) {
                  _updateMarkersAndCircles(points);
                });
              },
            ),
          );
        }
      } else {
        // Обычная проверка без разблокировки точек
        // Обрабатываем достижения если они были
        if (result['unlockedAchievements'] != null) {
          final achievements = result['unlockedAchievements'] as List?;
          if (achievements != null && achievements.isNotEmpty) {
            for (var achievement in achievements) {
              final achievementName = achievement['title'] ?? 'Достижение';
              final reward = achievement['rewardPoints'] ?? 0;
              _showAchievementDialog(achievementName, reward);
            }
          }
        }

        // Обрабатываем полученный опыт
        if (result['experienceGained'] != null) {
          final exp = result['experienceGained'] as int;
          if (exp > 0) {
            NotificationService.showInfoSnackBar('✨ Получено $exp опыта!');
          }
        }
      }
    } catch (e) {
      debugPrint('[CheckLocation] Ошибка при отправке геолокации: $e');
      NotificationService.showErrorSnackBar('Ошибка синхронизации локации');
    }
  }

  void _showAchievementDialog(String name, int reward) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Row(
          children: [
            Icon(Icons.emoji_events, color: Colors.amber, size: 32),
            SizedBox(width: 12),
            Expanded(child: Text('Достижение!')),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              name,
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Награда: $reward опыта',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.primary),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Отлично!'),
          ),
        ],
      ),
    );
  }

  void _centerMapOnUserLocation() {
    if (_userLocation == null) {
      NotificationService.showErrorSnackBar('GPS недоступен');
      return;
    }

    _mapController?.move(
      _userLocation!,
      17, // Приближаем на уровень 17 для лучшей видимости
    );
  }

  void _resetMapRotation() {
    // Ориентируем карту по компасу (северной стороне)
    _mapController?.rotate(0); // 0 градусов = северная сторона вверху
    NotificationService.showInfoSnackBar('Карта ориентирована по компасу');
  }

  void _updateMarkersAndCircles(List<MapPointRequest> mapPoints) {
    List<Marker> markers = [];
    List<CircleMarker> circles = [];

    for (var point in mapPoints) {
      final position = LatLng(point.latitude, point.longitude);
      final isUnlocked = _unlockedPointIds.contains(point.id);

      // Add marker with different color for unlocked/locked
      markers.add(
        Marker(
          point: position,
          child: GestureDetector(
            onTap: () => widget.onPointTap(point.id),
            child: Container(
              decoration: BoxDecoration(
                color: isUnlocked ? AppColors.secondary : AppColors.primary,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color:
                        (isUnlocked ? AppColors.secondary : AppColors.primary)
                            .withValues(alpha: 0.3),
                    blurRadius: 8,
                  ),
                ],
              ),
              padding: const EdgeInsets.all(8),
              child: Icon(
                isUnlocked ? Icons.check : Icons.location_on,
                color: AppColors.surface,
                size: 20,
              ),
            ),
          ),
        ),
      );

      // Add unlock radius circle
      circles.add(
        CircleMarker(
          point: position,
          radius: point.unlockRadiusMeters.toDouble(),
          useRadiusInMeter: true,
          color: (isUnlocked ? AppColors.secondary : AppColors.primary)
              .withValues(alpha: 0.1),
          borderStrokeWidth: 2,
          borderColor: (isUnlocked ? AppColors.secondary : AppColors.primary)
              .withValues(alpha: 0.3),
        ),
      );
    }

    // Add user location marker
    if (_userLocation != null) {
      markers.add(
        Marker(
          point: _userLocation!,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.blue,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withValues(alpha: 0.4),
                  blurRadius: 10,
                ),
              ],
            ),
            padding: const EdgeInsets.all(6),
            child: const Icon(Icons.person, color: Colors.white, size: 16),
          ),
        ),
      );
    }

    if (mounted) {
      setState(() {
        _markers = markers;
        _circles = circles;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final mapPointsAsync = ref.watch(mapPointsProvider);

    return Scaffold(
      appBar: authState.user != null
          ? ProfileAppBar(
              username: authState.user!.username ?? 'Гость',
              avatarUrl: authState.user!.avatarUrl,
              level: authState.user!.level,
              experience: authState.user!.experience,
              onProfileTap: widget.onProfileTap,
              actions: [
                IconButton(
                  icon: Icon(Icons.leaderboard),
                  onPressed: widget.onLeaderboardTap,
                ),
                IconButton(
                  icon: Icon(Icons.logout),
                  onPressed: () async {
                    await ref.read(authProvider.notifier).logout();
                  },
                ),
              ],
            )
          : null,
      body: Stack(
        children: [
          // OpenStreetMap
          if (_userLocation != null)
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _userLocation!,
                initialZoom: AppConstants.defaultMapZoom,
                minZoom: 5,
                maxZoom: 18,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.nomad_gis_app',
                  retinaMode: true,
                ),
                CircleLayer(circles: _circles),
                MarkerLayer(markers: _markers),
              ],
            )
          else
            const Center(child: LoadingIndicator(message: 'Загрузка карты...')),
          // Points layer update - используем listen вместо when в build
          mapPointsAsync.when(
            loading: () => const SizedBox.shrink(),
            error: (err, st) => Positioned(
              bottom: 80,
              left: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.error_outline, color: Colors.white, size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Ошибка загрузки точек',
                        style: TextStyle(color: Colors.white, fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            data: (points) {
              // Обновляем только если данные изменились
              if (_cachedMapPoints != points) {
                _cachedMapPoints = points;
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _updateMarkersAndCircles(points);
                });
              }
              return const SizedBox.shrink();
            },
          ),
          // Map zoom controls
          Positioned(
            bottom: 140,
            right: 16,
            child: Column(
              children: [
                // Zoom in button
                FloatingActionButton(
                  mini: true,
                  heroTag: 'zoom_in',
                  onPressed: () {
                    _mapController?.move(
                      _mapController!.camera.center,
                      _mapController!.camera.zoom + 1,
                    );
                  },
                  backgroundColor: AppColors.primary,
                  child: const Icon(Icons.add, color: Colors.white),
                ),
                const SizedBox(height: 8),
                // Zoom out button
                FloatingActionButton(
                  mini: true,
                  heroTag: 'zoom_out',
                  onPressed: () {
                    _mapController?.move(
                      _mapController!.camera.center,
                      _mapController!.camera.zoom - 1,
                    );
                  },
                  backgroundColor: AppColors.primary,
                  child: const Icon(Icons.remove, color: Colors.white),
                ),
                const SizedBox(height: 8),
                // Compass button - reset map rotation to north
                FloatingActionButton(
                  mini: true,
                  heroTag: 'compass',
                  onPressed: _resetMapRotation,
                  backgroundColor: AppColors.secondary,
                  child: const Icon(
                    Icons.compass_calibration,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          // Center on user location button
          Positioned(
            bottom: 16,
            right: 16,
            child: FloatingActionButton(
              heroTag: 'my_location',
              onPressed: _centerMapOnUserLocation,
              backgroundColor: AppColors.primary,
              child: const Icon(Icons.my_location, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _mapController?.dispose();
    _positionStreamSubscription?.cancel();
    super.dispose();
  }
}
