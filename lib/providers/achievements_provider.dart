import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nomad_gis_lib/nomad_gis_lib.dart';
import '../config/providers.dart';

// All Achievements Provider
final allAchievementsProvider = FutureProvider<List<AchievementResponse>>((
  ref,
) async {
  final apiService = ref.watch(apiServiceProvider);
  return apiService.client.achievements.getAchievements();
});

// Single Achievement Provider - с autoDispose для экономии памяти
final achievementProvider = FutureProvider.autoDispose
    .family<AchievementResponse, String>((ref, id) async {
      // Кэшируем на 5 минут
      final link = ref.keepAlive();
      Future.delayed(const Duration(minutes: 5), () => link.close());

      final apiService = ref.watch(apiServiceProvider);
      return apiService.client.achievements.getAchievementById(id);
    });

// Messages Provider - с autoDispose
final messagesProvider = FutureProvider.autoDispose
    .family<List<Map<String, dynamic>>, String>((ref, pointId) async {
      // Кэшируем на 1 минуту для сообщений
      final link = ref.keepAlive();
      Future.delayed(const Duration(minutes: 1), () => link.close());

      final apiService = ref.watch(apiServiceProvider);
      return apiService.client.messages.getMessagesByPoint(pointId);
    });

// Messages Notifier for creating and managing messages
class MessagesNotifier extends StateNotifier<AsyncValue<void>> {
  final Ref _ref;
  final String pointId;

  MessagesNotifier(this._ref, this.pointId)
    : super(const AsyncValue.data(null));

  Future<void> createMessage(String content) async {
    state = const AsyncValue.loading();

    try {
      final apiService = _ref.read(apiServiceProvider);
      await apiService.client.messages.createMessage(
        mapPointId: pointId,
        content: content,
      );
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> deleteMessage(String messageId) async {
    state = const AsyncValue.loading();

    try {
      final apiService = _ref.read(apiServiceProvider);
      await apiService.client.messages.deleteMessage(messageId);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> toggleLike(String messageId) async {
    // Don't set loading state to avoid UI flickering
    try {
      final apiService = _ref.read(apiServiceProvider);
      await apiService.client.messages.toggleLike(messageId);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow; // Re-throw to handle in UI
    }
  }
}

final messagesNotifierProvider = StateNotifierProvider.autoDispose
    .family<MessagesNotifier, AsyncValue<void>, String>((ref, pointId) {
      return MessagesNotifier(ref, pointId);
    });
