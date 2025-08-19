class User {
  final int? id;
  final String name;
  final String email;
  final String? password;
  final String avatar;
  final String slug;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final bool is_global_enabled;
  final String? googleId;
  final String? provider;

  User({
    this.id,
    required this.name,
    required this.email,
    this.password,
    this.avatar = 'assets/avatars/profile1.jpg',
    required this.slug,
    this.createdAt,
    this.updatedAt,
    this.is_global_enabled = true,
    this.googleId,
    this.provider,
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
      'is_global_enabled': is_global_enabled, // mapping ke kolom DB
      'google_id': googleId,
      'provider': provider,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      password: map['password'],
      avatar: map['avatar'] ?? 'assets/avatars/profile1.jpg',
      slug: map['slug'] ?? '',
      createdAt: map['created_at'] != null
          ? DateTime.tryParse(map['created_at'])
          : null,
      updatedAt: map['updated_at'] != null
          ? DateTime.tryParse(map['updated_at'])
          : null,
      is_global_enabled: map['is_global_enabled'] ?? map['is_global_alarm_enabled'] ?? true,
      googleId: map['google_id'],
      provider: map['provider'],
    );
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      password: json['password'],
      avatar: json['avatar'] ?? 'assets/avatars/profile1.jpg',
      slug: json['slug'] ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'])
          : null,
      is_global_enabled: json['is_global_enabled'] ?? json['is_global_alarm_enabled'] ?? true,
      googleId: json['google_id'],
      provider: json['provider'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'avatar': avatar,
      'slug': slug,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'is_global_enabled': is_global_enabled,
      'google_id': googleId,
      'provider': provider,
    };
  }

  User copyWithoutPassword() {
    return User(
      id: id,
      name: name,
      email: email,
      avatar: avatar,
      slug: slug,
      createdAt: createdAt,
      updatedAt: updatedAt,
      is_global_enabled: is_global_enabled,
      googleId: googleId,
      provider: provider,
    );
  }

  Map<String, dynamic> toRegistrationMap() {
    return {
      'name': name,
      'email': email,
      'password': password,
      'slug': slug,
    };
  }

  User copyWith({
    int? id,
    String? name,
    String? email,
    String? password,
    String? avatar,
    String? slug,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? is_global_enabled,
    String? googleId,
    String? provider,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      password: password ?? this.password,
      avatar: avatar ?? this.avatar,
      slug: slug ?? this.slug,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      is_global_enabled: is_global_enabled ?? this.is_global_enabled,
      googleId: googleId ?? this.googleId,
      provider: provider ?? this.provider,
    );
  }

  /// Check if user is logged in via Google
  bool get isGoogleUser => provider == 'google' && googleId != null;
  
  /// Get display avatar (prioritize Google avatar if available)
  String get displayAvatar {
    if (isGoogleUser && avatar.startsWith('http')) {
      return avatar; // Google avatar URL
    }
    return avatar; // Local avatar
  }
}
