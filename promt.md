# Промт для создания мобильного приложения Nomad GIS

## Задача

Разработать полнофункциональное Flutter мобильное приложение для игры **Nomad GIS** - геолокационной игры с открытием точек интереса, достижениями, сообщениями и лидербордами.

## Обязательные требования

### 1. Использование библиотеки

- **Обязательно использовать:** `nomad_gis_lib` (Dart библиотека для работы с API)
- **Импорт:** `import 'package:nomad_gis_lib/nomad_gis_lib.dart';`
- **Инициализация клиента:** 
  ```dart
  final apiClient = NomadApiClient(
    baseUrl: 'https://api.yourdomain.com', // Заменить на реальный URL
  );
  ```

### 2. Экраны приложения

#### **А. Экран входа/регистрации (Auth Flow)**

**Требуемые поля и функции:**

1. **Экран регистрации:**
   - Поле Email (валидация email формата)
   - Поле Имя пользователя (мин. 1 символ)
   - Поле Пароль (мин. 8 символов, показ/скрытие пароля)
   - Кнопка "Зарегистрироваться"
   - Ссылка на экран входа ("Уже есть аккаунт?")
   - Обработка ошибок валидации (ValidationException)
   - Загрузочный индикатор во время запроса
   - Успешная регистрация → сохранение токенов → переход на экран карты

2. **Экран входа:**
   - Поле Email/Имя пользователя (можно использовать одно поле для обоих)
   - Поле Пароль (показ/скрытие пароля)
   - Кнопка "Войти"
   - Ссылка на регистрацию ("Нет аккаунта?")
   - Обработка UnauthorizedException (неверные учетные данные)
   - Сохранение токенов в `SharedPreferences` для восстановления сессии
   - При ошибке показывать понятные сообщения

3. **Восстановление сессии:**
   - При запуске приложения проверить наличие сохраненных токенов
   - Если есть - попытаться загрузить профиль пользователя
   - Если профиль загружен успешно - перейти на экран карты
   - Если токены невалидны (UnauthorizedException) - перейти на экран входа

**Используемые методы библиотеки:**
- `auth.register(RegisterRequest)`
- `auth.login(LoginRequest)`
- `profile.getMe()`
- Управление токенами: `setTokens()`, `getAccessToken()`, `clearTokens()`

---

#### **Б. Экран карты (Main Game Screen)**

**Требуемые компоненты:**

1. **Карта с Google Maps / Yandex Maps:**
   - Отображение всех точек карты (MapPointRequest)
   - Текущая позиция пользователя (требуется GPS)
   - Визуальное обозначение:
     - Открытых точек (другой цвет/иконка)
     - Закрытых точек (другой цвет/иконка)
     - Зон разблокировки (радиус в метрах)
   - При нажатии на точку → переход на детальный экран точки

2. **Панель профиля (нижняя часть или сайдбар):**
   - Аватар пользователя
   - Имя пользователя
   - Текущий уровень и опыт
   - Прогресс-бар для следующего уровня
   - Кнопка "Мой профиль" → перейти на экран профиля
   - Кнопка "Лидерборды" → перейти на экран лидербордов

3. **Автоматическая проверка локации:**
   - Каждые 5-10 секунд вызывать `game.checkLocation(latitude, longitude)`
   - При разблокировке точки:
     - Показать уведомление (Toast/Snackbar)
     - Обновить визуализацию карты
     - Увеличить опыт пользователя
   - При получении достижения:
     - Показать модальное окно с поздравлением
     - Показать награду (опыт)

4. **Обработка ошибок:**
   - Если нет GPS сигнала → показать сообщение
   - Если API недоступна → показать снэкбар с ошибкой и кнопкой повтора
   - При 401 (токен истек) → обновление должно произойти автоматически, если не удалось → перейти на экран входа

**Используемые методы библиотеки:**
- `mapPoints.getMapPoints()` - загрузка списка всех точек
- `game.checkLocation(latitude, longitude)` - проверка локации

**Требуемые пермиссии Android/iOS:**
- Доступ к GPS
- Доступ в интернет

