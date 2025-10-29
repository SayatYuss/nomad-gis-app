import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/profile_api_service.dart';
import '../../domain/models/user_achievements.dart';
import '../../domain/models/user_dto.dart';
import '../../domain/models/user_map_progress.dart';
import '../../domain/models/user_profile_data.dart';

// 1. Провайдер для самого ProfileApiService (чтобы Notifier мог его читать)
final profileApiServiceProvider = Provider<ProfileApiService>((ref) {
  return ProfileApiService();
});

// 2. Наш AsyncNotifier
class ProfileNotifier extends AsyncNotifier<UserProfileData> {
  
  // 'build' вызывается автоматически, когда провайдер
  // впервые запрашивается. Он устанавливает начальное состояние.
  @override
  Future<UserProfileData> build() {
    // Вызываем наш главный метод-загрузчик
    return _fetchAllProfileData();
  }

  // --- ЭТОТ МЕТОД - ТО САМОЕ "ОДНО ДЕЙСТВИЕ" ---
  // Он будет вызван в 'build' ИЛИ при ручном обновлении (refresh)
  Future<UserProfileData> _fetchAllProfileData() async {
    final apiService = ref.read(profileApiServiceProvider);

    try {
      // 1. Создаем три "будущих" запроса БЕЗ await
      final profileFuture = apiService.getMyProfile();
      final pointsFuture = apiService.getMyPoints();
      final achievementsFuture = apiService.getMyAchievements();

      // 2. Запускаем все 3 запроса параллельно и ждем их завершения
      final results = await Future.wait([
        profileFuture,
        pointsFuture,
        achievementsFuture,
      ]);

      // 3. Извлекаем результаты
      final UserDto? profile = results[0] as UserDto?;
      final List<UserMapProgress> points = results[1] as List<UserMapProgress>;
      final List<UserAchievement> achievements = results[2] as List<UserAchievement>;

      // Если профиль почему-то не загрузился (например, 404),
      // вся загрузка считается проваленной.
      if (profile == null) {
        throw Exception('Не удалось загрузить основной профиль пользователя.');
      }

      // 4. Возвращаем единый объект UserProfileData
      return UserProfileData(
        profile: profile,
        unlockedPoints: points,
        achievements: achievements,
      );
    } catch (e, stacktrace) {
      // Если любой из 3-х запросов упадет, Future.wait
      // выбросит ошибку, и AsyncNotifier сам поймает ее
      // и установит state в AsyncError.
      print('Ошибка при загрузке профиля: $e');
      print(stacktrace);
      rethrow;
    }
  }

  /// Метод для ручного обновления (например, pull-to-refresh)
  Future<void> refresh() async {
    // Устанавливаем состояние в "загрузка"
    state = const AsyncValue.loading();
    
    // Пытаемся перезагрузить все данные
    // AsyncValue.guard автоматически поймает ошибку
    state = await AsyncValue.guard(() => _fetchAllProfileData());
  }
}

// 3. Глобальный провайдер, который будет "смотреть" (watch) наш UI
final profileProvider =
    AsyncNotifierProvider<ProfileNotifier, UserProfileData>(() {
  return ProfileNotifier();
});