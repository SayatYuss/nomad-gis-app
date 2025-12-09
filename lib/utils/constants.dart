class AppConstants {
  // API Configuration
  static const String apiBaseUrl = 'https://api.joshki.top';

  // Shared Preferences Keys
  static const String keyAccessToken = 'access_token';
  static const String keyRefreshToken = 'refresh_token';
  static const String keyUserId = 'user_id';
  static const String keyDeviceId = 'device_id';

  // Location check interval in seconds
  static const int locationCheckIntervalSeconds = 10;

  // Map defaults
  static const double defaultMapZoom = 14.0;
  static const double defaultUnlockRadius = 50.0; // meters

  // UI
  static const double appBarHeight = 56.0;
  static const double borderRadius = 12.0;
  static const double defaultPadding = 16.0;

  // Validation
  static const int minPasswordLength = 8;
  static const int minUsernameLength = 1;

  // File upload
  static const int maxAvatarSizeBytes = 5 * 1024 * 1024; // 5 MB
}

class AppStrings {
  // Auth
  static const String register = 'Зарегистрироваться';
  static const String login = 'Войти';
  static const String logout = 'Выход';
  static const String email = 'Email';
  static const String username = 'Имя пользователя';
  static const String password = 'Пароль';
  static const String confirmPassword = 'Подтвердить пароль';
  static const String alreadyHaveAccount = 'Уже есть аккаунт?';
  static const String dontHaveAccount = 'Нет аккаунта?';
  static const String invalidEmail = 'Неверный формат email';
  static const String passwordTooShort =
      'Пароль должен быть минимум 8 символов';
  static const String usernameTooShort =
      'Имя пользователя не может быть пустым';
  static const String invalidCredentials = 'Неверный email или пароль';
  static const String serverError = 'Ошибка сервера. Попробуйте позже';
  static const String networkError =
      'Ошибка сети. Проверьте интернет соединение';

  // Map
  static const String myLocation = 'Моя локация';
  static const String unlockedPoints = 'Открытые точки';
  static const String lockedPoints = 'Закрытые точки';
  static const String checkLocation = 'Проверить локацию';
  static const String approaching = 'Подходите ближе!';
  static const String unlocked = 'Открыто!';

  // Profile
  static const String myProfile = 'Мой профиль';
  static const String level = 'Уровень';
  static const String experience = 'Опыт';
  static const String achievements = 'Достижения';
  static const String openedPoints = 'Открытые точки';
  static const String editProfile = 'Редактировать профиль';
  static const String uploadAvatar = 'Загрузить аватар';
  static const String saveChanges = 'Сохранить изменения';
  static const String currentPassword = 'Текущий пароль';
  static const String newPassword = 'Новый пароль';

  // Leaderboard
  static const String leaderboard = 'Лидерборд';
  static const String byExperience = 'По опыту';
  static const String byPoints = 'По точкам';
  static const String byAchievements = 'По достижениям';
  static const String rank = 'Место';
  static const String score = 'Очки';

  // Messages
  static const String messages = 'Сообщения';
  static const String writeMessage = 'Напишите сообщение...';
  static const String send = 'Отправить';
  static const String delete = 'Удалить';
  static const String deleteMessage = 'Удалить сообщение?';
  static const String cancel = 'Отмена';

  // General
  static const String loading = 'Загрузка...';
  static const String error = 'Ошибка';
  static const String retry = 'Повторить';
  static const String noData = 'Нет данных';
  static const String close = 'Закрыть';
}
