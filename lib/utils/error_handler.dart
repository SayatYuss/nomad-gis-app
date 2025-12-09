import 'package:nomad_gis_lib/nomad_gis_lib.dart';
import 'constants.dart';

class ErrorHandler {
  static String getErrorMessage(dynamic error) {
    if (error is UnauthorizedException) {
      return 'Требуется вход в аккаунт';
    } else if (error is ValidationException) {
      return error.message;
    } else if (error is ApiException) {
      if (error.statusCode == 401) {
        return 'Требуется вход в аккаунт';
      } else if (error.statusCode == 403) {
        return 'Доступ запрещен';
      } else if (error.statusCode == 404) {
        return 'Ресурс не найден';
      } else if (error.statusCode == 500 || error.statusCode == 502) {
        return AppStrings.serverError;
      } else if (error.statusCode == 413) {
        return 'Файл слишком большой (максимум 5 МБ)';
      }
      return error.message;
    } else if (error is FormatException) {
      return 'Ошибка обработки данных';
    } else if (error is Exception) {
      final errorString = error.toString();
      if (errorString.contains('SocketException') ||
          errorString.contains('Network')) {
        return AppStrings.networkError;
      }
      return error.toString();
    } else {
      return 'Неизвестная ошибка';
    }
  }

  static bool isUnauthorized(dynamic error) {
    if (error is UnauthorizedException) {
      return true;
    } else if (error is ApiException) {
      return error.statusCode == 401;
    }
    return false;
  }

  static bool isValidationError(dynamic error) {
    return error is ValidationException;
  }

  static bool isNetworkError(dynamic error) {
    final errorString = error.toString();
    return errorString.contains('SocketException') ||
        errorString.contains('Network') ||
        errorString.contains('Connection');
  }
}
