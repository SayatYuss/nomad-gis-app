import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 1. Импортируем наши экраны и провайдер
import 'presentation/providers/auth_provider.dart';
import 'presentation/screens/auth/login_screen.dart';
import 'presentation/screens/home_screen/homeScreen.dart';

void main() {
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
        AuthState.unauthenticated => const LoginScreen(),
        
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