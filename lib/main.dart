import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yandex_maps_mapkit_lite/init.dart' as init;

// 1. Импортируем наши экраны и провайдер
import 'presentation/providers/auth_provider.dart';
import 'presentation/screens/auth/auth_screen.dart';
import 'presentation/screens/home_screen/homeScreen.dart';

const String YANDEX_API_KEY = '841f16bb-5683-4ea7-9911-6b7811280c76'; // 🔑 вставь сюда свой ключ

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await init.initMapkit(
      apiKey: YANDEX_API_KEY
    ); 

  // 2. Оборачиваем все приложение в ProviderScope
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

// 3. MyApp теперь ConsumerWidget, чтобы "слушать" провайдеры
class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 4. "Слушаем" состояние аутентификации
    final authState = ref.watch(authProvider);

    return MaterialApp(
      title: 'Nomad GIS',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(), // Используем темную тему
      
      // 5. Логика навигации
      home: switch (authState) {
        // Если вошли - показываем карту
        AuthState.authenticated => const HomeScreen(),
        
        // Если не вошли - показываем экран входа
        AuthState.unauthenticated => const AuthScreen(),
        
        // По умолчанию (пока идет проверка) - показываем загрузку
        AuthState.unknown => const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          ),
      },
    );
  }
}