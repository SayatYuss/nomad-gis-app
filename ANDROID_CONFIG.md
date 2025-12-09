# Конфигурация Android для приложения Nomad GIS

## 📋 Содержание
- [Разрешения](#разрешения)
- [Конфигурация Gradle](#конфигурация-gradle)
- [Runtime Permissions](#runtime-permissions)
- [Оптимизация](#оптимизация)
- [Сборка и развертывание](#сборка-и-развертывание)

## Разрешения

### AndroidManifest.xml

Файл расположен в `android/app/src/main/AndroidManifest.xml` и содержит все требуемые разрешения:

#### GPS и Локация
```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_BACKGROUND_LOCATION" />
```

#### Интернет
```xml
<uses-permission android:name="android.permission.INTERNET" />
```

#### Хранилище
```xml
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
```

#### Камера (для аватара)
```xml
<uses-permission android:name="android.permission.CAMERA" />
```

#### Сеть
```xml
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
<uses-permission android:name="android.permission.CHANGE_NETWORK_STATE" />
```

## Конфигурация Gradle

### app/build.gradle.kts

Основные настройки сборки находятся в `android/app/build.gradle.kts`:

```kotlin
android {
    namespace = "com.example.nomad_gis_app"
    compileSdk = flutter.compileSdkVersion
    
    defaultConfig {
        applicationId = "com.example.nomad_gis_app"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }
}
```

### Версии SDK

- **compileSdk**: управляется Flutter SDK
- **minSdk**: управляется Flutter SDK (обычно 21+)
- **targetSdk**: управляется Flutter SDK (обычно 33+)

## Runtime Permissions

Приложение использует пакет `geolocator` для автоматического управления runtime разрешениями.

### Поддерживаемые типы разрешений

- **Разрешения при использовании** (`PERMISSION_FINE_LOCATION`)
- **Разрешения всегда** (`PERMISSION_FINE_LOCATION` + фоне)
- **Отказано** (`PERMISSION_DENIED`)

### Код запроса разрешений

```dart
// lib/services/location_service.dart
static Future<bool> requestLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    
    if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
    }
    
    return permission == LocationPermission.whileInUse ||
           permission == LocationPermission.always;
}
```

## Оптимизация

### Параметры локации (constants.dart)

```dart
// Интервал проверки GPS (в секундах)
static const int locationCheckIntervalSeconds = 10;

// Точность определения
LocationAccuracy.high  // Высокая точность (GPS)

// Фильтр расстояния
distanceFilter: 10     // Игнорировать изменения < 10м
```

### Параметры файлов (constants.dart)

```dart
// Максимальный размер аватара (5 МБ)
static const int maxAvatarSizeBytes = 5 * 1024 * 1024;
```

## Сборка и развертывание

### Подготовка к сборке

```bash
# Обновить зависимости Flutter
flutter pub get

# Запустить code generation
flutter pub run build_runner build --delete-conflicting-outputs

# Проверить конфигурацию
flutter analyze
```

### Сборка Debug версии

```bash
# Сборка и запуск на устройстве
flutter run -v

# Сборка без запуска
flutter build apk --debug

# Сборка для конкретного устройства
flutter run -d <device_id> -v
```

### Сборка Release версии

```bash
# Сборка Release APK
flutter build apk --release

# Сборка AAB (для Google Play)
flutter build appbundle --release

# Вывод находится в:
# build/app/outputs/apk/release/app-release.apk
# build/app/outputs/bundle/release/app-release.aab
```

### Подпись приложения

Для подписи Release версии необходим keystore файл:

```bash
# Создание keystore (если его еще нет)
keytool -genkey -v -keystore ~/key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias nomad_gis_key

# Сборка с подписью (для Google Play)
flutter build appbundle --release
```

## Отладка на устройстве

### Включение логирования

```bash
# Просмотр логов в реальном времени
adb logcat | grep flutter

# Поиск конкретной ошибки
adb logcat | grep -i "permission\|location\|gps"
```

### Тестирование GPS на эмуляторе

```bash
# Запуск эмулятора с поддержкой GPS
emulator -avd <avd_name> -noaudio -no-snapshot-load

# Имитация GPS координат
adb emu geo fix 51.1694 71.4491

# Маршрут (несколько точек)
adb emu geo fix 51.1694 71.4491 1000
adb emu geo fix 51.1700 71.4500 1000
```

### Проверка разрешений на устройстве

```bash
# Список все разрешений приложения
adb shell pm list permissions -d

# Проверка конкретного разрешения
adb shell pm dump com.example.nomad_gis_app | grep permission

# Предоставление разрешения вручную (Android 6.0+)
adb shell pm grant com.example.nomad_gis_app android.permission.ACCESS_FINE_LOCATION

# Отзыв разрешения
adb shell pm revoke com.example.nomad_gis_app android.permission.ACCESS_FINE_LOCATION
```

## Проблемы и решения

### Проблема: GPS не работает на эмуляторе
**Решение:**
1. Используйте Google Play System Image вместо AOSP
2. Убедитесь, что GPU включена
3. Используйте `adb emu geo fix` для имитации GPS

### Проблема: Разрешения не запрашиваются
**Решение:**
1. Проверьте версию Android (должна быть 6.0+)
2. Очистите данные приложения: `adb shell pm clear com.example.nomad_gis_app`
3. Переустановите приложение

### Проблема: Высокое потребление батареи
**Решение:**
1. Увеличьте `locationCheckIntervalSeconds` в constants.dart
2. Используйте `LocationAccuracy.medium` для фона
3. Убедитесь, что приложение правильно паузирует GPS при сворачивании

### Проблема: Ошибка "Manifest merger failed"
**Решение:**
1. Обновите Android Gradle Plugin: `classpath 'com.android.tools.build:gradle:8.0.0'`
2. Убедитесь, что все зависимости используют совместимые версии
3. Запустите: `flutter clean` и `flutter pub get`

## Дополнительные ресурсы

- [Android Permissions Documentation](https://developer.android.com/guide/topics/permissions)
- [Google Play App Requirements](https://play.google.com/console/about/policies)
- [Geolocator Plugin Documentation](https://pub.dev/packages/geolocator)
- [Flutter Android Setup](https://docs.flutter.dev/deployment/android)
