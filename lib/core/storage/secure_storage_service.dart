import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// Ключи, которые мы будем использовать
const String _accessTokenKey = 'accessToken';
const String _refreshTokenKey = 'refreshToken';
const String _userIdKey = 'userId';
const String _deviceIdKey = 'deviceId';

class SecureStorageService {
  final _storage = const FlutterSecureStorage();

  // --- Access Token ---
  Future<void> saveAccessToken(String token) async {
    await _storage.write(key: _accessTokenKey, value: token);
  }

  Future<String?> getAccessToken() async {
    return await _storage.read(key: _accessTokenKey);
  }

  // --- Refresh Token ---
  Future<void> saveRefreshToken(String token) async {
    await _storage.write(key: _refreshTokenKey, value: token);
  }

  Future<String?> getRefreshToken() async {
    return await _storage.read(key: _refreshTokenKey);
  }

  // --- User & Device ID (Нужны для запроса на Refresh) ---
  //
  Future<void> saveUserId(String id) async {
    await _storage.write(key: _userIdKey, value: id);
  }

  Future<String?> getUserId() async {
    return await _storage.read(key: _userIdKey);
  }

  Future<void> saveDeviceId(String id) async {
    await _storage.write(key: _deviceIdKey, value: id);
  }

  Future<String?> getDeviceId() async {
    return await _storage.read(key: _deviceIdKey);
  }
  
  // --- Удаление всего при выходе ---
  Future<void> deleteAllTokens() async {
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _refreshTokenKey);
    await _storage.delete(key: _userIdKey);
    await _storage.delete(key: _deviceIdKey);
  }
}