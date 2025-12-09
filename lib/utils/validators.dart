import 'constants.dart';

class Validators {
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email не может быть пусто';
    }

    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    if (!emailRegex.hasMatch(value)) {
      return 'Некорректный формат email';
    }

    return null;
  }

  static String? validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return 'Имя пользователя не может быть пусто';
    }

    if (value.length < AppConstants.minUsernameLength) {
      return 'Имя пользователя: минимум ${AppConstants.minUsernameLength} символа';
    }

    if (value.length > 50) {
      return 'Имя пользователя: максимум 50 символов';
    }

    final usernameRegex = RegExp(r'^[a-zA-Z0-9_]+$');
    if (!usernameRegex.hasMatch(value)) {
      return 'Имя пользователя: только буквы, цифры и подчеркивание';
    }

    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Пароль не может быть пусто';
    }

    if (value.length < AppConstants.minPasswordLength) {
      return 'Пароль: минимум ${AppConstants.minPasswordLength} символов';
    }

    if (value.length > 128) {
      return 'Пароль: максимум 128 символов';
    }

    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'Пароль должен содержать большую букву';
    }

    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'Пароль должен содержать цифру';
    }

    return null;
  }

  static String? validateIdentifier(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email или имя пользователя не может быть пусто';
    }

    // Try as email
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    if (emailRegex.hasMatch(value)) {
      return null;
    }

    // Try as username
    if (value.length >= 3 && value.length <= 50) {
      final usernameRegex = RegExp(r'^[a-zA-Z0-9_]+$');
      if (usernameRegex.hasMatch(value)) {
        return null;
      }
    }

    return 'Некорректный email или имя пользователя';
  }

  static String? validateConfirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Подтверждение пароля не может быть пусто';
    }

    if (value != password) {
      return 'Пароли не совпадают';
    }

    return null;
  }

  static String? validateCoordinate(double value) {
    if (value < -90 || value > 90) {
      return 'Координата должна быть между -90 и 90';
    }
    return null;
  }

  static bool isValidCoordinate(double latitude, double longitude) {
    return latitude >= -90 &&
        latitude <= 90 &&
        longitude >= -180 &&
        longitude <= 180;
  }
}
