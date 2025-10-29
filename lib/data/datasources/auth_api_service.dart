import 'package:dio/dio.dart';
import '../../core/api/dio_client.dart'; // Наш клиент из Шага 3
import '../../core/storage/secure_storage_service.dart'; // Наш сервис из Шага 2

class AuthApiService {
  final Dio _dio = dioClient; // Используем глобальный экземпляр
  final SecureStorageService _storageService = SecureStorageService();

  //
  Future<bool> login(String identifier, String password, String deviceId) async {
    try {
      final response = await _dio.post(
        '/auth/login',
        data: {
          'identifier': identifier,
          'password': password,
          'deviceId': deviceId,
        },
      );

      if (response.statusCode == 200) {
        //
        final accessToken = response.data['accessToken'];
        final refreshToken = response.data['refreshToken'];
        final userId = response.data['user']['id'];

        // Сохраняем все
        await _storageService.saveAccessToken(accessToken);
        await _storageService.saveRefreshToken(refreshToken);
        await _storageService.saveUserId(userId);
        await _storageService.saveDeviceId(deviceId);
        
        return true;
      }
      return false;
    } on DioException catch (e) {
      // DioInterceptor уже обработал 401, но 400 (неверный пароль) придут сюда
      print('Login error: ${e.response?.data}');
      return false;
    }
  }

  //
  Future<bool> register(String email, String username, String password, String deviceId) async {
    try {
      final response = await _dio.post(
        '/auth/register',
        data: {
          'email': email,
          'username': username,
          'password': password,
          'deviceId': deviceId,
        },
      );
      
      // После регистрации API сразу возвращает токены, так что логинимся
      if (response.statusCode == 200) {
        final accessToken = response.data['accessToken'];
        final refreshToken = response.data['refreshToken'];
        final userId = response.data['user']['id'];

        await _storageService.saveAccessToken(accessToken);
        await _storageService.saveRefreshToken(refreshToken);
        await _storageService.saveUserId(userId);
        await _storageService.saveDeviceId(deviceId);

        return true;
      }
      return false;
    } on DioException catch (e) {
      // 409 (Conflict/Дубликат) придет сюда
      print('Register error: ${e.response?.data}');
      return false;
    }
  }

  Future<void> logout() async {
    // tODO: Вызвать /auth/logout на сервере, если нужно
    await _storageService.deleteAllTokens();
  }
}