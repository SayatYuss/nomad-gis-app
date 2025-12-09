import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';
import '../../services/notification_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/constants.dart';
import '../../utils/validators.dart';
import '../../widgets/common/loading_indicator.dart';

class LoginScreen extends ConsumerStatefulWidget {
  final VoidCallback onRegistrationTap;

  const LoginScreen({super.key, required this.onRegistrationTap});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  late TextEditingController _identifierController;
  late TextEditingController _passwordController;
  bool _obscurePassword = true;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _identifierController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      await ref
          .read(authProvider.notifier)
          .login(
            identifier: _identifierController.text.trim(),
            password: _passwordController.text,
          );

      final authState = ref.read(authProvider);
      if (authState.error != null) {
        NotificationService.showErrorSnackBar(authState.error!);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(AppConstants.defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 32),
              // Logo
              Center(
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [AppColors.primary, AppColors.primaryDark],
                    ),
                  ),
                  child: Icon(Icons.location_on, color: Colors.white, size: 30),
                ),
              ),
              SizedBox(height: 24),
              Center(
                child: Text(
                  'Добро пожаловать',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ),
              SizedBox(height: 8),
              Center(
                child: Text(
                  'Войдите в свой аккаунт',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
              ),
              SizedBox(height: 48),
              // Form
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _identifierController,
                      enabled: !authState.isLoading,
                      decoration: InputDecoration(
                        hintText: 'Email или имя пользователя',
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                      validator: Validators.validateIdentifier,
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      enabled: !authState.isLoading,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        hintText: 'Пароль',
                        prefixIcon: Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: () => setState(
                            () => _obscurePassword = !_obscurePassword,
                          ),
                        ),
                      ),
                      validator: Validators.validatePassword,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 32),
              // Login Button
              if (authState.isLoading)
                LoadingIndicator(size: 30)
              else
                ElevatedButton(
                  onPressed: _handleLogin,
                  child: Text(AppStrings.login),
                ),
              SizedBox(height: 24),
              // Register Link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    AppStrings.dontHaveAccount,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  SizedBox(width: 4),
                  TextButton(
                    onPressed: authState.isLoading
                        ? null
                        : widget.onRegistrationTap,
                    child: Text(AppStrings.register),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
