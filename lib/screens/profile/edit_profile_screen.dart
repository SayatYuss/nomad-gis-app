import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../providers/profile_provider.dart';
import '../../services/notification_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/constants.dart';
import '../../utils/validators.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/common/custom_app_bar.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  final String? currentUsername;
  final String? currentAvatarUrl;

  const EditProfileScreen({
    super.key,
    this.currentUsername,
    this.currentAvatarUrl,
  });

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  late TextEditingController _usernameController;
  late TextEditingController _currentPasswordController;
  late TextEditingController _newPasswordController;
  late TextEditingController _confirmPasswordController;

  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  bool _changePassword = false;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController(text: widget.currentUsername);
    _currentPasswordController = TextEditingController();
    _newPasswordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _pickAndUploadAvatar() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 500,
        maxHeight: 500,
        imageQuality: 80,
      );

      if (image == null) return;

      // Check file size
      final bytes = await image.readAsBytes();
      if (bytes.length > AppConstants.maxAvatarSizeBytes) {
        NotificationService.showErrorSnackBar(
          'Файл слишком большой (максимум 5 МБ)',
        );
        return;
      }

      setState(() => _isLoading = true);

      await ref.read(updateProfileProvider.notifier).uploadAvatar(bytes);

      final updateState = ref.read(updateProfileProvider);
      if (updateState.hasError) {
        NotificationService.showErrorSnackBar(updateState.error.toString());
      } else {
        NotificationService.showSuccessSnackBar('Аватар обновлен');
        ref.invalidate(profileProvider);
      }
    } catch (e) {
      NotificationService.showErrorSnackBar('Ошибка загрузки аватара');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final newUsername =
          _usernameController.text.trim() != widget.currentUsername
          ? _usernameController.text.trim()
          : null;

      String? currentPassword;
      String? newPassword;

      if (_changePassword) {
        currentPassword = _currentPasswordController.text;
        newPassword = _newPasswordController.text;
      }

      // Only update if something changed
      if (newUsername != null || newPassword != null) {
        await ref
            .read(updateProfileProvider.notifier)
            .updateProfile(
              username: newUsername,
              currentPassword: currentPassword,
              newPassword: newPassword,
            );

        final updateState = ref.read(updateProfileProvider);
        if (updateState.hasError) {
          NotificationService.showErrorSnackBar(updateState.error.toString());
        } else {
          NotificationService.showSuccessSnackBar('Профиль обновлен');
          ref.invalidate(profileProvider);
          if (mounted) {
            Navigator.of(context).pop();
          }
        }
      } else {
        NotificationService.showInfoSnackBar('Нет изменений для сохранения');
      }
    } catch (e) {
      NotificationService.showErrorSnackBar('Ошибка сохранения профиля');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'Редактировать профиль'),
      body: _isLoading
          ? Center(child: LoadingIndicator(message: 'Сохранение...'))
          : SingleChildScrollView(
              padding: EdgeInsets.all(AppConstants.defaultPadding),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Avatar Section
                    Center(
                      child: Stack(
                        children: [
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.primary,
                                width: 3,
                              ),
                            ),
                            child: widget.currentAvatarUrl != null
                                ? CircleAvatar(
                                    radius: 58,
                                    backgroundImage: NetworkImage(
                                      widget.currentAvatarUrl!,
                                    ),
                                    backgroundColor: AppColors.surfaceLight,
                                  )
                                : CircleAvatar(
                                    radius: 58,
                                    backgroundColor: AppColors.surfaceLight,
                                    child: Icon(
                                      Icons.person,
                                      size: 50,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: _pickAndUploadAvatar,
                              child: Container(
                                padding: EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: AppColors.surface,
                                    width: 2,
                                  ),
                                ),
                                child: Icon(
                                  Icons.camera_alt,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 8),
                    Center(
                      child: TextButton(
                        onPressed: _pickAndUploadAvatar,
                        child: Text('Изменить аватар'),
                      ),
                    ),
                    SizedBox(height: 24),

                    // Username Field
                    Text(
                      'Имя пользователя',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    SizedBox(height: 8),
                    TextFormField(
                      controller: _usernameController,
                      decoration: InputDecoration(
                        hintText: 'Введите имя пользователя',
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                      validator: Validators.validateUsername,
                    ),
                    SizedBox(height: 24),

                    // Change Password Toggle
                    Row(
                      children: [
                        Checkbox(
                          value: _changePassword,
                          onChanged: (value) {
                            setState(() {
                              _changePassword = value ?? false;
                              if (!_changePassword) {
                                _currentPasswordController.clear();
                                _newPasswordController.clear();
                                _confirmPasswordController.clear();
                              }
                            });
                          },
                          activeColor: AppColors.primary,
                        ),
                        Text(
                          'Изменить пароль',
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                      ],
                    ),

                    // Password Fields (shown only if changing password)
                    if (_changePassword) ...[
                      SizedBox(height: 16),
                      Text(
                        'Текущий пароль',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      SizedBox(height: 8),
                      TextFormField(
                        controller: _currentPasswordController,
                        obscureText: _obscureCurrentPassword,
                        decoration: InputDecoration(
                          hintText: 'Введите текущий пароль',
                          prefixIcon: Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureCurrentPassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onPressed: () => setState(
                              () => _obscureCurrentPassword =
                                  !_obscureCurrentPassword,
                            ),
                          ),
                        ),
                        validator: (value) {
                          if (_changePassword &&
                              (value == null || value.isEmpty)) {
                            return 'Введите текущий пароль';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Новый пароль',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      SizedBox(height: 8),
                      TextFormField(
                        controller: _newPasswordController,
                        obscureText: _obscureNewPassword,
                        decoration: InputDecoration(
                          hintText: 'Минимум 8 символов',
                          prefixIcon: Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureNewPassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onPressed: () => setState(
                              () => _obscureNewPassword = !_obscureNewPassword,
                            ),
                          ),
                        ),
                        validator: (value) {
                          if (_changePassword) {
                            return Validators.validatePassword(value);
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Подтвердите пароль',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      SizedBox(height: 8),
                      TextFormField(
                        controller: _confirmPasswordController,
                        obscureText: _obscureConfirmPassword,
                        decoration: InputDecoration(
                          hintText: 'Повторите новый пароль',
                          prefixIcon: Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureConfirmPassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onPressed: () => setState(
                              () => _obscureConfirmPassword =
                                  !_obscureConfirmPassword,
                            ),
                          ),
                        ),
                        validator: (value) {
                          if (_changePassword) {
                            return Validators.validateConfirmPassword(
                              value,
                              _newPasswordController.text,
                            );
                          }
                          return null;
                        },
                      ),
                    ],
                    SizedBox(height: 32),

                    // Save Button
                    ElevatedButton(
                      onPressed: _saveProfile,
                      child: Text('Сохранить изменения'),
                    ),
                    SizedBox(height: 16),

                    // Cancel Button
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text('Отмена'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
