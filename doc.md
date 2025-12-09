# Nomad GIS API Client Library - Полная документация

## Содержание

1. [Обзор](#обзор)
2. [Инициализация](#инициализация)
3. [Аутентификация](#аутентификация)
4. [Сервисы API](#сервисы-api)
5. [Модели данных](#модели-данных)
6. [Обработка ошибок](#обработка-ошибок)
7. [Примеры использования](#примеры-использования)

---

## Обзор

`nomad_gis_lib` - это Dart-библиотека для работы с API геолокационной игры Nomad GIS. Библиотека предоставляет типобезопасный интерфейс для всех API-операций с автоматическим управлением токенами и обработкой ошибок.

### Основные возможности

- ✅ Аутентификация и управление сессиями
- ✅ Управление достижениями (получение списков)
- ✅ Работа с картографическими точками
- ✅ Система сообщений и комментариев
- ✅ Профили пользователей
- ✅ Лидерборды
- ✅ Игровая механика (проверка локации)
- ✅ Автоматическое обновление токенов при истечении
- ✅ Обработка ошибок с типизированными исключениями

### Что НЕ включено (админские функции удалены)

- ❌ Создание/редактирование/удаление достижений
- ❌ Создание/редактирование/удаление точек на карте
- ❌ Управление пользователями (список, роли, удаление)
- ❌ Статистика приложения (dashboard)
- ❌ Удаление сообщений администратором

---

## Инициализация

### Создание клиента

```dart
import 'package:nomad_gis_lib/nomad_gis_lib.dart';

// Инициализация клиента
final apiClient = NomadApiClient(
  baseUrl: 'https://api.yourdomain.com',
);

// Или с сохраненными токенами из предыдущей сессии
final apiClient = NomadApiClient(
  baseUrl: 'https://api.yourdomain.com',
  initialAccessToken: 'saved_access_token',
  initialRefreshToken: 'saved_refresh_token',
  initialUserId: 'user_id',
  initialDeviceId: 'device_id',
);
```

### Параметры конструктора

| Параметр | Тип | Описание | Обязателен |
|----------|-----|---------|-----------|
| `baseUrl` | `String` | Базовый URL API (например, https://api.example.com) | ✅ Да |
| `initialAccessToken` | `String?` | Сохраненный access токен | ❌ Нет |
| `initialRefreshToken` | `String?` | Сохраненный refresh токен | ❌ Нет |
| `initialUserId` | `String?` | ID пользователя | ❌ Нет |
| `initialDeviceId` | `String?` | ID устройства | ❌ Нет |

### Управление токенами

```dart
// Установить токены после успешного входа
apiClient.setTokens(
  accessToken: authResponse.accessToken!,
  refreshToken: authResponse.refreshToken!,
  userId: authResponse.user!.id,
  deviceId: 'your-device-id',
);

// Получить текущие токены
String? accessToken = apiClient.getAccessToken();
String? refreshToken = apiClient.getRefreshToken();
String? userId = apiClient.getUserId();
String? deviceId = apiClient.getDeviceId();

// Очистить токены (выход из приложения)
apiClient.clearTokens();
```

---

## Аутентификация

Сервис аутентификации доступен через `apiClient.auth`.

### Методы

#### 1. Регистрация нового пользователя

```dart
Future<AuthResponse> register(RegisterRequest request)
```

**Параметры:**
- `email` - Электронная почта (обязательно, валидный email)
- `username` - Имя пользователя (обязательно, минимум 1 символ)
- `password` - Пароль (обязательно, минимум 8 символов)
- `deviceId` - ID устройства (обязательно, для создания refresh токена)

**Возвращает:** `AuthResponse` с `accessToken`, `refreshToken` и информацией о пользователе

**Исключения:**
- `ValidationException` - Ошибка валидации данных (400)
- `ApiException` - Другие ошибки

**Пример:**
```dart
try {
  final response = await apiClient.auth.register(
    RegisterRequest(
      email: 'user@example.com',
      username: 'john_doe',
      password: 'securePassword123',
      deviceId: 'device-unique-id',
    ),
  );
  
  // Сохранить токены
  apiClient.setTokens(
    accessToken: response.accessToken!,
    refreshToken: response.refreshToken!,
    userId: response.user!.id,
    deviceId: 'device-unique-id',
  );
} on ValidationException catch (e) {
  print('Ошибка валидации: ${e.message}');
} on ApiException catch (e) {
  print('Ошибка: ${e.message}');
}
```

#### 2. Вход в аккаунт

```dart
Future<AuthResponse> login(LoginRequest request)
```

**Параметры:**
- `identifier` - Email или имя пользователя (обязательно)
- `password` - Пароль (обязательно)
- `deviceId` - ID устройства (обязательно)

**Возвращает:** `AuthResponse` с токенами и данными пользователя

**Исключения:**
- `UnauthorizedException` - Неверные учетные данные (401)
- `ValidationException` - Ошибка валидации (400)
- `ApiException` - Другие ошибки

**Пример:**
```dart
try {
  final response = await apiClient.auth.login(
    LoginRequest(
      identifier: 'user@example.com', // или 'john_doe'
      password: 'securePassword123',
      deviceId: 'device-unique-id',
    ),
  );
  
  apiClient.setTokens(
    accessToken: response.accessToken!,
    refreshToken: response.refreshToken!,
    userId: response.user!.id,
    deviceId: 'device-unique-id',
  );
} on UnauthorizedException catch (e) {
  print('Неверные учетные данные');
} on ApiException catch (e) {
  print('Ошибка входа: ${e.message}');
}
```

#### 3. Обновление access токена

```dart
Future<AuthResponse> refresh(RefreshTokenRequest request)
```

**Параметры:**
- `userId` - ID пользователя (обязательно)
- `refreshToken` - Refresh токен (обязательно)
- `deviceId` - ID устройства (обязательно)

**Возвращает:** `AuthResponse` с новыми токенами

**Примечание:** Этот метод вызывается **автоматически** при получении 401 ошибки. Ручное вызывание обычно не требуется.

#### 4. Выход из аккаунта

```dart
Future<void> logout(LogoutRequest request)
```

**Параметры:**
- `userId` - ID пользователя (обязательно)
- `refreshToken` - Refresh токен для инвалидации (обязательно)
- `deviceId` - ID устройства (обязательно)

**Пример:**
```dart
try {
  await apiClient.auth.logout(
    LogoutRequest(
      userId: apiClient.getUserId()!,
      refreshToken: apiClient.getRefreshToken()!,
      deviceId: apiClient.getDeviceId()!,
    ),
  );
  
  // Очистить токены локально
  apiClient.clearTokens();
} on ApiException catch (e) {
  print('Ошибка выхода: ${e.message}');
  // Даже при ошибке рекомендуется очистить локальные токены
  apiClient.clearTokens();
}
```

---

## Сервисы API

### 1. Achievements Service

Работа с достижениями. **Требует:** Не требует аутентификации (кроме исключений).

```dart
final achievementsService = apiClient.achievements;
```

#### Методы

##### `getAchievements()`

```dart
Future<List<AchievementResponse>> getAchievements()
```

**Описание:** Получить список всех доступных достижений

**Возвращает:** Список `AchievementResponse`

**Поля `AchievementResponse`:**
- `id` - UUID ачивки
- `code` - Код для внутреннего использования
- `title` - Название ачивки
- `description` - Описание условий получения
- `rewardPoints` - Количество опыта за разблокировку
- `badgeImageUrl` - URL изображения значка

**Пример:**
```dart
try {
  final achievements = await apiClient.achievements.getAchievements();
  for (final achievement in achievements) {
    print('${achievement.title}: ${achievement.description}');
    print('Награда: ${achievement.rewardPoints} опыта');
  }
} on ApiException catch (e) {
  print('Ошибка: ${e.message}');
}
```

##### `getAchievementById(String id)`

```dart
Future<AchievementResponse> getAchievementById(String id)
```

**Параметры:**
- `id` - UUID ачивки

**Возвращает:** `AchievementResponse`

**Пример:**
```dart
final achievement = await apiClient.achievements.getAchievementById(
  '550e8400-e29b-41d4-a716-446655440000',
);
print('${achievement.title}: ${achievement.description}');
```

---

### 2. Map Points Service

Работа с точками на карте.

```dart
final mapPointsService = apiClient.mapPoints;
```

#### Методы

##### `getMapPoints()`

```dart
Future<List<MapPointRequest>> getMapPoints()
```

**Описание:** Получить все точки на карте

**Возвращает:** Список `MapPointRequest`

**Поля `MapPointRequest`:**
- `id` - UUID точки
- `name` - Название точки интереса
- `latitude` - Широта (-90 до 90)
- `longitude` - Долгота (-180 до 180)
- `unlockRadiusMeters` - Радиус разблокировки в метрах
- `description` - Описание точки
- `createdAt` - Дата создания (DateTime)

**Пример:**
```dart
try {
  final points = await apiClient.mapPoints.getMapPoints();
  for (final point in points) {
    print('${point.name} (${point.latitude}, ${point.longitude})');
    print('Радиус разблокировки: ${point.unlockRadiusMeters}м');
  }
} on ApiException catch (e) {
  print('Ошибка: ${e.message}');
}
```

##### `getMapPointById(String id)`

```dart
Future<MapPointRequest> getMapPointById(String id)
```

**Параметры:**
- `id` - UUID точки

**Возвращает:** `MapPointRequest`

**Пример:**
```dart
final point = await apiClient.mapPoints.getMapPointById(
  '550e8400-e29b-41d4-a716-446655440000',
);
print('${point.name}: ${point.description}');
```

---

### 3. Game Service

Игровая механика - проверка локации пользователя.

```dart
final gameService = apiClient.game;
```

**Требует:** Аутентификация (Bearer токен)

#### Методы

##### `checkLocation({required double latitude, required double longitude})`

```dart
Future<Map<String, dynamic>> checkLocation({
  required double latitude,
  required double longitude,
})
```

**Описание:** Проверить текущую локацию пользователя и разблокировать близлежащие точки. Может активировать достижения.

**Параметры:**
- `latitude` - Текущая широта пользователя (обязательно, от -90 до 90)
- `longitude` - Текущая долгота пользователя (обязательно, от -180 до 180)

**Возвращает:** `Map<String, dynamic>` с информацией о разблокированных точках и активированных достижениях

**Исключения:**
- `ValidationException` - Некорректные координаты (400)
- `UnauthorizedException` - Не аутентифицирован (401)
- `ApiException` - Другие ошибки

**Пример:**
```dart
try {
  final result = await apiClient.game.checkLocation(
    latitude: 55.7558,
    longitude: 37.6173,
  );
  
  print('Результат проверки: $result');
  // result может содержать:
  // - unlockedPoints: список разблокированных точек
  // - achievementsUnlocked: список активированных ачивок
  // - experienceGained: количество полученного опыта
} on ValidationException catch (e) {
  print('Ошибка валидации координат: ${e.message}');
} on UnauthorizedException catch (e) {
  print('Требуется вход в аккаунт');
} on ApiException catch (e) {
  print('Ошибка: ${e.message}');
}
```

---

### 4. Messages Service

Система сообщений и комментариев на точках карты.

```dart
final messagesService = apiClient.messages;
```

**Требует:** Аутентификация (Bearer токен)

#### Методы

##### `getMessagesByPoint(String pointId)`

```dart
Future<List<Map<String, dynamic>>> getMessagesByPoint(String pointId)
```

**Описание:** Получить все сообщения на конкретной точке карты

**Параметры:**
- `pointId` - UUID точки карты

**Возвращает:** Список сообщений (Map)

**Структура сообщения:**
```json
{
  "id": "uuid",
  "mapPointId": "uuid",
  "author": "username",
  "authorId": "uuid",
  "content": "Текст сообщения",
  "createdAt": "2023-12-09T10:30:00",
  "likes": 5,
  "isLikedByMe": false
}
```

**Пример:**
```dart
try {
  final messages = await apiClient.messages.getMessagesByPoint(
    'point-uuid',
  );
  
  for (final message in messages) {
    print('${message['author']}: ${message['content']}');
    print('Лайков: ${message['likes']}');
  }
} on UnauthorizedException catch (e) {
  print('Требуется вход в аккаунт');
}
```

##### `createMessage({required String mapPointId, String? content})`

```dart
Future<Map<String, dynamic>> createMessage({
  required String mapPointId,
  String? content,
})
```

**Описание:** Создать новое сообщение на точке карты

**Параметры:**
- `mapPointId` - UUID точки (обязательно)
- `content` - Текст сообщения (необязательно)

**Возвращает:** Созданное сообщение (Map)

**Исключения:**
- `ValidationException` - Ошибка валидации (400)
- `UnauthorizedException` - Не аутентифицирован (401)

**Пример:**
```dart
try {
  final message = await apiClient.messages.createMessage(
    mapPointId: 'point-uuid',
    content: 'Отличное место! Спасибо за находку!',
  );
  
  print('Сообщение создано: ${message['id']}');
} on ValidationException catch (e) {
  print('Ошибка: ${e.message}');
}
```

##### `deleteMessage(String messageId)`

```dart
Future<void> deleteMessage(String messageId)
```

**Описание:** Удалить собственное сообщение

**Параметры:**
- `messageId` - UUID сообщения

**Исключения:**
- `UnauthorizedException` - Не аутентифицирован (401)
- `ApiException` - Нет прав на удаление (403) или сообщение не найдено (404)

**Пример:**
```dart
try {
  await apiClient.messages.deleteMessage('message-uuid');
  print('Сообщение удалено');
} on ApiException catch (e) {
  if (e.statusCode == 403) {
    print('Вы не можете удалить это сообщение');
  } else if (e.statusCode == 404) {
    print('Сообщение не найдено');
  } else {
    print('Ошибка: ${e.message}');
  }
}
```

##### `toggleLike(String messageId)`

```dart
Future<Map<String, dynamic>> toggleLike(String messageId)
```

**Описание:** Поставить или убрать лайк на сообщение

**Параметры:**
- `messageId` - UUID сообщения

**Возвращает:** Обновленное сообщение с новым количеством лайков

**Пример:**
```dart
try {
  final updatedMessage = await apiClient.messages.toggleLike('message-uuid');
  print('Лайков теперь: ${updatedMessage['likes']}');
} on ApiException catch (e) {
  print('Ошибка: ${e.message}');
}
```

---

### 5. Profile Service

Управление профилем текущего пользователя.

```dart
final profileService = apiClient.profile;
```

**Требует:** Аутентификация (Bearer токен)

#### Методы

##### `getMe()`

```dart
Future<UserDto> getMe()
```

**Описание:** Получить информацию о текущем профиле пользователя

**Возвращает:** `UserDto`

**Поля `UserDto`:**
- `id` - UUID пользователя
- `email` - Email
- `username` - Имя пользователя
- `experience` - Общее количество опыта
- `level` - Текущий уровень
- `avatarUrl` - URL аватара (может быть null)

**Пример:**
```dart
try {
  final user = await apiClient.profile.getMe();
  print('Пользователь: ${user.username}');
  print('Уровень: ${user.level}');
  print('Опыт: ${user.experience}');
  print('Email: ${user.email}');
} on UnauthorizedException catch (e) {
  print('Требуется вход в аккаунт');
}
```

##### `updateProfile({String? username, String? currentPassword, String? newPassword, List<int>? avatarFile})`

```dart
Future<void> updateProfile({
  String? username,
  String? currentPassword,
  String? newPassword,
  List<int>? avatarFile,
})
```

**Описание:** Обновить информацию профиля пользователя

**Параметры:**
- `username` - Новое имя пользователя (необязательно)
- `currentPassword` - Текущий пароль для проверки (требуется если меняется пароль)
- `newPassword` - Новый пароль (необязательно, минимум 8 символов)
- `avatarFile` - Байты изображения аватара (необязательно)

**Исключения:**
- `ValidationException` - Ошибка валидации (400)
- `UnauthorizedException` - Не аутентифицирован (401)

**Пример:**
```dart
try {
  await apiClient.profile.updateProfile(
    username: 'new_username',
    currentPassword: 'oldPassword123',
    newPassword: 'newPassword123',
  );
  print('Профиль обновлен');
} on ValidationException catch (e) {
  print('Ошибка: ${e.message}');
}
```

##### `getMyPoints()`

```dart
Future<List<MapPointRequest>> getMyPoints()
```

**Описание:** Получить список всех открытых пользователем точек карты

**Возвращает:** Список `MapPointRequest`

**Пример:**
```dart
try {
  final points = await apiClient.profile.getMyPoints();
  print('Открыто точек: ${points.length}');
  for (final point in points) {
    print('- ${point.name}');
  }
} on UnauthorizedException catch (e) {
  print('Требуется вход в аккаунт');
}
```

##### `getMyAchievements()`

```dart
Future<List<AchievementResponse>> getMyAchievements()
```

**Описание:** Получить список всех достижений пользователя (активированных и неактивированных)

**Возвращает:** Список `AchievementResponse`

**Примечание:** Ответ содержит полную информацию о достижениях, включая информацию об активации

**Пример:**
```dart
try {
  final achievements = await apiClient.profile.getMyAchievements();
  print('Всего достижений: ${achievements.length}');
  for (final achievement in achievements) {
    print('- ${achievement.title}');
  }
} on UnauthorizedException catch (e) {
  print('Требуется вход в аккаунт');
}
```

##### `uploadAvatar(List<int> file)`

```dart
Future<void> uploadAvatar(List<int> file)
```

**Описание:** Загрузить новый аватар пользователя

**Параметры:**
- `file` - Байты изображения (обязательно)

**Ограничения:**
- Максимальный размер: 5 МБ
- Поддерживаемые форматы: jpg, png, gif

**Исключения:**
- `ValidationException` - Ошибка валидации (400)
- `UnauthorizedException` - Не аутентифицирован (401)
- `ApiException` - Файл слишком большой (413)

**Пример:**
```dart
try {
  final imageBytes = await File('avatar.jpg').readAsBytes();
  await apiClient.profile.uploadAvatar(imageBytes);
  print('Аватар загружен');
} on ApiException catch (e) {
  if (e.statusCode == 413) {
    print('Файл слишком большой (макс 5 МБ)');
  } else {
    print('Ошибка: ${e.message}');
  }
}
```

---

### 6. Leaderboard Service

Получение лидербордов (рейтингов).

```dart
final leaderboardService = apiClient.leaderboard;
```

**Требует:** Не требует аутентификации

#### Методы

##### `getExperienceLeaderboard()`

```dart
Future<List<LeaderboardEntryDto>> getExperienceLeaderboard()
```

**Описание:** Получить ТОП-10 пользователей по количеству опыта

**Возвращает:** Список `LeaderboardEntryDto` (максимум 10 записей)

**Поля `LeaderboardEntryDto`:**
- `rank` - Позиция в рейтинге (1-10)
- `userId` - UUID пользователя
- `username` - Имя пользователя
- `avatarUrl` - URL аватара
- `level` - Уровень пользователя
- `score` - Количество опыта

**Пример:**
```dart
try {
  final leaderboard = await apiClient.leaderboard.getExperienceLeaderboard();
  for (final entry in leaderboard) {
    print('${entry.rank}. ${entry.username} - ${entry.score} опыта (уровень ${entry.level})');
  }
} on ApiException catch (e) {
  print('Ошибка: ${e.message}');
}
```

##### `getPointsLeaderboard()`

```dart
Future<List<LeaderboardEntryDto>> getPointsLeaderboard()
```

**Описание:** Получить ТОП-10 пользователей по количеству открытых точек

**Возвращает:** Список `LeaderboardEntryDto` (максимум 10 записей)

**Поле `score` содержит:** Количество открытых точек

**Пример:**
```dart
final leaderboard = await apiClient.leaderboard.getPointsLeaderboard();
for (final entry in leaderboard) {
  print('${entry.rank}. ${entry.username} - ${entry.score} открытых точек');
}
```

##### `getAchievementsLeaderboard()`

```dart
Future<List<LeaderboardEntryDto>> getAchievementsLeaderboard()
```

**Описание:** Получить ТОП-10 пользователей по количеству полученных достижений

**Возвращает:** Список `LeaderboardEntryDto` (максимум 10 записей)

**Поле `score` содержит:** Количество полученных достижений

**Пример:**
```dart
final leaderboard = await apiClient.leaderboard.getAchievementsLeaderboard();
for (final entry in leaderboard) {
  print('${entry.rank}. ${entry.username} - ${entry.score} достижений');
}
```

---

### 7. Users Service

**⚠️ ВНИМАНИЕ:** Данный сервис содержит только заглушку (TODO). Админские методы удалены из библиотеки.

```dart
final usersService = apiClient.users;
```

---

### 8. Dashboard Service

**⚠️ ВНИМАНИЕ:** Данный сервис содержит только заглушку (TODO). Этот функционал доступен только администраторам и удален из библиотеки.

```dart
final dashboardService = apiClient.dashboard;
```

---

## Модели данных

### AuthResponse

Ответ при успешной аутентификации.

```dart
class AuthResponse {
  final String? accessToken;      // JWT токен доступа
  final String? refreshToken;     // Токен обновления
  final UserDto? user;            // Информация о пользователе
}
```

### UserDto

Информация о пользователе.

```dart
class UserDto {
  final String id;                // UUID пользователя
  final String? email;            // Email
  final String? username;         // Имя пользователя
  final int experience;           // Количество опыта
  final int level;                // Уровень
  final String? avatarUrl;        // URL аватара
}
```

### AchievementResponse

Информация об достижении.

```dart
class AchievementResponse {
  final String id;                    // UUID
  final String? code;                 // Внутренний код
  final String? title;                // Название
  final String? description;          // Описание
  final int rewardPoints;             // Опыт за разблокировку
  final String? badgeImageUrl;        // URL значка
}
```

### MapPointRequest

Информация о точке на карте.

```dart
class MapPointRequest {
  final String id;                    // UUID
  final String? name;                 // Название
  final double latitude;              // Широта
  final double longitude;             // Долгота
  final double unlockRadiusMeters;   // Радиус разблокировки
  final String? description;          // Описание
  final DateTime createdAt;           // Дата создания
}
```

### LeaderboardEntryDto

Запись в лидербордe.

```dart
class LeaderboardEntryDto {
  final int rank;                 // Позиция (1-10)
  final String userId;            // UUID пользователя
  final String? username;         // Имя пользователя
  final String? avatarUrl;        // URL аватара
  final int level;                // Уровень
  final int score;                // Показатель (опыт/точки/ачивки)
}
```

### Запросы

#### RegisterRequest

```dart
class RegisterRequest {
  final String email;             // Email (обязательно)
  final String password;          // Пароль, минимум 8 символов
  final String username;          // Имя пользователя
  final String deviceId;          // ID устройства
}
```

#### LoginRequest

```dart
class LoginRequest {
  final String identifier;        // Email или username
  final String? deviceId;         // ID устройства
  final String? password;         // Пароль
}
```

#### RefreshTokenRequest

```dart
class RefreshTokenRequest {
  final String userId;            // UUID пользователя
  final String? refreshToken;     // Refresh токен
  final String? deviceId;         // ID устройства
}
```

#### LogoutRequest

```dart
class LogoutRequest {
  final String userId;            // UUID пользователя
  final String? refreshToken;     // Refresh токен
  final String? deviceId;         // ID устройства
}
```

#### CheckLocationRequest

```dart
class CheckLocationRequest {
  final double latitude;          // Широта (-90 до 90)
  final double longitude;         // Долгота (-180 до 180)
}
```

#### MessageRequest

```dart
class MessageRequest {
  final String mapPointId;        // UUID точки
  final String? content;          // Текст сообщения
}
```

---

## Обработка ошибок

### Иерархия исключений

```
Exception
  └── ApiException
      ├── UnauthorizedException (401)
      └── ValidationException (400)
```

### ApiException (Базовый класс)

```dart
try {
  // API операция
} on ApiException catch (e) {
  print('Сообщение: ${e.message}');
  print('HTTP код: ${e.statusCode}');
  print('Оригинальная ошибка: ${e.originalException}');
}
```

**Свойства:**
- `message` - Описание ошибки
- `statusCode` - HTTP статус код (может быть null)
- `originalException` - Исходное исключение

### UnauthorizedException (401)

Выбрасывается при проблемах с аутентификацией:

```dart
try {
  await apiClient.profile.getMe();
} on UnauthorizedException catch (e) {
  // Токены невалидны или истекли
  // Требуется переход на экран входа
  apiClient.clearTokens();
  navigateToLogin();
}
```

### ValidationException (400)

Выбрасывается при ошибках валидации входных данных:

```dart
try {
  await apiClient.auth.register(
    RegisterRequest(
      email: 'invalid-email',  // Неверный формат
      username: 'john',
      password: 'pass123',     // Слишком короткий пароль
      deviceId: 'device-id',
    ),
  );
} on ValidationException catch (e) {
  // Показать ошибку пользователю
  showErrorDialog('Ошибка валидации: ${e.message}');
}
```

### Общая обработка ошибок

```dart
try {
  // Любая API операция
  final result = await apiClient.someService.someMethod();
} on UnauthorizedException catch (e) {
  print('Требуется аутентификация');
  apiClient.clearTokens();
} on ValidationException catch (e) {
  print('Ошибка валидации: ${e.message}');
} on ApiException catch (e) {
  if (e.statusCode == 404) {
    print('Ресурс не найден');
  } else if (e.statusCode == 403) {
    print('Доступ запрещен');
  } else {
    print('Ошибка API: ${e.message}');
  }
}
```

---

## Примеры использования

### Полный цикл: Регистрация → Игра → Профиль

```dart
import 'package:nomad_gis_lib/nomad_gis_lib.dart';

void main() async {
  // 1. Инициализация клиента
  final api = NomadApiClient(
    baseUrl: 'https://api.nomad-gis.com',
  );

  try {
    // 2. Регистрация
    print('=== Регистрация ===');
    final registerResponse = await api.auth.register(
      RegisterRequest(
        email: 'player@example.com',
        username: 'player_123',
        password: 'SecurePassword123!',
        deviceId: 'android-device-uuid',
      ),
    );

    // 3. Сохранить токены
    api.setTokens(
      accessToken: registerResponse.accessToken!,
      refreshToken: registerResponse.refreshToken!,
      userId: registerResponse.user!.id,
      deviceId: 'android-device-uuid',
    );

    print('Новый пользователь создан: ${registerResponse.user!.username}');

    // 4. Получить профиль
    print('\n=== Профиль ===');
    final profile = await api.profile.getMe();
    print('Имя: ${profile.username}');
    print('Уровень: ${profile.level}');
    print('Опыт: ${profile.experience}');

    // 5. Получить карту
    print('\n=== Карта ===');
    final points = await api.mapPoints.getMapPoints();
    print('Всего точек на карте: ${points.length}');
    if (points.isNotEmpty) {
      final firstPoint = points.first;
      print('Первая точка: ${firstPoint.name}');
      print('Координаты: ${firstPoint.latitude}, ${firstPoint.longitude}');
      print('Радиус разблокировки: ${firstPoint.unlockRadiusMeters}м');
    }

    // 6. Проверить локацию
    print('\n=== Проверка локации ===');
    final locationResult = await api.game.checkLocation(
      latitude: 55.7558,
      longitude: 37.6173,
    );
    print('Результат проверки: $locationResult');

    // 7. Получить сообщения на первой точке
    if (points.isNotEmpty) {
      print('\n=== Сообщения ===');
      final messages = await api.messages.getMessagesByPoint(points.first.id);
      print('Сообщений на точке "${points.first.name}": ${messages.length}');
    }

    // 8. Получить лидерборды
    print('\n=== Лидерборды ===');
    final expLeaderboard = await api.leaderboard.getExperienceLeaderboard();
    print('ТОП игроки по опыту:');
    for (final entry in expLeaderboard.take(3)) {
      print('  ${entry.rank}. ${entry.username} - ${entry.score} опыта');
    }

    // 9. Получить достижения
    print('\n=== Достижения ===');
    final achievements = await api.achievements.getAchievements();
    print('Всего достижений в игре: ${achievements.length}');
    
    final myAchievements = await api.profile.getMyAchievements();
    print('Мои достижения: ${myAchievements.length}');

    // 10. Выход
    print('\n=== Выход ===');
    await api.auth.logout(
      LogoutRequest(
        userId: api.getUserId()!,
        refreshToken: api.getRefreshToken()!,
        deviceId: api.getDeviceId()!,
      ),
    );
    api.clearTokens();
    print('Успешно вышли из аккаунта');

  } on ValidationException catch (e) {
    print('Ошибка валидации: ${e.message}');
  } on UnauthorizedException catch (e) {
    print('Ошибка аутентификации: ${e.message}');
  } on ApiException catch (e) {
    print('Ошибка API: ${e.message} (код ${e.statusCode})');
  }
}
```

### Обновление профиля с аватаром

```dart
import 'dart:io';
import 'package:nomad_gis_lib/nomad_gis_lib.dart';

void updateUserProfile(NomadApiClient api) async {
  try {
    // Загрузить изображение аватара
    final avatarFile = File('/path/to/avatar.jpg');
    final avatarBytes = await avatarFile.readAsBytes();

    // Обновить профиль
    await api.profile.updateProfile(
      username: 'new_username_2024',
      currentPassword: 'OldPassword123!',
      newPassword: 'NewPassword123!',
      avatarFile: avatarBytes,
    );

    print('Профиль успешно обновлен');

    // Получить обновленный профиль
    final updatedProfile = await api.profile.getMe();
    print('Новое имя: ${updatedProfile.username}');
    if (updatedProfile.avatarUrl != null) {
      print('Новый аватар: ${updatedProfile.avatarUrl}');
    }
  } on ValidationException catch (e) {
    print('Ошибка валидации: ${e.message}');
  } on ApiException catch (e) {
    print('Ошибка: ${e.message}');
  }
}
```

### Работа с сообщениями

```dart
import 'package:nomad_gis_lib/nomad_gis_lib.dart';

void messagesExample(NomadApiClient api, String pointId) async {
  try {
    // Получить все сообщения на точке
    final messages = await api.messages.getMessagesByPoint(pointId);
    print('Сообщений: ${messages.length}');

    for (final msg in messages) {
      print('${msg['author']}: ${msg['content']}');
      print('  Лайков: ${msg['likes']}');
    }

    // Написать новое сообщение
    await api.messages.createMessage(
      mapPointId: pointId,
      content: 'Отличное место! Большое спасибо за находку! 🎉',
    );
    print('Сообщение отправлено');

    // Обновить список сообщений
    final updatedMessages = await api.messages.getMessagesByPoint(pointId);
    final myMessage = updatedMessages.last;

    // Поставить лайк на свое сообщение
    final likedMessage = await api.messages.toggleLike(myMessage['id']);
    print('Лайков теперь: ${likedMessage['likes']}');

    // Удалить сообщение
    await api.messages.deleteMessage(myMessage['id']);
    print('Сообщение удалено');

  } on ApiException catch (e) {
    print('Ошибка: ${e.message}');
  }
}
```

### Восстановление сессии

```dart
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nomad_gis_lib/nomad_gis_lib.dart';

Future<bool> restoreSession(NomadApiClient api) async {
  final prefs = await SharedPreferences.getInstance();

  final accessToken = prefs.getString('access_token');
  final refreshToken = prefs.getString('refresh_token');
  final userId = prefs.getString('user_id');
  final deviceId = prefs.getString('device_id');

  if (accessToken == null || refreshToken == null || userId == null) {
    return false; // Нет сохраненной сессии
  }

  try {
    // Установить сохраненные токены
    api.setTokens(
      accessToken: accessToken,
      refreshToken: refreshToken,
      userId: userId,
      deviceId: deviceId ?? 'unknown',
    );

    // Проверить валидность токенов
    final profile = await api.profile.getMe();
    print('Сессия восстановлена: ${profile.username}');
    return true;

  } on UnauthorizedException catch (e) {
    print('Сохраненные токены истекли, требуется повторный вход');
    api.clearTokens();
    prefs.clear(); // Очистить сохраненные данные
    return false;
  }
}

Future<void> saveSession(
  NomadApiClient api,
  String deviceId,
) async {
  final prefs = await SharedPreferences.getInstance();

  await prefs.setString('access_token', api.getAccessToken() ?? '');
  await prefs.setString('refresh_token', api.getRefreshToken() ?? '');
  await prefs.setString('user_id', api.getUserId() ?? '');
  await prefs.setString('device_id', deviceId);

  print('Сессия сохранена');
}
```

---

## Автоматическое обновление токенов

Библиотека **автоматически** обновляет токены доступа при получении 401 ошибки. Процесс:

1. **Запрос отклонен с 401** → Клиент сохраняет запрос в очередь
2. **Инициируется обновление токена** → Отправляется запрос refresh с текущим refresh токеном
3. **Получены новые токены** → Токены обновляются в клиенте
4. **Исходный запрос повторяется** → С новыми токенами (только один раз)

**Примечание:** Если обновление токена происходит много раз одновременно, все запросы дождутся первого успешного обновления и повторят запросы.

```dart
try {
  // Если access токен истек, обновление произойдет автоматически
  final profile = await api.profile.getMe();
} on UnauthorizedException catch (e) {
  // Выбросится только если refresh токен также невалиден
  print('Требуется повторная аутентификация');
  api.clearTokens();
}
```

---

## Лучшие практики

### 1. Обработка аутентификации

```dart
// ✅ ПРАВИЛЬНО
try {
  final profile = await api.profile.getMe();
} on UnauthorizedException {
  // Перейти на экран входа
  navigateToLogin();
} on ApiException catch (e) {
  // Показать ошибку
  showError(e.message);
}

// ❌ НЕПРАВИЛЬНО - игнорировать 401
try {
  final profile = await api.profile.getMe();
} catch (e) {
  // Что если это именно 401?
}
```

### 2. Сохранение токенов

```dart
// ✅ ПРАВИЛЬНО - сохранить сразу после входа
final loginResponse = await api.auth.login(request);
api.setTokens(
  accessToken: loginResponse.accessToken!,
  refreshToken: loginResponse.refreshToken!,
  userId: loginResponse.user!.id,
  deviceId: deviceId,
);
await saveTokensToStorage(
  accessToken: loginResponse.accessToken!,
  refreshToken: loginResponse.refreshToken!,
  userId: loginResponse.user!.id,
  deviceId: deviceId,
);

// ❌ НЕПРАВИЛЬНО - потеря токенов при перезагрузке приложения
final loginResponse = await api.auth.login(request);
api.setTokens(...);
// Забыли сохранить в SharedPreferences!
```

### 3. Проверка входа перед защищенными операциями

```dart
// ✅ ПРАВИЛЬНО
void onMapTapped() {
  if (api.getAccessToken() == null) {
    navigateToLogin();
    return;
  }
  checkLocation();
}

// ❌ НЕПРАВИЛЬНО - ждите ошибки API
void onMapTapped() {
  checkLocation(); // Будет ошибка 401 если не вошли
}
```

### 4. Работа с файлами

```dart
// ✅ ПРАВИЛЬНО - проверить размер перед загрузкой
final file = File(imagePath);
final fileSizeInMB = await file.length() / (1024 * 1024);
if (fileSizeInMB > 5) {
  showError('Размер файла должен быть не более 5 МБ');
  return;
}
await api.profile.uploadAvatar(await file.readAsBytes());

// ❌ НЕПРАВИЛЬНО - ждите ошибки 413
await api.profile.uploadAvatar(await hugeFile.readAsBytes());
```

### 5. Обработка сетевых ошибок

```dart
// ✅ ПРАВИЛЬНО - показать пользователю понятное сообщение
try {
  final leaderboard = await api.leaderboard.getExperienceLeaderboard();
} on ApiException catch (e) {
  if (e.statusCode == 500) {
    showError('Ошибка сервера. Попробуйте позже.');
  } else if (e.originalException is SocketException) {
    showError('Нет соединения с интернетом.');
  } else {
    showError('Неудача загрузки. Попробуйте снова.');
  }
}

// ❌ НЕПРАВИЛЬНО - техническое сообщение об ошибке
} catch (e) {
  showError(e.toString()); // "SocketException: No address associated..."
}
```

---

## Версия библиотеки

- **Версия:** 1.0.0
- **Дата документации:** 9 декабря 2025
- **Совместимость:** Dart SDK >= 2.19.0

---

## Что реализовано в библиотеке

### ✅ Полностью реализовано (14 методов)

1. **Auth Service (4 метода)**
   - Register (регистрация)
   - Login (вход)
   - Refresh (обновление токена - автоматическое)
   - Logout (выход)

2. **Achievements Service (2 метода)**
   - Get all achievements
   - Get achievement by ID

3. **Map Points Service (2 метода)**
   - Get all map points
   - Get map point by ID

4. **Messages Service (4 метода)**
   - Get messages by point
   - Create message
   - Delete message
   - Toggle like

5. **Profile Service (5 методов)**
   - Get current profile
   - Update profile
   - Get my unlocked points
   - Get my achievements
   - Upload avatar

6. **Game Service (1 метод)**
   - Check location

7. **Leaderboard Service (3 метода)**
   - Get experience leaderboard
   - Get points leaderboard
   - Get achievements leaderboard

### ❌ Не реализовано (21 метод)

**Все методы ниже удалены по причине того, что они требуют администраторские права:**

1. **Achievements (3 админских)**
   - Create achievement
   - Update achievement
   - Delete achievement

2. **Map Points (3 админских)**
   - Create map point
   - Update map point
   - Delete map point

3. **Messages (1 админский)**
   - Delete message as admin

4. **Dashboard (1 админский)**
   - Get stats

5. **Users (4 админских)**
   - Get all users
   - Get user details
   - Change user role
   - Delete user

6. **Services with stubs (2 stub-сервиса)**
   - Dashboard Service
   - Users Service

---

## Контакты и поддержка

- **API Repository:** https://github.com/SayatYuss/nomad-gis-api
- **Library Repository:** [ваш репозиторий]
- **Версия API:** v1
- **License:** MIT
