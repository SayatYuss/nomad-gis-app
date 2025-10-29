import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../data/datasources/auth_api_service.dart';

// 1. Провайдер для самого сервиса (чтобы его можно было получить)
final authApiServiceProvider = Provider<AuthApiService>((ref) {
  return AuthApiService();
});

// 2. Провайдер состояния (StateNotifier)
// Он будет хранить состояние: аутентифицирован пользователь или нет
enum AuthState { unknown, authenticated, unauthenticated }

class AuthStateNotifier extends StateNotifier<AuthState> {
  final AuthApiService _authApiService;
  
  AuthStateNotifier(this._authApiService) : super(AuthState.unknown) {
    // При запуске приложения проверяем, есть ли токен
    _checkTokenOnStart();
  }

  Future<void> _checkTokenOnStart() async {
    // Простая проверка. Можно и не делать, Interceptor все равно проверит
    // при первом запросе. Но это полезно для UI.
    // ... (можно добавить проверку токена)
    // Пока просто скажем, что мы не вошли
    state = AuthState.unauthenticated; 
  }

  Future<bool> login(String identifier, String password, String deviceId) async {
    final success = await _authApiService.login(identifier, password, deviceId);
    if (success) {
      state = AuthState.authenticated;
      return true;
    }
    return false;
  }
  
  Future<bool> register(String email, String username, String password, String deviceId) async {
    final success = await _authApiService.register(email, username, password, deviceId);
    if (success) {
      state = AuthState.authenticated;
      return true;
    }
    return false;
  }

  Future<void> logout() async {
    await _authApiService.logout();
    state = AuthState.unauthenticated;
  }
}

// 3. Глобальный провайдер, который будет использовать UI
final authProvider = StateNotifierProvider<AuthStateNotifier, AuthState>((ref) {
  final authApiService = ref.watch(authApiServiceProvider);
  return AuthStateNotifier(authApiService);
});