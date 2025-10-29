class UserDto {
  final String id;
  final String email;
  final String username;
  final int experience;
  final int level;
  final String? avatarUrl;

  UserDto({
    required this.id,
    required this.email,
    required this.username,
    required this.experience,
    required this.level,
    this.avatarUrl,
  });

  // Фабричный конструктор для парсинга JSON
  factory UserDto.fromJson(Map<String, dynamic> json) {
    return UserDto(
      id: json['id'],
      email: json['email'],
      username: json['username'],
      experience: json['experience'],
      level: json['level'],
      avatarUrl: json['avatarUrl'],
    );
  }
}