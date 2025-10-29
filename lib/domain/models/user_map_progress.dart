class UserMapProgress {
  final String userId;
  final String mapPointId;
  final DateTime unlockedAt;

  UserMapProgress({
    required this.userId,
    required this.mapPointId,
    required this.unlockedAt,
  });

  factory UserMapProgress.fromJson(Map<String, dynamic> json) {
    return UserMapProgress(
      userId: json['userId'],
      mapPointId: json['mapPointId'],
      // API возвращает дату как строку, парсим ее
      unlockedAt: DateTime.parse(json['unlockedAt']),
    );
  }
}