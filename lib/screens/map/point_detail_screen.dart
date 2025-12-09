import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'dart:async';
import '../../providers/achievements_provider.dart';
import '../../providers/map_provider.dart';
import '../../providers/profile_provider.dart';
import '../../services/location_service.dart';
import '../../services/notification_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/common/custom_app_bar.dart';

class PointDetailScreen extends ConsumerStatefulWidget {
  final String pointId;

  const PointDetailScreen({super.key, required this.pointId});

  @override
  ConsumerState<PointDetailScreen> createState() => _PointDetailScreenState();
}

class _PointDetailScreenState extends ConsumerState<PointDetailScreen> {
  MapController? _mapController;
  late TextEditingController _messageController;
  bool _isCreatingMessage = false;
  LatLng? _userLocation;
  bool _isCheckingLocation = false;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _messageController = TextEditingController();
    _loadUserLocation();
  }

  Future<void> _loadUserLocation() async {
    try {
      final position = await LocationService.getCurrentPosition();
      if (mounted && position != null) {
        setState(() {
          _userLocation = LatLng(position.latitude, position.longitude);
        });
      }
    } catch (e) {
      // Ignore
    }
  }

  double? _calculateDistance(double pointLat, double pointLon) {
    if (_userLocation == null) return null;
    return LocationService.calculateDistance(
      _userLocation!.latitude,
      _userLocation!.longitude,
      pointLat,
      pointLon,
    );
  }

  String _formatDistance(double meters) {
    if (meters >= 1000) {
      return '${(meters / 1000).toStringAsFixed(2)} км';
    }
    return '${meters.toStringAsFixed(0)} м';
  }

  Future<void> _checkLocation(
    double pointLat,
    double pointLon,
    double radius,
  ) async {
    if (_userLocation == null) {
      NotificationService.showErrorSnackBar('GPS недоступен');
      return;
    }

    setState(() => _isCheckingLocation = true);

    try {
      await ref.read(
        checkLocationProvider((
          _userLocation!.latitude,
          _userLocation!.longitude,
        )).future,
      );

      final distance = _calculateDistance(pointLat, pointLon);
      if (distance != null && distance <= radius) {
        NotificationService.showSuccessSnackBar('🎉 Точка разблокирована!');
        ref.invalidate(userPointsProvider);
      } else if (distance != null) {
        NotificationService.showInfoSnackBar(
          'Подойдите ближе! Осталось ${_formatDistance(distance - radius)}',
        );
      }
    } catch (e) {
      NotificationService.showErrorSnackBar('Ошибка проверки локации');
    } finally {
      if (mounted) {
        setState(() => _isCheckingLocation = false);
      }
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  void _handleSendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    setState(() => _isCreatingMessage = true);

    try {
      final notifier = ref.read(
        messagesNotifierProvider(widget.pointId).notifier,
      );
      await notifier.createMessage(_messageController.text.trim());
      _messageController.clear();

      // Refresh messages
      unawaited(ref.refresh(messagesProvider(widget.pointId).future));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ошибка отправки сообщения')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isCreatingMessage = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final messagesAsync = ref.watch(messagesProvider(widget.pointId));
    final pointAsync = ref.watch(mapPointProvider(widget.pointId));

    return Scaffold(
      appBar: const CustomAppBar(title: 'Точка интереса'),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Map with point
            pointAsync.when(
              loading: () => Container(
                height: 300,
                color: AppColors.surfaceLight,
                child: LoadingIndicator(),
              ),
              error: (err, st) => Container(
                height: 300,
                color: AppColors.surfaceLight,
                child: Center(child: Text('Ошибка загрузки карты')),
              ),
              data: (point) {
                final pointLocation = LatLng(point.latitude, point.longitude);
                return Container(
                  height: 300,
                  color: AppColors.surfaceLight,
                  child: FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      initialCenter: pointLocation,
                      initialZoom: 15,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.example.nomad_gis_app',
                      ),
                      CircleLayer(
                        circles: [
                          CircleMarker(
                            point: pointLocation,
                            radius: point.unlockRadiusMeters.toDouble(),
                            useRadiusInMeter: true,
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderStrokeWidth: 2,
                            borderColor: AppColors.primary.withValues(
                              alpha: 0.3,
                            ),
                          ),
                        ],
                      ),
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: pointLocation,
                            child: Icon(
                              Icons.location_on,
                              color: AppColors.primary,
                              size: 40,
                            ),
                          ),
                          // User location marker
                          if (_userLocation != null)
                            Marker(
                              point: _userLocation!,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.blue,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 2,
                                  ),
                                ),
                                padding: EdgeInsets.all(4),
                                child: Icon(
                                  Icons.person,
                                  color: Colors.white,
                                  size: 12,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
            // Point Info
            pointAsync.when(
              loading: () => Padding(
                padding: EdgeInsets.all(16),
                child: LoadingIndicator(size: 24),
              ),
              error: (err, st) => SizedBox.shrink(),
              data: (point) {
                final distance = _calculateDistance(
                  point.latitude,
                  point.longitude,
                );
                final isInRange =
                    distance != null && distance <= point.unlockRadiusMeters;

                return Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        point.name ?? 'Неизвестная точка',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      SizedBox(height: 8),
                      Text(
                        point.description ?? 'Нет описания',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _InfoItem(
                              icon: Icons.location_on,
                              label: 'Координаты',
                              value:
                                  '${point.latitude.toStringAsFixed(2)}, ${point.longitude.toStringAsFixed(2)}',
                            ),
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: _InfoItem(
                              icon: Icons.radio,
                              label: 'Радиус',
                              value:
                                  '${point.unlockRadiusMeters.toStringAsFixed(0)} м',
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      // Distance indicator
                      if (distance != null)
                        _InfoItem(
                          icon: Icons.straighten,
                          label: 'Расстояние до точки',
                          value: _formatDistance(distance),
                        ),
                      SizedBox(height: 16),
                      // Check location button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _isCheckingLocation
                              ? null
                              : () => _checkLocation(
                                  point.latitude,
                                  point.longitude,
                                  point.unlockRadiusMeters,
                                ),
                          icon: _isCheckingLocation
                              ? SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : Icon(
                                  isInRange ? Icons.check : Icons.my_location,
                                ),
                          label: Text(
                            isInRange
                                ? 'Вы в зоне разблокировки!'
                                : 'Проверить локацию',
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isInRange
                                ? AppColors.secondary
                                : AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            Divider(height: 0),
            // Messages Section
            Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Text(
                'Сообщения',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            // Messages List
            messagesAsync.when(
              loading: () => Padding(
                padding: EdgeInsets.all(32),
                child: LoadingIndicator(size: 30),
              ),
              error: (err, st) => Padding(
                padding: EdgeInsets.all(16),
                child: Text('Ошибка загрузки сообщений'),
              ),
              data: (messages) => messages.isNotEmpty
                  ? _MessagesList(
                      messages: messages,
                      pointId: widget.pointId,
                      ref: ref,
                    )
                  : Padding(
                      padding: EdgeInsets.all(16),
                      child: Text('Нет сообщений'),
                    ),
            ),
            // Message Input
            Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      enabled: !_isCreatingMessage,
                      decoration: InputDecoration(
                        hintText: 'Напишите сообщение...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                      maxLines: 1,
                    ),
                  ),
                  SizedBox(width: 8),
                  IconButton(
                    onPressed: _isCreatingMessage ? null : _handleSendMessage,
                    icon: Icon(Icons.send),
                    color: AppColors.primary,
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _MessagesList extends ConsumerWidget {
  final List<dynamic> messages;
  final String pointId;
  final WidgetRef ref;

  const _MessagesList({
    required this.messages,
    required this.pointId,
    required this.ref,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileProvider);

    return profileAsync.when(
      loading: () => Padding(
        padding: EdgeInsets.all(32),
        child: LoadingIndicator(size: 30),
      ),
      error: (err, st) => SizedBox.shrink(),
      data: (currentUser) {
        final currentUserId = currentUser.id;

        return ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: messages.length,
          itemBuilder: (context, index) {
            final msg = messages[index];
            final messageId = msg['id'] as String;
            final username = msg['username'] as String?;
            final userId = msg['userId'] as String?;
            final isOwnMessage = userId == currentUserId;

            final displayAuthor =
                (username?.isNotEmpty == true
                    ? username
                    : 'Пользователь #${userId?.substring(0, 8) ?? 'unknown'}') ??
                'Аноним';

            return _MessageItem(
              author: displayAuthor,
              content: msg['content'] as String? ?? '',
              likes: (msg['likesCount'] as int?) ?? 0,
              isLikedByMe: (msg['isLikedByCurrentUser'] as bool?) ?? false,
              createdAt: msg['createdAt'] as String?,
              isOwnMessage: isOwnMessage,
              onDeleteTap: isOwnMessage
                  ? () async {
                      try {
                        final notifier = ref.read(
                          messagesNotifierProvider(pointId).notifier,
                        );
                        await notifier.deleteMessage(messageId);
                        NotificationService.showSuccessSnackBar(
                          'Комментарий удален',
                        );
                        ref.invalidate(messagesProvider(pointId));
                      } catch (e) {
                        NotificationService.showErrorSnackBar(
                          'Ошибка при удалении комментария',
                        );
                      }
                    }
                  : null,
              onLikeTap: () async {
                try {
                  final notifier = ref.read(
                    messagesNotifierProvider(pointId).notifier,
                  );
                  await notifier.toggleLike(messageId);
                  ref.invalidate(messagesProvider(pointId));
                } catch (e) {
                  NotificationService.showErrorSnackBar(
                    'Ошибка при обновлении лайка',
                  );
                }
              },
            );
          },
        );
      },
    );
  }
}

class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: AppColors.primary),
              SizedBox(width: 4),
              Text(label, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
          SizedBox(height: 4),
          Text(value, style: Theme.of(context).textTheme.titleSmall),
        ],
      ),
    );
  }
}

class _MessageItem extends StatelessWidget {
  final String author;
  final String content;
  final int likes;
  final bool isLikedByMe;
  final String? createdAt;
  final bool isOwnMessage;
  final VoidCallback? onDeleteTap;
  final VoidCallback onLikeTap;

  const _MessageItem({
    required this.author,
    required this.content,
    required this.likes,
    required this.isLikedByMe,
    this.createdAt,
    required this.isOwnMessage,
    this.onDeleteTap,
    required this.onLikeTap,
  });

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '';
    try {
      final date = DateTime.parse(dateStr);
      final now = DateTime.now();
      final diff = now.difference(date);

      if (diff.inDays > 0) {
        return '${diff.inDays}д назад';
      } else if (diff.inHours > 0) {
        return '${diff.inHours}ч назад';
      } else if (diff.inMinutes > 0) {
        return '${diff.inMinutes}мин назад';
      } else {
        return 'только что';
      }
    } catch (e) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Text(author, style: Theme.of(context).textTheme.titleSmall),
                    if (createdAt != null) ...[
                      SizedBox(width: 8),
                      Text(
                        _formatDate(createdAt),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textTertiary,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (isOwnMessage && onDeleteTap != null)
                IconButton(
                  icon: Icon(
                    Icons.delete,
                    size: 16,
                    color: AppColors.textTertiary,
                  ),
                  onPressed: onDeleteTap,
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints(),
                ),
            ],
          ),
          SizedBox(height: 8),
          Text(content, style: Theme.of(context).textTheme.bodyMedium),
          SizedBox(height: 8),
          GestureDetector(
            onTap: onLikeTap,
            child: Row(
              children: [
                Icon(
                  isLikedByMe ? Icons.favorite : Icons.favorite_border,
                  size: 16,
                  color: isLikedByMe ? Colors.red : AppColors.textTertiary,
                ),
                SizedBox(width: 4),
                Text(
                  likes.toString(),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: isLikedByMe ? Colors.red : AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
