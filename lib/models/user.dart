import 'dart:convert';

class User {

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.password,
    required this.createdAt,
  });

  // Create User from Map
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      password: map['password'] ?? '',
      createdAt: DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  // Create User from JSON string
  factory User.fromJson(String source) => User.fromMap(json.decode(source));
  final String id;
  final String name;
  final String email;
  final String phone;
  final String password; // In production, never store plain passwords!
  final DateTime createdAt;

  // Convert User to Map for storage
  Map<String, dynamic> toMap() => {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'password': password,
      'createdAt': createdAt.toIso8601String(),
    };

  // Convert to JSON string
  String toJson() => json.encode(toMap());

  // Create a copy with updated fields
  User copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? password,
    DateTime? createdAt,
  }) => User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      password: password ?? this.password,
      createdAt: createdAt ?? this.createdAt,
    );
}
