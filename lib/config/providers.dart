import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_service.dart';
import '../services/token_storage_service.dart';

final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService();
});

final tokenStorageProvider = FutureProvider<TokenStorageService>((ref) async {
  final tokenStorage = TokenStorageService();
  await tokenStorage.init();
  return tokenStorage;
});
