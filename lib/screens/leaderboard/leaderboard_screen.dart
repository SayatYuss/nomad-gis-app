import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nomad_gis_lib/nomad_gis_lib.dart';
import '../../providers/leaderboard_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common/loading_indicator.dart';

class LeaderboardScreen extends ConsumerWidget {
  const LeaderboardScreen({super.key});

  void _refreshAll(WidgetRef ref) {
    ref.invalidate(experienceLeaderboardProvider);
    ref.invalidate(pointsLeaderboardProvider);
    ref.invalidate(achievementsLeaderboardProvider);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(kToolbarHeight + 48),
          child: Column(
            children: [
              AppBar(
                title: Text('Лидерборд'),
                centerTitle: true,
                actions: [
                  IconButton(
                    icon: Icon(Icons.refresh),
                    onPressed: () => _refreshAll(ref),
                    tooltip: 'Обновить',
                  ),
                ],
              ),
              TabBar(
                tabs: [
                  Tab(text: 'По опыту'),
                  Tab(text: 'По точкам'),
                  Tab(text: 'По ачивкам'),
                ],
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _LeaderboardTab(
              leaderboardProvider: experienceLeaderboardProvider,
              metric: 'опыта',
            ),
            _LeaderboardTab(
              leaderboardProvider: pointsLeaderboardProvider,
              metric: 'точек',
            ),
            _LeaderboardTab(
              leaderboardProvider: achievementsLeaderboardProvider,
              metric: 'ачивок',
            ),
          ],
        ),
      ),
    );
  }
}

class _LeaderboardTab extends ConsumerWidget {
  final FutureProvider<List<LeaderboardEntryDto>> leaderboardProvider;
  final String metric;

  const _LeaderboardTab({
    required this.leaderboardProvider,
    required this.metric,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final leaderboardAsync = ref.watch(leaderboardProvider);

    return leaderboardAsync.when(
      loading: () => Center(child: LoadingIndicator()),
      error: (err, st) => Center(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 48, color: AppColors.error),
              SizedBox(height: 16),
              Text(
                'Ошибка загрузки лидерборда',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              SizedBox(height: 8),
              Text(
                err.toString(),
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.invalidate(leaderboardProvider),
                child: Text('Повторить'),
              ),
            ],
          ),
        ),
      ),
      data: (entries) => entries.isEmpty
          ? Center(
              child: Text(
                'Нет данных',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            )
          : ListView.builder(
              itemCount: entries.length,
              itemBuilder: (context, index) {
                final entry = entries[index];
                final isTopThree = index < 3;
                final medalColor = isTopThree
                    ? [AppColors.primary, Colors.amber, Colors.grey][index]
                    : null;

                return Container(
                  margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isTopThree
                        ? AppColors.surfaceLight
                        : AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isTopThree ? medalColor! : AppColors.borderColor,
                      width: isTopThree ? 2 : 1,
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(12),
                    child: Row(
                      children: [
                        // Medal or Rank
                        if (isTopThree)
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: medalColor,
                            ),
                            child: Center(
                              child: Text(
                                (index + 1).toString(),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          )
                        else
                          SizedBox(
                            width: 40,
                            child: Text(
                              '${index + 1}',
                              style: Theme.of(context).textTheme.titleMedium,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        SizedBox(width: 12),
                        // Avatar
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.borderColor),
                          ),
                          child: entry.avatarUrl != null
                              ? CircleAvatar(
                                  backgroundImage: NetworkImage(
                                    entry.avatarUrl!,
                                  ),
                                  backgroundColor: AppColors.surfaceLight,
                                )
                              : CircleAvatar(
                                  backgroundColor: AppColors.surfaceLight,
                                  child: Icon(
                                    Icons.person,
                                    size: 20,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                        ),
                        SizedBox(width: 12),
                        // Username and Level
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                entry.username ?? 'Пользователь',
                                style: Theme.of(context).textTheme.titleMedium,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                'Уровень ${entry.level}',
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(color: AppColors.textTertiary),
                              ),
                            ],
                          ),
                        ),
                        // Score
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              entry.score.toString(),
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(color: AppColors.primary),
                            ),
                            Text(
                              metric,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: AppColors.textTertiary),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
