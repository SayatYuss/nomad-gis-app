import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart'; // Убедись, что путь верный

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  // --- Состояние ---
  bool _isLoginMode = true; // true = Вход, false = Регистрация
  bool _isLoading = false;

  // --- Контроллеры (общие и только для регистрации) ---
  final _identifierController = TextEditingController(text: 'admin'); // Email или Username для входа
  final _emailController = TextEditingController(text: 'sayat@nomad.com'); // Email для регистрации
  final _usernameController = TextEditingController(text: 'username'); // Username для регистрации
  final _passwordController = TextEditingController(text: 'strongPassword');
  // Используем ваш deviceId для Ubuntu
  final _deviceId = 'flutter-app-linux-1'; // Можно сгенерировать 1 раз или брать из ОС

  @override
  void dispose() {
    _identifierController.dispose();
    _emailController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // --- Логика отправки формы ---
  Future<void> _submitForm() async {
    setState(() => _isLoading = true);

    bool success = false;
    final authNotifier = ref.read(authProvider.notifier);

    if (_isLoginMode) {
      // --- Вход ---
      success = await authNotifier.login(
        _identifierController.text,
        _passwordController.text,
        _deviceId,
      );
      if (!success && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ошибка входа! Неверный логин или пароль.')),
        );
      }
    } else {
      // --- Регистрация ---
      success = await authNotifier.register(
        _emailController.text,
        _usernameController.text,
        _passwordController.text,
        _deviceId,
      );
      if (!success && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Ошибка регистрации. Email или Username уже заняты?")),
        );
      }
    }

    // Если success == true, main.dart сам перекинет нас дальше
    // Проверяем, смонтирован ли виджет, прежде чем менять state
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  // --- Переключение режима ---
  void _toggleAuthMode() {
    setState(() {
      _isLoginMode = !_isLoginMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // --- Заголовок ---
                Text(
                  _isLoginMode ? 'Вход' : 'Создать аккаунт',
                  style: const TextStyle(fontSize: 24),
                ),
                const SizedBox(height: 20),

                // --- Поля ввода ---
                if (_isLoginMode) // Поле Email/Username (только для входа)
                  TextField(
                    controller: _identifierController,
                    decoration: const InputDecoration(
                      labelText: 'Email или Username',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.emailAddress, // Примерный тип
                  )
                else ...[ // Поля Email и Username (только для регистрации)
                  TextField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _usernameController,
                    decoration: const InputDecoration(
                      labelText: 'Username',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
                const SizedBox(height: 12),

                // Поле Пароль (общее)
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Пароль',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),

                // --- Кнопка действия ---
                _isLoading
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: _submitForm,
                        child: Text(_isLoginMode ? 'Войти' : 'Зарегистрироваться'),
                      ),
                const SizedBox(height: 20),

                // --- Кнопка переключения режима ---
                TextButton(
                  onPressed: _isLoading ? null : _toggleAuthMode,
                  child: Text(
                    _isLoginMode
                        ? 'Нет аккаунта? Зарегистрироваться'
                        : 'Уже есть аккаунт? Войти',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}