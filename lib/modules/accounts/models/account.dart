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

  @JsonKey(readValue: _readId)
  final int id;
  final String fullName;
  final String email;
  @JsonKey(readValue: _readRole)
  final String role;
  @JsonKey(defaultValue: '')
  final String phone;
  @JsonKey(defaultValue: '')
  final String gender;
  @JsonKey(readValue: _readIsActive)
  final bool isActive;
  @JsonKey(readValue: _readIsDeleted)
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

  static Object? _readId(Map<dynamic, dynamic> json, String key) {
    return json['account_id'] ?? json['teacher_id'] ?? json[key] ?? 0;
  }

  static Object? _readRole(Map<dynamic, dynamic> json, String key) {
    final account = json['account'];
    if (account is Map) {
      return account['role'] ?? 'none';
    }
    return json[key] ?? 'none';
  }

  static Object? _readIsActive(Map<dynamic, dynamic> json, String key) {
    final account = json['account'];
    if (account is Map && account['is_active'] is bool) {
      return account['is_active'];
    }
    return json[key] ?? true;
  }

  static Object? _readIsDeleted(Map<dynamic, dynamic> json, String key) {
    return json['is_deleted'] == true || json['deleted_at'] != null;
  }
}
