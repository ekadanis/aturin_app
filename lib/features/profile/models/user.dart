class User {
  final int? id;
  final String username;
  final String email;
  final String avatar;

  User({
    this.id,
    required this.username,
    required this.email,
    required this.avatar,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'avatar': avatar,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      username: map['username'],
      email: map['email'],
      avatar: map['avatar'],
    );
  }
}