---

#### **В. Экран детали точки карты (Point Detail Screen)**

**Требуемые компоненты:**

1. **Информация о точке:**
   - Название точки
   - Описание
   - Координаты (широта, долгота)
   - Радиус разблокировки
   - Статус (открыто/закрыто)
   - Дата создания
   - Расстояние до точки (вычислить из текущей позиции)

2. **Карта с одной точкой:**
   - Показать точку и текущую позицию пользователя
   - Показать зону разблокировки (круг на карте)
   - Показать расстояние до точки

3. **Кнопка "Проверить локацию":**
   - Явный запрос проверки локации (в дополнение к автоматической)
   - Если точка разблокирована → показать сообщение
   - Если не в зоне → показать сообщение "Подойдите ближе"

4. **Секция сообщений:**
   - Список всех сообщений на этой точке
   - Для каждого сообщения показать:
     - Автора (имя пользователя)
     - Текст сообщения
     - Дату/время
     - Количество лайков
     - Кнопка лайка (если авторизован)
     - Кнопка удаления (если автор сообщения)
   - Инпут для написания нового сообщения (только для авторизованных)
   - Кнопка "Отправить сообщение"

5. **Скроллируемый лейаут:**
   - Сверху информация о точке и карта
   - Ниже секция сообщений
   - Возможность прокрутить, чтобы увидеть все сообщения

**Используемые методы библиотеки:**
- `mapPoints.getMapPointById(String id)`
- `messages.getMessagesByPoint(String pointId)`
- `messages.createMessage(mapPointId, content)`
- `messages.deleteMessage(messageId)`
- `messages.toggleLike(messageId)`

---

#### **Г. Экран профиля пользователя (Profile Screen)**

**Требуемые компоненты:**

1. **Информация профиля:**
   - Аватар пользователя (большой размер)
     - Кнопка для загрузки нового аватара (только для владельца профиля)
   - Имя пользователя
   - Email
   - Уровень
   - Общий опыт
   - Время регистрации

2. **Статистика:**
   - Количество открытых точек
   - Количество достижений
   - Прогресс (визуальные полосы)

3. **Открытые точки:**
   - Список всех открытых пользователем точек карты
   - Для каждой точки:
     - Название
     - Дата открытия
     - Клик для перехода на детальный экран точки

4. **Достижения:**
   - Список всех достижений пользователя
   - Визуальное различие между открытыми и закрытыми
   - Для каждого достижения показать:
     - Иконка (badgeImageUrl)
     - Название
     - Описание
     - Статус (✓ открыто / ✗ закрыто)
     - Награда (опыт)

5. **Кнопка редактирования профиля:**
   - Переход на экран редактирования (если свой профиль)
   - Поля: Имя пользователя, текущий пароль, новый пароль
   - Кнопка сохранения

6. **Кнопка выхода (Logout):**
   - Только если это свой профиль
   - Подтверждение выхода
   - Очистка токенов
   - Переход на экран входа

**Используемые методы библиотеки:**
- `profile.getMe()` - текущий профиль
- `profile.getMyPoints()` - открытые точки
- `profile.getMyAchievements()` - достижения
- `profile.updateProfile(...)` - обновление профиля
- `profile.uploadAvatar(fileBytes)` - загрузка аватара

---

#### **Д. Экран лидербордов (Leaderboard Screen)**

**Требуемые компоненты:**

1. **Три таба с лидербордами:**
   - Tab 1: "По опыту" (Experience)
   - Tab 2: "По открытым точкам" (Points)
   - Tab 3: "По достижениям" (Achievements)

2. **Для каждого лидерборда:**
   - Список ТОП-10 игроков
   - Для каждого игрока показать:
     - Позиция (rank) 1-10
     - Аватар
     - Имя пользователя
     - Уровень
     - Показатель (опыт/точки/ачивки)
     - Визуальное выделение для первых трех мест (золото/серебро/бронза)
   - Возможность нажать на игрока для перехода на его профиль

3. **Обновление:**
   - Кнопка "Обновить" для перезагрузки лидербордов
   - Индикатор загрузки

