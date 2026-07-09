import 'package:json_annotation/json_annotation.dart';

part 'account.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class Account {
  const Account({
    required this.id,
    required this.fullName,
    required this.email,
    required this.role,
    this.phone = '',
    this.gender = '',
    this.isActive = true,
    this.isDeleted = false,
  });

  final int id;
  final String fullName;
  final String email;
  final String role;
  final String phone;
  final String gender;
  final bool isActive;
  final bool isDeleted;

  factory Account.fromJson(Map<String, dynamic> json) {
    return _$AccountFromJson(json);
  }

  Map<String, dynamic> toJson() {
    return _$AccountToJson(this);
  }

  Account copyWith({
    int? id,
    String? fullName,
    String? email,
    String? role,
    String? phone,
    String? gender,
    bool? isActive,
    bool? isDeleted,
  }) {
    return Account(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      role: role ?? this.role,
      phone: phone ?? this.phone,
      gender: gender ?? this.gender,
      isActive: isActive ?? this.isActive,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }
}
