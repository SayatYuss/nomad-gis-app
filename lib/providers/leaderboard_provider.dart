import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nomad_gis_lib/nomad_gis_lib.dart';
import '../config/providers.dart';

// Experience Leaderboard Provider
final experienceLeaderboardProvider = FutureProvider<List<LeaderboardEntryDto>>(
  (ref) async {
    final apiService = ref.watch(apiServiceProvider);
    return apiService.client.leaderboard.getExperienceLeaderboard();
  },
);

// Points Leaderboard Provider
final pointsLeaderboardProvider = FutureProvider<List<LeaderboardEntryDto>>((
  ref,
) async {
  final apiService = ref.watch(apiServiceProvider);
  return apiService.client.leaderboard.getPointsLeaderboard();
});

// Achievements Leaderboard Provider
final achievementsLeaderboardProvider =
    FutureProvider<List<LeaderboardEntryDto>>((ref) async {
      final apiService = ref.watch(apiServiceProvider);
      return apiService.client.leaderboard.getAchievementsLeaderboard();
    });
