import 'package:equatable/equatable.dart';

import 'package:costbook/core/constants/user_role.dart';

// ผู้ใช้ (API /auth/me, /profile, /users) / avatarVersion = 0 คือยังไม่มีรูปโปรไฟล์
class UserModel extends Equatable {
  const UserModel({
    this.id = '',
    this.email = '',
    this.firstName = '',
    this.lastName = '',
    this.role = UserRole.staff,
    this.isActive = true,
    this.avatarVersion = 0,
  });

  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final UserRole role;
  final bool isActive;
  final int avatarVersion;

  bool get isNew => id.isEmpty;

  bool get isOwner => role == UserRole.owner;

  bool get hasAvatar => avatarVersion > 0;

  // ชื่อ-นามสกุล / ยังไม่มีชื่อ → ใช้อีเมลแทน
  String get displayName {
    final fullName = '$firstName $lastName'.trim();
    if (fullName.isEmpty) return email;
    return fullName;
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String? ?? '',
      email: json['email'] as String? ?? '',
      firstName: json['first_name'] as String? ?? '',
      lastName: json['last_name'] as String? ?? '',
      role: UserRole.fromName(json['role'] as String?),
      isActive: json['active'] as bool? ?? true,
      avatarVersion: (json['avatar_version'] as num? ?? 0).toInt(),
    );
  }

  // ข้อมูลที่เจ้าของร้านแก้ได้ (PUT /users/:id)
  Map<String, dynamic> toJson() => {
    'first_name': firstName,
    'last_name': lastName,
    'role': role.name,
    'active': isActive,
  };

  @override
  List<Object?> get props => [id, email, firstName, lastName, role, isActive, avatarVersion];
}