**Используемые методы библиотеки:**
- `leaderboard.getExperienceLeaderboard()`
- `leaderboard.getPointsLeaderboard()`
- `leaderboard.getAchievementsLeaderboard()`

---

#### **Е. Экран достижений (Achievements Screen)**

**Требуемые компоненты:**

1. **Список всех достижений:**
   - Grid или список всех ачивок
   - Для каждой ачивки показать:
     - Иконка (badgeImageUrl) - серая если не открыто, цветная если открыто
     - Название
     - Описание
     - Награда (опыт)
     - Статус (✓/✗)

2. **Фильтры (опционально):**
   - Кнопки: "Все", "Открытые", "Закрытые"

3. **Прогресс:**
   - Показать процент открытых достижений
   - Показать опыт, полученный от достижений

**Используемые методы библиотеки:**
- `achievements.getAchievements()` - все ачивки
- `profile.getMyAchievements()` - открытые ачивки пользователя

---

### 3. Архитектура приложения

**Рекомендуемая структура:**

```
lib/
├── main.dart
├── config/
│   ├── api_config.dart          # Конфигурация API клиента
│   └── routes.dart              # Маршруты приложения
├── providers/
│   ├── api_provider.dart        # Provider для API клиента
│   ├── auth_provider.dart       # Provider для аутентификации
│   ├── map_provider.dart        # Provider для карты
│   ├── profile_provider.dart    # Provider для профиля
│   └── leaderboard_provider.dart # Provider для лидербордов
├── models/
│   ├── app_user.dart            # Локальная модель пользователя
│   └── ui_models.dart           # UI-специфичные модели
├── screens/
│   ├── auth/
│   │   ├── login_screen.dart
│   │   ├── register_screen.dart
│   │   └── splash_screen.dart
│   ├── map/
│   │   ├── map_screen.dart
│   │   └── point_detail_screen.dart
│   ├── profile/
│   │   ├── profile_screen.dart
│   │   └── edit_profile_screen.dart
│   ├── leaderboard/
│   │   └── leaderboard_screen.dart
│   ├── achievements/
│   │   └── achievements_screen.dart
│   └── error/
│       └── error_screen.dart
├── widgets/
│   ├── common/
│   │   ├── loading_indicator.dart
│   │   ├── error_widget.dart
│   │   └── custom_app_bar.dart
│   ├── map/
│   │   └── map_widget.dart
│   ├── messages/
│   │   ├── message_item.dart
│   │   └── message_input.dart
│   └── profile/
│       ├── profile_header.dart
│       └── stats_widget.dart
├── utils/
│   ├── constants.dart           # Константы приложения
│   ├── error_handler.dart       # Обработка ошибок API
│   ├── location_service.dart    # Работа с GPS
│   ├── storage_service.dart     # Локальное хранилище (SharedPreferences)
│   └── validators.dart          # Валидаторы форм
├── services/
│   ├── token_storage_service.dart # Сохранение токенов
│   └── notification_service.dart  # Уведомления (Toast/Snackbar)
└── theme/
    ├── app_theme.dart           # Тема приложения
    └── colors.dart              # Цвета

```

**State Management:**
- **Рекомендуется:** Riverpod или Provider (для простоты использования)
- Можно использовать: BLoC, GetX или другие решения
- **Требуется:** Правильное управление состоянием для:
  - Аутентификации
  - Данных карты
  - Профиля пользователя
  - Загрузочных состояний
  - Ошибок

---

### 4. Обработка ошибок

**Все API вызовы должны обрабатывать:**

```dart
try {
  // API вызов
  final result = await apiClient.someService.someMethod();
} on UnauthorizedException catch (e) {
  // Токены невалидны - перейти на экран входа
  // Библиотека должна автоматически обновить токены
  // Если не удалось - показать сообщение и экран входа
} on ValidationException catch (e) {
  // Ошибка валидации - показать сообщение об ошибке пользователю
  showErrorDialog('${e.message}');
} on ApiException catch (e) {
  if (e.statusCode == 404) {
    showErrorSnackBar('Ресурс не найден');
  } else if (e.statusCode == 500) {
    showErrorSnackBar('Ошибка сервера. Попробуйте позже');
  } else {
    showErrorSnackBar('${e.message}');
  }
}
```

