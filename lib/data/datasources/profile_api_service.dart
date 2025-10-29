import 'package:dio/dio.dart';
import '../../core/api/dio_client.dart'; // Наш настроенный Dio-клиент

// 1. Импортируем наши DTO-модели
import '../../domain/models/user_dto.dart';
import '../../domain/models/user_map_progress.dart';
import '../../domain/models/user_achievements.dart';

// [ИСПРАВЛЕНО] Убрана 'a' из 'ProfileaApiService'
class ProfileApiService {
  final Dio _dio = dioClient;

  // SecureStorageService не нужен, так как interceptor
  // в dio_client.dart уже сам подставляет токен.

  /// Получает информацию о текущем пользователе
  /// [GET] /api/v1/profile/me
  ///
  Future<UserDto?> getMyProfile() async {
    try {
      final response = await _dio.get('/profile/me');
      
      if (response.statusCode == 200) {
        // 2. Используем .fromJson() для парсинга
        return UserDto.fromJson(response.data);
      }
      return null;
    } on DioException catch (e) {
      // DioInterceptor уже должен был обработать 401,
      // но другие ошибки (500, 404) попадут сюда.
      print('Ошибка при получении профиля: $e');
      return null;
    }
  }

  /// Получает список ID точек, открытых пользователем
  /// [GET] /api/v1/profile/my-points
  ///
  Future<List<UserMapProgress>> getMyPoints() async {
    try {
      final response = await _dio.get('/profile/my-points');

      if (response.statusCode == 200) {
        // 3. API возвращает список.
        // Мы преобразуем (map) каждый JSON-объект в Dart-объект.
        List<dynamic> jsonList = response.data;
        return jsonList.map((json) => UserMapProgress.fromJson(json)).toList();
      }
      return []; // Возвращаем пустой список в случае ошибки
    } on DioException catch (e) {
      print('Ошибка при получении открытых точек: $e');
      return [];
    }
  }

  /// Получает список достижений пользователя
  /// [GET] /api/v1/profile/my-achievements
  ///
  Future<List<UserAchievement>> getMyAchievements() async {
    try {
      final response = await _dio.get('/profile/my-achievements');

      if (response.statusCode == 200) {
        // 4. Так же, как и с точками
        List<dynamic> jsonList = response.data;
        return jsonList.map((json) => UserAchievement.fromJson(json)).toList();
      }
      return [];
    } on DioException catch (e) {
      print('Ошибка при получении достижений: $e');
      return [];
    }
  }
  
  // TODO: Добавить методы для обновления профиля
  // (POST /profile/avatar и PUT /profile/me),
  // когда они вам понадобятся.
}