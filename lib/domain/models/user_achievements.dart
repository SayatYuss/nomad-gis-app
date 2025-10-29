class UserAchievement {
  final String userId;
  final String achievementId;
  final int progressValue;
  final bool isCompleted;
  final DateTime? completedAt; // DateTime? (может быть null)

  UserAchievement({
    required this.userId,
    required this.achievementId,
    required this.progressValue,
    required this.isCompleted,
    this.completedAt,
  });

  factory UserAchievement.fromJson(Map<String, dynamic> json) {
    return UserAchievement(
      userId: json['userId'],
      achievementId: json['achievementId'],
      progressValue: json['progressValue'],
      isCompleted: json['isCompleted'],
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'])
          : null,
    );
  }
}