**Пользовательские сообщения об ошибках:**
- ✅ "Неверный email или пароль" - вместо "Unauthorized"
- ✅ "Интернет соединение отсутствует" - для сетевых ошибок
- ✅ "Сервер недоступен. Попробуйте позже" - для 500 ошибок
- ❌ Не показывать технические сообщения вроде "SocketException"

---

### 5. Функциональные требования

#### **Аутентификация:**
- ✅ Регистрация нового пользователя
- ✅ Вход в существующий аккаунт
- ✅ Сохранение токенов в SharedPreferences
- ✅ Восстановление сессии при запуске приложения
- ✅ Выход из аккаунта (logout)
- ✅ Обновление токенов при истечении (должно быть автоматическое)

#### **Игровые механики:**
- ✅ Отображение карты с точками интереса
- ✅ Получение текущей локации (GPS)
- ✅ Проверка локации каждые 5-10 секунд
- ✅ Разблокировка точек при подходе
- ✅ Получение достижений при разблокировке точек
- ✅ Увеличение опыта при разблокировке

#### **Профиль:**
- ✅ Просмотр профиля
- ✅ Редактирование профиля (имя, пароль)
- ✅ Загрузка аватара
- ✅ Просмотр открытых точек
- ✅ Просмотр достижений

#### **Коммуникация:**
- ✅ Просмотр сообщений на точке
- ✅ Написание сообщений на точке
- ✅ Удаление собственных сообщений
- ✅ Лайки на сообщения

#### **Лидерборды:**
- ✅ Просмотр ТОП-10 по опыту
- ✅ Просмотр ТОП-10 по открытым точкам
- ✅ Просмотр ТОП-10 по достижениям
- ✅ Переход на профиль игрока из лидербордов

#### **Достижения:**
- ✅ Просмотр всех достижений в игре
- ✅ Просмотр достижений пользователя
- ✅ Визуальное различие между открытыми и закрытыми

---

### 6. UI/UX требования

#### **Дизайн:**
- Современный Material Design или Cupertino (iOS style)
- Темная тема приложения (рекомендуется для игры)
- Адаптивный дизайн (работает на телефонах разных размеров)
- Плавные переходы и анимации

#### **Юзабилити:**
- Интуитивная навигация
- Быстрая загрузка экранов
- Оптимизация батареи при использовании GPS
- Оффлайн-функционал где возможно (кэширование)

#### **Индикаторы состояния:**
- Загрузочные индикаторы для длительных операций
- Сообщения об ошибках в Snackbar или Dialog
- Пустые состояния (Empty State) когда нет данных
- Состояние обновления для лидербордов

---

### 7. Требования к безопасности

#### **Работа с токенами:**
- ✅ Сохранять токены в SharedPreferences (или более безопасное хранилище)
- ✅ Передавать токены в заголовке Authorization: Bearer {token}
- ✅ Очищать токены при выходе из приложения
- ✅ Не выводить токены в логи
- ✅ Обновлять токены автоматически при истечении

#### **Валидация входных данных:**
- ✅ Валидировать email перед отправкой
- ✅ Валидировать пароль (минимум 8 символов)
- ✅ Валидировать имя пользователя
- ✅ Ограничивать размер файлов (макс 5 МБ для аватара)

#### **Обработка ошибок:**
- ✅ Не показывать деталей ошибок 500
- ✅ Не выводить токены в сообщениях об ошибках
- ✅ Правильно обрабатывать 401 для пересоздания сессии

---

### 8. Тестирование

**Рекомендуется:**
- Unit тесты для сервисов (location service, storage service)
- Widget тесты для критичных экранов (login, map)
- Integration тесты для основных пользовательских сценариев

