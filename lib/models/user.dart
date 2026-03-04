class User {
  const User({
    required this.id,
    required this.username,
    required this.role,
  });

  final int id;
  final String username;
  final String role;

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: (json['id'] as num).toInt(),
      username: (json['username'] ?? '').toString(),
      role: (json['role'] ?? '').toString(),
    );
  }
}
