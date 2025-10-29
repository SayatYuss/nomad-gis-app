import 'package:dio/dio.dart';
import 'package:nomad_gis/core/storage/secure_storage_service.dart'; // Наш сервис из Шага 2

// URL вашего API
const String _apiBaseUrl = 'https://api.joshki.top/api/v1';

// Глобальный экземпляр Dio, который будет использовать все приложение
final dioClient = createDioClient();

Dio createDioClient() {
  final dio = Dio(
    BaseOptions(
      baseUrl: _apiBaseUrl,
      receiveTimeout: const Duration(seconds: 15), // 15 секунд
      connectTimeout: const Duration(seconds: 15),
      sendTimeout: const Duration(seconds: 15),
    ),
  );

  final storageService = SecureStorageService();

  dio.interceptors.add(
    QueuedInterceptorsWrapper(
      // --- 1. ВЫЗЫВАЕТСЯ ПЕРЕД КАЖДЫМ ЗАПРОСОМ ---
      onRequest: (options, handler) async {
        // Получаем токен из хранилища
        final accessToken = await storageService.getAccessToken();
        
        // Если токен есть, добавляем его в заголовок
        if (accessToken != null) {
          options.headers['Authorization'] = 'Bearer $accessToken';
        }
        return handler.next(options); // Продолжаем запрос
      },

      // --- 2. ВЫЗЫВАЕТСЯ ПРИ ОШИБКЕ (например, 401) ---
      onError: (DioException err, handler) async {
        // Проверяем, что ошибка - это 401 (Unauthorized)
        if (err.response?.statusCode == 401) {
          try {
            // 1. Получаем старый Refresh Token, UserId и DeviceId
            final refreshToken = await storageService.getRefreshToken();
            final userId = await storageService.getUserId();
            final deviceId = await storageService.getDeviceId();

            if (refreshToken == null || userId == null || deviceId == null) {
              // Если чего-то нет, мы не можем обновиться. Выходим из системы.
              await storageService.deleteAllTokens();
              // tODO: Добавить логику "выхода" (например, через Riverpod)
              return handler.reject(err);
            }

            // 2. Делаем запрос на обновление токена
            //
            final refreshResponse = await dio.post(
              '$_apiBaseUrl/auth/refresh', // Используем dio, но без interceptor'а
              data: {
                'refreshToken': refreshToken,
                'userId': userId,
                'deviceId': deviceId,
              },
            );

            if (refreshResponse.statusCode == 200) {
              // 3. Сохраняем новые токены
              final newAccessToken = refreshResponse.data['accessToken'];
              final newRefreshToken = refreshResponse.data['refreshToken'];
              await storageService.saveAccessToken(newAccessToken);
              await storageService.saveRefreshToken(newRefreshToken);

              // 4. Повторяем ОРИГИНАЛЬНЫЙ запрос с НОВЫМ токеном
              // Dio сам обновит заголовок 'Authorization' при следующем onRequest
              final originalRequestOptions = err.requestOptions;
              originalRequestOptions.headers['Authorization'] = 'Bearer $newAccessToken';
              
              // Повторяем запрос
              final response = await dio.request(
                originalRequestOptions.path,
                data: originalRequestOptions.data,
                queryParameters: originalRequestOptions.queryParameters,
                options: Options(
                  method: originalRequestOptions.method,
                  headers: {
                    ...originalRequestOptions.headers,
                    'Authorization': 'Bearer $newAccessToken', // Принудительно ставим новый токен
                  },
                ),
              );
              return handler.resolve(response); // Возвращаем успешный ответ
            }
          } on DioException {
            // Если и запрос на REFRESH провалился (например, refresh token тоже протух)
            await storageService.deleteAllTokens();
            // tODO: Логика "выхода"
            return handler.reject(err); // Провалить запрос
          }
        }
        // Если ошибка не 401, просто пробрасываем ее дальше
        return handler.next(err);
      },
    ),
  );

  return dio;
}