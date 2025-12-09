import 'package:flutter_test/flutter_test.dart';
import 'package:nomad_gis_app/utils/error_handler.dart';
import 'package:nomad_gis_app/utils/constants.dart';

void main() {
  group('ErrorHandler', () {
    group('getErrorMessage', () {
      test('returns unknown error for unknown error type', () {
        expect(
          ErrorHandler.getErrorMessage('Unknown error'),
          'Неизвестная ошибка',
        );
      });

      test('returns server error message', () {
        expect(
          ErrorHandler.getErrorMessage(AppStrings.serverError),
          'Ошибка сервера. Попробуйте позже',
        );
      });

      test('returns network error message', () {
        expect(
          ErrorHandler.getErrorMessage(AppStrings.networkError),
          'Ошибка сети. Проверьте интернет соединение',
        );
      });

      test('returns default message for unknown input', () {
        final result = ErrorHandler.getErrorMessage(null);
        expect(result, 'Неизвестная ошибка');
      });
    });

    group('isUnauthorized', () {
      test('returns false for non-unauthorized errors', () {
        expect(ErrorHandler.isUnauthorized('Some other error'), false);
      });

      test('returns false for null', () {
        expect(ErrorHandler.isUnauthorized(null), false);
      });
    });

    group('isValidationError', () {
      test('returns false for non-validation errors', () {
        expect(ErrorHandler.isValidationError('Some other error'), false);
      });

      test('returns false for null', () {
        expect(ErrorHandler.isValidationError(null), false);
      });
    });

    group('isNetworkError', () {
      test('returns true for SocketException string', () {
        expect(
          ErrorHandler.isNetworkError('SocketException: Connection refused'),
          true,
        );
      });

      test('returns true for Network error string', () {
        expect(
          ErrorHandler.isNetworkError('Network connection error'),
          true,
        );
      });

      test('returns true for Connection error string', () {
        expect(
          ErrorHandler.isNetworkError('Connection timeout'),
          true,
        );
      });

      test('returns false for other errors', () {
        expect(
          ErrorHandler.isNetworkError('Server error'),
          false,
        );
      });

      test('returns false for null', () {
        expect(ErrorHandler.isNetworkError(null), false);
      });
    });
  });
}
