import 'package:flutter_test/flutter_test.dart';
import 'package:nomad_gis_app/utils/error_handler.dart';
import 'package:nomad_gis_lib/nomad_gis_lib.dart';

void main() {
  group('ErrorHandler Tests', () {
    test('Handle ValidationException with field error', () {
      final exception = ValidationException(
        message: 'Validation failed',
        errors: {'email': 'Invalid email'},
      );

      final message = ErrorHandler.getErrorMessage(exception);
      expect(message, isNotEmpty);
      expect(message, contains('Invalid email'));
    });

    test('Handle ValidationException with generic message', () {
      final exception = ValidationException(
        message: 'Validation failed',
        errors: {},
      );

      final message = ErrorHandler.getErrorMessage(exception);
      expect(message, contains('Validation failed'));
    });

    test('Handle UnauthorizedException', () {
      final exception = UnauthorizedException(message: 'Invalid credentials');

      final message = ErrorHandler.getErrorMessage(exception);
      expect(message, contains('Invalid credentials'));
    });

    test('Handle ApiException with status code 404', () {
      final exception = ApiException(statusCode: 404, message: 'Not found');

      final message = ErrorHandler.getErrorMessage(exception);
      expect(message, isNotEmpty);
    });

    test('Handle ApiException with status code 500', () {
      final exception = ApiException(
        statusCode: 500,
        message: 'Internal server error',
      );

      final message = ErrorHandler.getErrorMessage(exception);
      expect(message, isNotEmpty);
    });

    test('Handle generic Exception', () {
      final exception = Exception('Unknown error');
      final message = ErrorHandler.getErrorMessage(exception);
      expect(message, isNotEmpty);
    });

    test('Handle null error', () {
      const exception = 'String error';
      final message = ErrorHandler.getErrorMessage(exception);
      expect(message, isNotEmpty);
    });
  });
}
