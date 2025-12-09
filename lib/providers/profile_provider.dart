import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nomad_gis_lib/nomad_gis_lib.dart';
import '../config/providers.dart';
import '../utils/error_handler.dart';

// Current Profile Provider
final profileProvider = FutureProvider<UserDto>((ref) async {
  final apiService = ref.watch(apiServiceProvider);
  return apiService.client.profile.getMe();
});

// User Points Provider
final userPointsProvider = FutureProvider<List<MapPointRequest>>((ref) async {
  final apiService = ref.watch(apiServiceProvider);
  return apiService.client.profile.getMyPoints();
});

// User Achievements Provider
final userAchievementsProvider = FutureProvider<List<AchievementResponse>>((
  ref,
) async {
  final apiService = ref.watch(apiServiceProvider);
  return apiService.client.profile.getMyAchievements();
});

// Update Profile Notifier
class UpdateProfileNotifier extends StateNotifier<AsyncValue<void>> {
  final Ref _ref;

  UpdateProfileNotifier(this._ref) : super(const AsyncValue.data(null));

  Future<void> updateProfile({
    String? username,
    String? currentPassword,
    String? newPassword,
  }) async {
    state = const AsyncValue.loading();

    try {
      final apiService = _ref.read(apiServiceProvider);
      await apiService.client.profile.updateProfile(
        username: username,
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      state = const AsyncValue.data(null);
    } on Exception catch (e) {
      state = AsyncValue.error(
        ErrorHandler.getErrorMessage(e),
        StackTrace.current,
      );
    }
  }

  Future<void> uploadAvatar(List<int> fileBytes) async {
    state = const AsyncValue.loading();

    try {
      final apiService = _ref.read(apiServiceProvider);
      await apiService.client.profile.uploadAvatar(fileBytes);
      state = const AsyncValue.data(null);
    } on Exception catch (e) {
      state = AsyncValue.error(
        ErrorHandler.getErrorMessage(e),
        StackTrace.current,
      );
    }
  }
}

final updateProfileProvider =
    StateNotifierProvider<UpdateProfileNotifier, AsyncValue<void>>((ref) {
      return UpdateProfileNotifier(ref);
    });
