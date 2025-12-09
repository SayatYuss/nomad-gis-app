import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nomad_gis_lib/nomad_gis_lib.dart';
import 'package:uuid/uuid.dart';
import '../config/providers.dart';
import '../services/api_service.dart';
import '../services/token_storage_service.dart';
import '../utils/error_handler.dart';

class AuthState {
  final bool isLoading;
  final bool isAuthenticated;
  final UserDto? user;
  final String? error;
  final bool isRestoringSession;

  const AuthState({
    this.isLoading = false,
    this.isAuthenticated = false,
    this.user,
    this.error,
    this.isRestoringSession = false,
  });

  AuthState copyWith({
    bool? isLoading,
    bool? isAuthenticated,
    UserDto? user,
    String? error,
    bool? isRestoringSession,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      user: user ?? this.user,
      error: error,
      isRestoringSession: isRestoringSession ?? this.isRestoringSession,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final ApiService _apiService;
  final TokenStorageService _tokenStorage;
  String? _deviceId;

  AuthNotifier(this._apiService, this._tokenStorage) : super(const AuthState());

  Future<void> _initDeviceId() async {
    _deviceId ??= const Uuid().v4();
  }

  Future<void> register({
    required String email,
    required String username,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await _initDeviceId();

      final response = await _apiService.client.auth.register(
        RegisterRequest(
          email: email,
          username: username,
          password: password,
          deviceId: _deviceId!,
        ),
      );

      await _tokenStorage.saveTokens(
        accessToken: response.accessToken!,
        refreshToken: response.refreshToken!,
        userId: response.user!.id,
        deviceId: _deviceId!,
      );

      _apiService.setTokens(
        accessToken: response.accessToken!,
        refreshToken: response.refreshToken!,
        userId: response.user!.id,
        deviceId: _deviceId!,
      );

      state = state.copyWith(
        isLoading: false,
        isAuthenticated: true,
        user: response.user,
        error: null,
      );
    } on Exception catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: ErrorHandler.getErrorMessage(e),
      );
    }
  }

  Future<void> login({
    required String identifier,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await _initDeviceId();

      final response = await _apiService.client.auth.login(
        LoginRequest(
          identifier: identifier,
          password: password,
          deviceId: _deviceId!,
        ),
      );

      await _tokenStorage.saveTokens(
        accessToken: response.accessToken!,
        refreshToken: response.refreshToken!,
        userId: response.user!.id,
        deviceId: _deviceId!,
      );

      _apiService.setTokens(
        accessToken: response.accessToken!,
        refreshToken: response.refreshToken!,
        userId: response.user!.id,
        deviceId: _deviceId!,
      );

      state = state.copyWith(
        isLoading: false,
        isAuthenticated: true,
        user: response.user,
        error: null,
      );
    } on Exception catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: ErrorHandler.getErrorMessage(e),
      );
    }
  }

  Future<void> restoreSession() async {
    state = state.copyWith(isRestoringSession: true);

    try {
      await _initDeviceId();

      final tokens = await _tokenStorage.loadTokens();
      if (tokens == null) {
        state = state.copyWith(
          isRestoringSession: false,
          isAuthenticated: false,
        );
        return;
      }

      _apiService.setTokens(
        accessToken: tokens['accessToken']!,
        refreshToken: tokens['refreshToken']!,
        userId: tokens['userId']!,
        deviceId: tokens['deviceId']!,
      );
      _deviceId = tokens['deviceId'];

      final user = await _apiService.client.profile.getMe();

      state = state.copyWith(
        isRestoringSession: false,
        isAuthenticated: true,
        user: user,
        error: null,
      );
    } on UnauthorizedException {
      await _tokenStorage.clearTokens();
      _apiService.clearTokens();
      state = state.copyWith(
        isRestoringSession: false,
        isAuthenticated: false,
        error: null,
      );
    } catch (_) {
      state = state.copyWith(
        isRestoringSession: false,
        isAuthenticated: false,
        error: null,
      );
    }
  }

  Future<void> logout() async {
    try {
      final userId = _apiService.getUserId();
      final refreshToken = _apiService.getRefreshToken();
      final deviceId = _apiService.getDeviceId();

      if (userId != null && refreshToken != null && deviceId != null) {
        await _apiService.client.auth.logout(
          LogoutRequest(
            userId: userId,
            refreshToken: refreshToken,
            deviceId: deviceId,
          ),
        );
      }
    } catch (e) {
      // Ignore error, clear locally anyway
    } finally {
      _apiService.clearTokens();
      await _tokenStorage.clearTokens();
      state = const AuthState();
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  final tokenStorageAsync = ref.watch(tokenStorageProvider);

  return tokenStorageAsync.when(
    data: (tokenStorage) => AuthNotifier(apiService, tokenStorage),
    loading: () => AuthNotifier(apiService, TokenStorageService()),
    error: (err, stack) => AuthNotifier(apiService, TokenStorageService()),
  );
});