**Основные сценарии для тестирования:**
1. Регистрация → Вход → Просмотр карты
2. Проверка локации → Разблокировка точки → Получение ачивки
3. Написание сообщения → Лайк → Удаление
4. Обновление профиля → Загрузка аватара
5. Просмотр лидербордов
6. Выход из приложения

---

### 9. Дополнительные возможности (опционально)

- Пушные уведомления при разблокировке точек
- Оффлайн кэширование карты и точек
- История посещений с датами
- Социальные функции (добавление друзей, их отслеживание)
- Фильтры на карте (по типам точек)
- Аналитика (отслеживание использования)
- Темная/светлая тема
- Поддержка нескольких языков

---

## Инструкции для разработки

### Шаг 1: Подготовка проекта
```bash
flutter create nomad_gis_app
cd nomad_gis_app
flutter pub add nomad_gis_lib        # Добавить библиотеку
flutter pub add google_maps_flutter  # Для карты (или яндекс)
flutter pub add geolocator          # Для GPS
flutter pub add provider            # Для state management (или riverpod)
flutter pub add shared_preferences  # Для сохранения токенов
flutter pub add image_picker        # Для выбора аватара
flutter pub add intl                # Для форматирования дат
```

### Шаг 2: Конфигурация
- Установить API URL в конфиге
- Настроить Google Maps / Yandex Maps ключи
- Настроить пермиссии для GPS в AndroidManifest.xml и Info.plist

### Шаг 3: Реализация слоев
1. Слой сервисов (Storage, Location, Notifications)
2. Слой Providers/BLoC (Управление состоянием)
3. Слой экранов (UI)
4. Слой виджетов (Переиспользуемые компоненты)

### Шаг 4: Тестирование
- Тестировать каждый экран
- Проверить обработку ошибок
- Проверить работу с сетью

---

## Примеры кода для использования библиотеки

### Инициализация API клиента

```dart
// services/api_service.dart
import 'package:nomad_gis_lib/nomad_gis_lib.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  
  late NomadApiClient _client;
  
  factory ApiService() {
    return _instance;
  }
  
  ApiService._internal() {
    _client = NomadApiClient(
      baseUrl: 'https://api.nomad-gis.com',
    );
  }
  
  NomadApiClient get client => _client;
}
```

### Сохранение токенов

```dart
// services/token_storage_service.dart
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nomad_gis_lib/nomad_gis_lib.dart';

class TokenStorageService {
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userIdKey = 'user_id';
  static const String _deviceIdKey = 'device_id';
  
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
    required String userId,
    required String deviceId,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_accessTokenKey, accessToken);
    await prefs.setString(_refreshTokenKey, refreshToken);
    await prefs.setString(_userIdKey, userId);
    await prefs.setString(_deviceIdKey, deviceId);
  }
  
  Future<Map<String, String>?> loadTokens() async {
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString(_accessTokenKey);
    final refreshToken = prefs.getString(_refreshTokenKey);
    final userId = prefs.getString(_userIdKey);
    final deviceId = prefs.getString(_deviceIdKey);
    
    if (accessToken == null || refreshToken == null || userId == null) {
      return null;
    }
    
    return {
      'accessToken': accessToken,
      'refreshToken': refreshToken,
      'userId': userId,
      'deviceId': deviceId ?? 'unknown',
    };
  }
  
  Future<void> clearTokens() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_accessTokenKey);
    await prefs.remove(_refreshTokenKey);
    await prefs.remove(_userIdKey);
    await prefs.remove(_deviceIdKey);
  }
}
```

### Provider для аутентификации

