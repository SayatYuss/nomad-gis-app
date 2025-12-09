import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/achievements_provider.dart';
import '../../providers/profile_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/common/custom_app_bar.dart';

class AchievementsScreen extends ConsumerStatefulWidget {
  const AchievementsScreen({super.key});

  @override
  ConsumerState<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends ConsumerState<AchievementsScreen> {
  String _filter = 'all'; // all, unlocked, locked

  @override
  Widget build(BuildContext context) {
    final allAchievementsAsync = ref.watch(allAchievementsProvider);
    final userAchievementsAsync = ref.watch(userAchievementsProvider);

    return Scaffold(
      appBar: CustomAppBar(title: 'Достижения'),
      body: Column(
        children: [
          // Progress Section
          allAchievementsAsync.when(
            loading: () => SizedBox.shrink(),
            error: (err, st) => SizedBox.shrink(),
            data: (allAchievements) {
              return userAchievementsAsync.when(
                loading: () => SizedBox.shrink(),
                error: (err, st) => SizedBox.shrink(),
                data: (userAchievements) {
                  final total = allAchievements.length;
                  final unlocked = userAchievements.length;
                  final progress = total > 0 ? unlocked / total : 0.0;
                  final totalReward = userAchievements.fold<int>(
                    0,
                    (sum, a) => sum + a.rewardPoints,
                  );

                  return Container(
                    margin: EdgeInsets.all(12),
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceLight,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.borderColor),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Прогресс',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            Text(
                              '$unlocked / $total',
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(color: AppColors.primary),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: progress,
                            backgroundColor: AppColors.surface,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.primary,
                            ),
                            minHeight: 8,
                          ),
                        ),
                        SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${(progress * 100).toStringAsFixed(0)}% завершено',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: AppColors.textTertiary),
                            ),
                            Text(
                              '+$totalReward опыта',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: AppColors.secondary),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
          // Filter Buttons
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _FilterButton(
                    label: 'Все',
                    isSelected: _filter == 'all',
                    onTap: () => setState(() => _filter = 'all'),
                  ),
                  SizedBox(width: 8),
                  _FilterButton(
                    label: 'Открытые',
                    isSelected: _filter == 'unlocked',
                    onTap: () => setState(() => _filter = 'unlocked'),
                  ),
                  SizedBox(width: 8),
                  _FilterButton(
                    label: 'Закрытые',
                    isSelected: _filter == 'locked',
                    onTap: () => setState(() => _filter = 'locked'),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 8),
          // Achievements Grid
          Expanded(
            child: allAchievementsAsync.when(
              loading: () => LoadingIndicator(),
              error: (err, st) => Center(child: Text('Ошибка загрузки')),
              data: (allAchievements) {
                return userAchievementsAsync.when(
                  loading: () => LoadingIndicator(),
                  error: (err, st) => Center(child: Text('Ошибка загрузки')),
                  data: (userAchievements) {
                    final filteredAchievements = allAchievements.where((
                      achievement,
                    ) {
                      final isUnlocked = userAchievements.any(
                        (ua) => ua.id == achievement.id,
                      );
                      if (_filter == 'all') return true;
                      if (_filter == 'unlocked') return isUnlocked;
                      if (_filter == 'locked') return !isUnlocked;
                      return true;
                    }).toList();

                    return GridView.builder(
                      padding: EdgeInsets.all(12),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        childAspectRatio: 0.9,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      itemCount: filteredAchievements.length,
                      itemBuilder: (context, index) {
                        final achievement = filteredAchievements[index];
                        final isUnlocked = userAchievements.any(
                          (ua) => ua.id == achievement.id,
                        );

                        return _AchievementCard(
                          title: achievement.title ?? 'Ачивка',
                          description: achievement.description,
                          badgeUrl: achievement.badgeImageUrl,
                          isUnlocked: isUnlocked,
                          reward: achievement.rewardPoints,
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: isSelected ? AppColors.primary : AppColors.surfaceLight,
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.borderColor,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _AchievementCard extends StatelessWidget {
  final String title;
  final String? description;
  final String? badgeUrl;
  final bool isUnlocked;
  final int reward;

  const _AchievementCard({
    required this.title,
    this.description,
    this.badgeUrl,
    required this.isUnlocked,
    required this.reward,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          builder: (context) => Container(
            color: AppColors.surface,
            padding: EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (badgeUrl != null)
                  Image.network(badgeUrl!, width: 80, height: 80),
                SizedBox(height: 16),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),
                if (description != null) ...[
                  SizedBox(height: 8),
                  Text(
                    description!,
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ],
                SizedBox(height: 8),
                Text(
                  'Награда: $reward опыта',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: AppColors.primary),
                ),
                if (isUnlocked) ...[
                  SizedBox(height: 12),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.success,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check, color: Colors.white, size: 16),
                        SizedBox(width: 4),
                        Text(
                          'Разблокировано',
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ],
                SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isUnlocked ? AppColors.primary : AppColors.borderColor,
            width: isUnlocked ? 2 : 1,
          ),
        ),
        child: Stack(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (badgeUrl != null)
                  Padding(
                    padding: EdgeInsets.all(8),
                    child: Image.network(
                      badgeUrl!,
                      width: 50,
                      height: 50,
                      errorBuilder: (context, error, stackTrace) =>
                          Icon(Icons.stars, size: 50),
                    ),
                  ),
                SizedBox(height: 8),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.labelLarge,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            if (!isUnlocked)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.black.withValues(alpha: 0.4),
                  ),
                  child: const Center(
                    child: Icon(Icons.lock, color: Colors.white, size: 32),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
