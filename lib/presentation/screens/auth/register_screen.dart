import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart'; // Убедитесь, что путь верный

class RegisterScreen extends ConsumerStatefulWidget {
  // Конструктор был неполным
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _emailController = TextEditingController(text: 'sayat@nomad.com');
  final _usernameController = TextEditingController(text: 'username');
  final _passwordController = TextEditingController(text: 'strongPassword');
  
  // Использование 'flutter-app-linux-1' идеально подходит для 
  // тестирования на вашей Ubuntu 22.04.
  final _deviceId = 'flutter-app-linux-1'; 

  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    setState(() => _isLoading = true);
    
    // Вызываем .register() из провайдера
    final success = await ref.read(authProvider.notifier).register(
          _emailController.text,
          _usernameController.text,
          _passwordController.text,
          _deviceId,
        );

    // [ИСПРАВЛЕНО 1] Показываем ошибку, если !success (неудача)
    if (!success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Ошибка. Email или Username уже заняты?")),
      );
    }
    // Если регистрация успешна, main.dart сам нас перенаправит

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Добавляем AppBar для кнопки "Назад"
      appBar: AppBar(
        title: const Text('Регистрация'),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Center(
        // SingleChildScrollView, чтобы поля не закрывались клавиатурой
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // [ИСПРАВЛЕНО 4] Меняем заголовок
                const Text('Создать аккаунт', style: TextStyle(fontSize: 24)),
                const SizedBox(height: 20),
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
                const SizedBox(height: 12),
                
                // [ИСПРАВЛЕНО 2] Добавляем недостающее поле пароля
                TextField(
                  controller: _passwordController,
                  obscureText: true, // Скрываем пароль
                  decoration: const InputDecoration(
                    labelText: 'Пароль',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),

                _isLoading
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                        // [ИСПРАВЛЕНО 3] Вызываем _register
                        onPressed: _register,
                        // [ИСПРАВЛЕНО 5] Меняем текст кнопки
                        child: const Text('Зарегистрироваться'),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
