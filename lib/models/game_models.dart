import 'package:nomad_gis_lib/nomad_gis_lib.dart';

class UnlockedPoint {
  final MapPointRequest point;
  final DateTime unlockedAt;
  final double distanceMeters;

  UnlockedPoint({
    required this.point,
    required this.unlockedAt,
    required this.distanceMeters,
  });
}

class AchievementStatus {
  final AchievementResponse achievement;
  final bool isUnlocked;
  final DateTime? unlockedAt;

  AchievementStatus({
    required this.achievement,
    required this.isUnlocked,
    this.unlockedAt,
  });
}

class GameNotification {
  final String
  type; // 'point_unlocked', 'achievement_unlocked', 'experience_gained'
  final String title;
  final String message;
  final int? experienceGained;
  final DateTime timestamp;

  GameNotification({
    required this.type,
    required this.title,
    required this.message,
    this.experienceGained,
    required this.timestamp,
  });
}
