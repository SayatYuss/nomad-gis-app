import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';
import '../../providers/profile_provider.dart';
import '../../services/notification_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/common/custom_app_bar.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends ConsumerWidget {
  final VoidCallback onLogout;

  const ProfileScreen({super.key, required this.onLogout});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileProvider);
    final userPointsAsync = ref.watch(userPointsProvider);
    final userAchievementsAsync = ref.watch(userAchievementsProvider);

    return Scaffold(
      appBar: CustomAppBar(title: 'Профиль'),
      body: profileAsync.when(
        loading: () => LoadingIndicator(),
        error: (err, st) => Center(child: Text('Ошибка загрузки профиля')),
        data: (user) => SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Profile Header
              Container(
                color: AppColors.surface,
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Avatar
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.primary, width: 3),
                      ),
                      child: user.avatarUrl != null
                          ? CircleAvatar(
                              backgroundImage: NetworkImage(user.avatarUrl!),
                              backgroundColor: AppColors.surfaceLight,
                            )
                          : CircleAvatar(
                              backgroundColor: AppColors.surfaceLight,
                              child: Icon(
                                Icons.person,
                                size: 40,
                                color: AppColors.textSecondary,
                              ),
                            ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      user.username ?? 'Пользователь',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    SizedBox(height: 4),
                    Text(
                      user.email ?? '',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textTertiary,
                      ),
                    ),
                    SizedBox(height: 12),
                    // Edit Profile Button
                    OutlinedButton.icon(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => EditProfileScreen(
                              currentUsername: user.username,
                              currentAvatarUrl: user.avatarUrl,
                            ),
                          ),
                        );
                      },
                      icon: Icon(Icons.edit, size: 18),
                      label: Text('Редактировать профиль'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: BorderSide(color: AppColors.primary),
                      ),
                    ),
                  ],
                ),
              ),
              // Stats
              Padding(
                padding: EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        title: 'Уровень',
                        value: user.level.toString(),
                        icon: Icons.star,
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: _StatCard(
                        title: 'Опыт',
                        value: user.experience.toString(),
                        icon: Icons.flash_on,
                      ),
                    ),
                  ],
                ),
              ),
              // Opened Points
              _SectionTitle('Открытые точки'),
              userPointsAsync.when(
                loading: () => LoadingIndicator(size: 30),
                error: (err, st) => Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('Ошибка загрузки'),
                ),
                data: (points) => points.isNotEmpty
                    ? ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: points.length,
                        itemBuilder: (context, index) => ListTile(
                          leading: Icon(
                            Icons.location_on,
                            color: AppColors.primary,
                          ),
                          title: Text(points[index].name ?? 'Точка'),
                          subtitle: Text(
                            '${points[index].latitude.toStringAsFixed(4)}, '
                            '${points[index].longitude.toStringAsFixed(4)}',
                          ),
                        ),
                      )
                    : Padding(
                        padding: EdgeInsets.all(16),
                        child: Text('Нет открытых точек'),
                      ),
              ),
              // Achievements
              _SectionTitle('Достижения'),
              userAchievementsAsync.when(
                loading: () => LoadingIndicator(size: 30),
                error: (err, st) => Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('Ошибка загрузки'),
                ),
                data: (achievements) => achievements.isNotEmpty
                    ? GridView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          childAspectRatio: 1,
                        ),
                        itemCount: achievements.length,
                        itemBuilder: (context, index) => Padding(
                          padding: EdgeInsets.all(8),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: AppColors.surfaceLight,
                              border: Border.all(color: AppColors.borderColor),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (achievements[index].badgeImageUrl != null)
                                  Image.network(
                                    achievements[index].badgeImageUrl!,
                                    width: 40,
                                    height: 40,
                                  ),
                              ],
                            ),
                          ),
                        ),
                      )
                    : Padding(
                        padding: EdgeInsets.all(16),
                        child: Text('Нет достижений'),
                      ),
              ),
              SizedBox(height: 32),
              // Logout Button
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: ElevatedButton(
                  onPressed: () async {
                    final confirmed =
                        await NotificationService.showConfirmDialog(
                          context,
                          title: 'Выход',
                          message: 'Вы уверены, что хотите выйти?',
                          confirmText: 'Выход',
                          cancelText: 'Отмена',
                        );
                    if (confirmed == true) {
                      await ref.read(authProvider.notifier).logout();
                      onLogout();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.error,
                  ),
                  child: Text('Выход из аккаунта'),
                ),
              ),
              SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.primary),
          SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(color: AppColors.primary),
          ),
          SizedBox(height: 4),
          Text(title, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 24, 16, 12),
      child: Text(title, style: Theme.of(context).textTheme.titleLarge),
    );
  }
}
