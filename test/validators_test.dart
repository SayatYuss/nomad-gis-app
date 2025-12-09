import 'package:flutter_test/flutter_test.dart';
import 'package:nomad_gis_app/utils/validators.dart';

void main() {
  group('Validators', () {
    group('validateEmail', () {
      test('returns null for valid email', () {
        expect(Validators.validateEmail('test@example.com'), isNull);
      });

      test('returns error for invalid email format', () {
        expect(Validators.validateEmail('invalid-email'), isNotNull);
      });

      test('returns error for empty email', () {
        expect(Validators.validateEmail(''), isNotNull);
      });

      test('returns error for null email', () {
        expect(Validators.validateEmail(null), isNotNull);
      });

      test('returns null for email with numbers and special chars', () {
        expect(Validators.validateEmail('user+tag@example.co.uk'), isNull);
      });
    });

    group('validateUsername', () {
      test('returns null for valid username', () {
        expect(Validators.validateUsername('john_doe'), isNull);
      });

      test('returns null for single character username', () {
        expect(Validators.validateUsername('a'), isNull);
      });

      test('returns error for empty username', () {
        expect(Validators.validateUsername(''), isNotNull);
      });

      test('returns error for null username', () {
        expect(Validators.validateUsername(null), isNotNull);
      });
    });

    group('validatePassword', () {
      test('returns null for valid password (8+ chars)', () {
        expect(Validators.validatePassword('password123'), isNull);
      });

      test('returns error for password less than 8 chars', () {
        expect(Validators.validatePassword('pass123'), isNotNull);
      });

      test('returns error for empty password', () {
        expect(Validators.validatePassword(''), isNotNull);
      });

      test('returns error for null password', () {
        expect(Validators.validatePassword(null), isNotNull);
      });
    });

    group('validateIdentifier', () {
      test('returns null for non-empty identifier', () {
        expect(Validators.validateIdentifier('user@example.com'), isNull);
      });

      test('returns error for empty identifier', () {
        expect(Validators.validateIdentifier(''), isNotNull);
      });

      test('returns error for null identifier', () {
        expect(Validators.validateIdentifier(null), isNotNull);
      });
    });

    group('validateConfirmPassword', () {
      test('returns null when passwords match', () {
        expect(Validators.validateConfirmPassword('password123', 'password123'),
            isNull);
      });

      test('returns error when passwords do not match', () {
        expect(Validators.validateConfirmPassword('password123', 'password456'),
            isNotNull);
      });

      test('returns error for empty confirm password', () {
        expect(
            Validators.validateConfirmPassword('', 'password123'), isNotNull);
      });
    });

    group('isValidCoordinate', () {
      test('returns true for valid coordinates', () {
        expect(Validators.isValidCoordinate(55.7558, 37.6173), true);
      });

      test('returns true for edge case latitude', () {
        expect(Validators.isValidCoordinate(-90, 37.6173), true);
        expect(Validators.isValidCoordinate(90, 37.6173), true);
      });

      test('returns true for edge case longitude', () {
        expect(Validators.isValidCoordinate(55.7558, -180), true);
        expect(Validators.isValidCoordinate(55.7558, 180), true);
      });

      test('returns false for invalid latitude', () {
        expect(Validators.isValidCoordinate(91, 37.6173), false);
        expect(Validators.isValidCoordinate(-91, 37.6173), false);
      });

      test('returns false for invalid longitude', () {
        expect(Validators.isValidCoordinate(55.7558, 181), false);
        expect(Validators.isValidCoordinate(55.7558, -181), false);
      });

      test('returns false for both invalid', () {
        expect(Validators.isValidCoordinate(100, 200), false);
      });
    });
  });
}
