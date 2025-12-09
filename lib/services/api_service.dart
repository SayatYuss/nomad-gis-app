import 'package:nomad_gis_lib/nomad_gis_lib.dart';
import '../utils/constants.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();

  late NomadApiClient _client;

  factory ApiService() {
    return _instance;
  }

  ApiService._internal() {
    _client = NomadApiClient(baseUrl: AppConstants.apiBaseUrl);
  }

  NomadApiClient get client => _client;

  void setTokens({
    required String accessToken,
    required String refreshToken,
    required String userId,
    required String deviceId,
  }) {
    _client.setTokens(
      accessToken: accessToken,
      refreshToken: refreshToken,
      userId: userId,
      deviceId: deviceId,
    );
  }

  void clearTokens() {
    _client.clearTokens();
  }

  String? getAccessToken() => _client.getAccessToken();
  String? getRefreshToken() => _client.getRefreshToken();
  String? getUserId() => _client.getUserId();
  String? getDeviceId() => _client.getDeviceId();
}
