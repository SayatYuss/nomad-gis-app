import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/profile_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileDataAsync = ref.watch(profileProvider);
    final theme = Theme.of(context); // Получаем текущую тему

    return Scaffold(
      appBar: AppBar(
        title: const Text('Мой Профиль'),
        backgroundColor: Colors.transparent, // Сделаем AppBar прозрачным
        elevation: 0, // Уберем тень AppBar
        actions: [
          IconButton(
            onPressed: () {
              ref.read(profileProvider.notifier).refresh();
            },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      // Убираем отступы Scaffold, чтобы ListView начинался от верха
      body: profileDataAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Ошибка: $err')),
        data: (data) {
          final profile = data.profile;
          final avatarUrl = profile.avatarUrl;

          return ListView(
            // Убираем стандартные отступы ListView
            padding: EdgeInsets.zero, 
            children: [
              // --- Блок Хедера с Аватаром ---
              Container(
                padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 16),
                // Можно добавить градиент или фоновое изображение
                // color: theme.colorScheme.primary.withOpacity(0.1), 
                child: Column(
                  children: [
                    // -- Аватар --
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: theme.colorScheme.surfaceContainerHighest, // Фон, если картинка не загрузится
                      // Используем NetworkImage для загрузки из URL
                      // Обрабатываем случай, если avatarUrl == null или пустой
                      backgroundImage: (avatarUrl != null && avatarUrl.isNotEmpty)
                          ? NetworkImage(avatarUrl)
                          : null, // Если null, показывается backgroundColor
                      // Можно добавить иконку-заглушку
                      child: (avatarUrl == null || avatarUrl.isEmpty)
                          ? Icon(
                              Icons.person,
                              size: 50,
                              color: theme.colorScheme.onSurfaceVariant,
                            )
                          : null,
                    ),
                    const SizedBox(height: 16),
                    // -- Username --
                    Text(
                      profile.username,
                      style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    // -- Уровень и Опыт --
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Chip(
                          avatar: Icon(Icons.star, color: Colors.amber, size: 16),
                          label: Text('Уровень: ${profile.level}'),
                           backgroundColor: theme.colorScheme.secondaryContainer,
                           labelStyle: TextStyle(color: theme.colorScheme.onSecondaryContainer),
                        ),
                        const SizedBox(width: 12),
                        Chip(
                           avatar: Icon(Icons.military_tech, color: Colors.lightGreen, size: 16),
                           label: Text('Опыт: ${profile.experience} XP'),
                           backgroundColor: theme.colorScheme.tertiaryContainer,
                           labelStyle: TextStyle(color: theme.colorScheme.onTertiaryContainer),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // --- Блок Статистики (Точки и Ачивки) ---
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                   crossAxisAlignment: CrossAxisAlignment.start,
                   children: [
                     Text('Статистика', style: theme.textTheme.titleLarge),
                     const SizedBox(height: 16),
                     _buildStatCard(
                       context: context,
                       icon: Icons.location_on,
                       iconColor: Colors.blueAccent,
                       title: 'Открыто точек',
                       value: '${data.unlockedPoints.length}',
                     ),
                     const SizedBox(height: 12),
                      _buildStatCard(
                       context: context,
                       icon: Icons.emoji_events,
                       iconColor: Colors.orangeAccent,
                       title: 'Получено достижений',
                       value: '${data.achievements.where((a) => a.isCompleted).length}', // Считаем только завершенные
                     ),
                   ],
                ),
              ),

              // TODO: Можно добавить детальные списки точек и ачивок ниже
              // Text('Последние открытые точки:', style: theme.textTheme.titleMedium),
              // ...
              // Text('Полученные достижения:', style: theme.textTheme.titleMedium),
              // ...
            ],
          );
        },
      ),
    );
  }

  // Вспомогательный виджет для карточки статистики
  Widget _buildStatCard({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
  }) {
    final theme = Theme.of(context);
    return Card(
       elevation: 0, // Убираем тень, используем цвет фона
       color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
       child: Padding(
         padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
         child: Row(
            children: [
              Icon(icon, color: iconColor, size: 30),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Text(title, style: theme.textTheme.bodyMedium?.copyWith(
                     color: theme.colorScheme.onSurfaceVariant
                   )),
                   Text(value, style: theme.textTheme.titleLarge?.copyWith(
                     fontWeight: FontWeight.bold,
                     color: theme.colorScheme.onSurfaceVariant
                   )),
                ],
              )
            ],
         ),
       ),
    );
  }
}
