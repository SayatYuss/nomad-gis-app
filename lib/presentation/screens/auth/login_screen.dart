import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';
import 'register_screen.dart'; // 1. Импортируем экран регистрации

// Мы используем ConsumerStatefulWidget, чтобы хранить контроллеры для полей ввода
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  // Контроллеры для получения текста из полей
  final _identifierController = TextEditingController(text: 'admin'); // для теста
  final _passwordController = TextEditingController(text: 'strongPassword'); // для теста
  final _deviceId = 'flutter-app-linux-1'; // Можно сгенерировать 1 раз

  bool _isLoading = false;

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
  
  // Асинхронная функция для входа
  Future<void> _login() async {
    setState(() => _isLoading = true);

    final success = await ref.read(authProvider.notifier).login(
      _identifierController.text,
      _passwordController.text,
      _deviceId,
    );

    if (!success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ошибка входа! Неверный логин или пароль.')),
      );
    }
    // Если success == true, main.dart сам перекинет нас на MapScreen
    
    // Проверяем, смонтирован ли виджет, прежде чем менять state
    if (mounted) {
       setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        // Оборачиваем в SingleChildScrollView для предотвращения переполнения клавиатурой
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Вход', style: TextStyle(fontSize: 24)),
                const SizedBox(height: 20),
                TextField(
                  controller: _identifierController,
                  decoration: const InputDecoration(
                    labelText: 'Email или Username',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Пароль',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),
                
                // Показываем кнопку или загрузку
                _isLoading
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: _login,
                        child: const Text('Войти'),
                      ),
                
                // 2. ДОБАВЛЕНА КНОПКА ДЛЯ ПЕРЕХОДА НА РЕГИСТРАЦИЮ
                const SizedBox(height: 20),
                TextButton(
                  // Блокируем кнопку во время загрузки
                  onPressed: _isLoading ? null : () {
                    // 3. Переходим на RegisterScreen
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const RegisterScreen(),
                      ),
                    );
                  },
                  child: const Text('Нет аккаунта? Зарегистрироваться'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

