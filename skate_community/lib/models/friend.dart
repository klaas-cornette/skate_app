// lib/models/friend.dart
class Friend {
  final String id;
  final String username;
  final String email;

  Friend({
    required this.id,
    required this.username,
    required this.email,
  });

  factory Friend.fromMap(Map<String, dynamic> map) {
    return Friend(
      id: map['id'] as String,
      username: map['username'] as String,
      email: map['email'] as String,
    );
  }
}
