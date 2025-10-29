import 'package:flutter/foundation.dart';
import 'user_achievements.dart';
import 'user_dto.dart';
import 'user_map_progress.dart';

// Этот класс будет хранить все данные для экрана профиля
@immutable
class UserProfileData {
  final UserDto profile;
  final List<UserMapProgress> unlockedPoints;
  final List<UserAchievement> achievements;

  const UserProfileData({
    required this.profile,
    required this.unlockedPoints,
    required this.achievements,
  });
}