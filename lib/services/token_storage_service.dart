import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';

class TokenStorageService {
  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
    required String userId,
    required String deviceId,
  }) async {
    await _prefs.setString(AppConstants.keyAccessToken, accessToken);
    await _prefs.setString(AppConstants.keyRefreshToken, refreshToken);
    await _prefs.setString(AppConstants.keyUserId, userId);
    await _prefs.setString(AppConstants.keyDeviceId, deviceId);
  }

  Future<Map<String, String>?> loadTokens() async {
    final accessToken = _prefs.getString(AppConstants.keyAccessToken);
    final refreshToken = _prefs.getString(AppConstants.keyRefreshToken);
    final userId = _prefs.getString(AppConstants.keyUserId);
    final deviceId = _prefs.getString(AppConstants.keyDeviceId);

    if (accessToken == null || refreshToken == null || userId == null) {
      return null;
    }

    return {
      'accessToken': accessToken,
      'refreshToken': refreshToken,
      'userId': userId,
      'deviceId': deviceId ?? 'unknown',
    };
  }

  Future<void> clearTokens() async {
    await _prefs.remove(AppConstants.keyAccessToken);
    await _prefs.remove(AppConstants.keyRefreshToken);
    await _prefs.remove(AppConstants.keyUserId);
    await _prefs.remove(AppConstants.keyDeviceId);
  }

  String? getAccessToken() => _prefs.getString(AppConstants.keyAccessToken);
  String? getRefreshToken() => _prefs.getString(AppConstants.keyRefreshToken);
  String? getUserId() => _prefs.getString(AppConstants.keyUserId);
  String? getDeviceId() => _prefs.getString(AppConstants.keyDeviceId);
}
