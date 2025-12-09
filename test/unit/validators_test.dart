import 'package:flutter_test/flutter_test.dart';
import 'package:nomad_gis_app/utils/validators.dart';

void main() {
  group('Email Validator', () {
    test('Valid email should return empty string', () {
      expect(Validators.validateEmail('user@example.com'), isEmpty);
    });

    test('Valid email with domain extension', () {
      expect(Validators.validateEmail('test@gmail.co.uk'), isEmpty);
    });

    test('Empty email should return error', () {
      expect(
        Validators.validateEmail(''),
        contains('Email не может быть пусто'),
      );
    });

    test('Invalid email without @', () {
      expect(
        Validators.validateEmail('invalidemail.com'),
        contains('Некорректный формат email'),
      );
    });

    test('Invalid email with multiple @', () {
      expect(
        Validators.validateEmail('user@@example.com'),
        contains('Некорректный формат email'),
      );
    });
  });

  group('Username Validator', () {
    test('Valid username should return empty string', () {
      expect(Validators.validateUsername('validuser'), isEmpty);
    });

    test('Username with numbers should be valid', () {
      expect(Validators.validateUsername('user123'), isEmpty);
    });

    test('Username with underscore should be valid', () {
      expect(Validators.validateUsername('user_name'), isEmpty);
    });

    test('Empty username should return error', () {
      expect(
        Validators.validateUsername(''),
        contains('Имя пользователя не может быть пусто'),
      );
    });

    test('Username too short should return error', () {
      expect(Validators.validateUsername('ab'), contains('минимум 3 символа'));
    });

    test('Username too long should return error', () {
      expect(
        Validators.validateUsername('a' * 51),
        contains('максимум 50 символов'),
      );
    });

    test('Username with special characters should be invalid', () {
      expect(
        Validators.validateUsername('user@name'),
        contains('только буквы'),
      );
    });
  });

  group('Password Validator', () {
    test('Valid password should return empty string', () {
      expect(Validators.validatePassword('SecurePass123'), isEmpty);
    });

    test('Password with uppercase and numbers', () {
      expect(Validators.validatePassword('Password1'), isEmpty);
    });

    test('Empty password should return error', () {
      expect(
        Validators.validatePassword(''),
        contains('Пароль не может быть пусто'),
      );
    });

    test('Password too short should return error', () {
      expect(
        Validators.validatePassword('Pass1'),
        contains('минимум 8 символов'),
      );
    });

    test('Password too long should return error', () {
      expect(
        Validators.validatePassword('a' * 129),
        contains('максимум 128 символов'),
      );
    });

    test('Password with no uppercase should return error', () {
      expect(
        Validators.validatePassword('password123'),
        contains('большую букву'),
      );
    });

    test('Password with no numbers should return error', () {
      expect(Validators.validatePassword('PasswordABC'), contains('цифру'));
    });
  });

  group('Identifier Validator', () {
    test('Valid email identifier should return empty string', () {
      expect(Validators.validateIdentifier('user@example.com'), isEmpty);
    });

    test('Valid username identifier should return empty string', () {
      expect(Validators.validateIdentifier('validuser'), isEmpty);
    });

    test('Empty identifier should return error', () {
      expect(
        Validators.validateIdentifier(''),
        contains('не может быть пусто'),
      );
    });

    test('Invalid identifier should return error', () {
      expect(Validators.validateIdentifier('ab'), isNotEmpty);
    });
  });

  group('Coordinate Validator', () {
    test('Valid latitude should return empty string', () {
      expect(Validators.validateCoordinate(55.75), isEmpty);
    });

    test('Valid negative latitude', () {
      expect(Validators.validateCoordinate(-33.865), isEmpty);
    });

    test('Maximum valid latitude', () {
      expect(Validators.validateCoordinate(90.0), isEmpty);
    });

    test('Minimum valid latitude', () {
      expect(Validators.validateCoordinate(-90.0), isEmpty);
    });

    test('Latitude too high should return error', () {
      expect(
        Validators.validateCoordinate(91.0),
        contains('должна быть между'),
      );
    });

    test('Latitude too low should return error', () {
      expect(
        Validators.validateCoordinate(-91.0),
        contains('должна быть между'),
      );
    });
  });
}
