class User {
  final int? id;
  final String name;
  final String email;
  final String? password;
  final String avatar;
  final String slug;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  User({
    this.id,
    required this.name,
    required this.email,
    this.password,
    this.avatar = '/assets/avatars/profile1.jpg',
    required this.slug,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'password': password,
      'avatar': avatar,
      'slug': slug,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      password: map['password'],
      avatar: map['avatar'] ?? '/assets/avatars/profile1.jpg',
      slug: map['slug'] ?? '',
      createdAt: map['created_at'] != null ? DateTime.tryParse(map['created_at']) : null,
      updatedAt: map['updated_at'] != null ? DateTime.tryParse(map['updated_at']) : null,
    );
  }

  // Method to create a copy without password for security
  User copyWithoutPassword() {
    return User(
      id: id,
      name: name,
      email: email,
      avatar: avatar,
      slug: slug,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  // Method for registration data (includes password)
  Map<String, dynamic> toRegistrationMap() {
    return {
      'name': name,
      'email': email,
      'password': password,
      'slug': slug,
    };
  }
}