```dart
// providers/auth_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nomad_gis_lib/nomad_gis_lib.dart';
import '../services/api_service.dart';
import '../services/token_storage_service.dart';

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});

class AuthState {
  final bool isLoading;
  final bool isAuthenticated;
  final UserDto? user;
  final String? error;
  
  AuthState({
    this.isLoading = false,
    this.isAuthenticated = false,
    this.user,
    this.error,
  });
}

class AuthNotifier extends StateNotifier<AuthState> {
  final _apiService = ApiService();
  final _tokenStorage = TokenStorageService();
  
  AuthNotifier() : super(AuthState());
  
  Future<void> register({
    required String email,
    required String username,
    required String password,
    required String deviceId,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final response = await _apiService.client.auth.register(
        RegisterRequest(
          email: email,
          username: username,
          password: password,
          deviceId: deviceId,
        ),
      );
      
      await _tokenStorage.saveTokens(
        accessToken: response.accessToken!,
        refreshToken: response.refreshToken!,
        userId: response.user!.id,
        deviceId: deviceId,
      );
      
      _apiService.client.setTokens(
        accessToken: response.accessToken!,
        refreshToken: response.refreshToken!,
        userId: response.user!.id,
        deviceId: deviceId,
      );
      
      state = state.copyWith(
        isLoading: false,
        isAuthenticated: true,
        user: response.user,
      );
    } on ValidationException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.message,
      );
    } on ApiException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.message,
      );
    }
  }
  
  Future<void> login({
    required String identifier,
    required String password,
    required String deviceId,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final response = await _apiService.client.auth.login(
        LoginRequest(
          identifier: identifier,
          password: password,
          deviceId: deviceId,
        ),
      );
      
      await _tokenStorage.saveTokens(
        accessToken: response.accessToken!,
        refreshToken: response.refreshToken!,
        userId: response.user!.id,
        deviceId: deviceId,
      );
      
      _apiService.client.setTokens(
        accessToken: response.accessToken!,
        refreshToken: response.refreshToken!,
        userId: response.user!.id,
        deviceId: deviceId,
      );
      
      state = state.copyWith(
        isLoading: false,
        isAuthenticated: true,
        user: response.user,
      );
    } on UnauthorizedException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Неверный email/пароль',
      );
    } on ValidationException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.message,
      );
    }
  }
  
  Future<void> restoreSession() async {
    state = state.copyWith(isLoading: true);
    
    try {
      final tokens = await _tokenStorage.loadTokens();
      if (tokens == null) {
        state = state.copyWith(isLoading: false, isAuthenticated: false);
        return;
      }
      
      _apiService.client.setTokens(
        accessToken: tokens['accessToken']!,
        refreshToken: tokens['refreshToken']!,
        userId: tokens['userId']!,
        deviceId: tokens['deviceId']!,
      );
      
      final user = await _apiService.client.profile.getMe();
      
      state = state.copyWith(
        isLoading: false,
        isAuthenticated: true,
        user: user,
      );
    } on UnauthorizedException {
      await _tokenStorage.clearTokens();
      state = state.copyWith(isLoading: false, isAuthenticated: false);
    } on ApiException {
      state = state.copyWith(isLoading: false, isAuthenticated: false);
    }
  }
  
  Future<void> logout() async {
    try {
      await _apiService.client.auth.logout(
        LogoutRequest(
          userId: _apiService.client.getUserId()!,
          refreshToken: _apiService.client.getRefreshToken()!,
          deviceId: _apiService.client.getDeviceId()!,
        ),
      );
    } catch (e) {
      // Игнорируем ошибку при logout
    } finally {
      _apiService.client.clearTokens();
      await _tokenStorage.clearTokens();
      state = AuthState();
    }
  }
}
```

---

## Контрольный список перед сдачей

- [ ] Все экраны разработаны и работают
- [ ] Аутентификация работает (регистрация, вход, выход)
- [ ] Восстановление сессии при запуске работает
- [ ] Карта отображается и обновляется в реальном времени
- [ ] GPS локация работает корректно
- [ ] Проверка локации проходит каждые 5-10 секунд
- [ ] Разблокировка точек происходит правильно
- [ ] Все ошибки обрабатываются с понятными сообщениями
- [ ] Профиль загружается и редактируется
- [ ] Сообщения отображаются, создаются, удаляются, лайкаются
- [ ] Лидерборды отображаются правильно
- [ ] Все токены сохраняются и восстанавливаются
- [ ] Приложение работает оффлайн (кэширует данные)
- [ ] Тесты написаны и проходят
- [ ] Приложение оптимизировано для батареи
- [ ] Все требования безопасности выполнены
- [ ] Дизайн интуитивен и красив
