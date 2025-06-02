class User {
  final int? id;
  final String name;
  final String email;
  final String? password;
  final String avatar;
  final String slug;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int? todayActivities;
  final int? todayTasks;
  final bool is_global_enabled;

  User({
    this.id,
    required this.name,
    required this.email,
    this.password,
    this.avatar = 'assets/avatars/profile1.jpg',
    required this.slug,
    this.createdAt,
    this.updatedAt,
    this.todayActivities,
    this.todayTasks,
    final this.is_global_enabled = true,
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
      'today_activities': todayActivities,
      'today_tasks': todayTasks,
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
      todayActivities: map['today_activities'],
      todayTasks: map['today_tasks'],
    );
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      password: json['password'],
      avatar: json['avatar'] ?? '/assets/avatars/profile1.jpg',
      slug: json['slug'] ?? '',
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.tryParse(json['updated_at']) : null,
      todayActivities: json['today_activities'],
      todayTasks: json['today_tasks'],
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
      'today_activities': todayActivities,
      'today_tasks': todayTasks,
    };
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
      todayActivities: todayActivities,
      todayTasks: todayTasks,
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

  User copyWith({
    int? id,
    String? name,
    String? email,
    String? password,
    String? avatar,
    String? slug,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? todayActivities,
    int? todayTasks,
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
      todayActivities: todayActivities ?? this.todayActivities,
      todayTasks: todayTasks ?? this.todayTasks,
    );
  }
}