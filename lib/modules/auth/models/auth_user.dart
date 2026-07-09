import 'package:json_annotation/json_annotation.dart';

part 'auth_user.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class AuthUser {
  const AuthUser({
    required this.id,
    required this.fullName,
    required this.email,
    required this.role,
    this.token = '',
  });

  final int id;
  final String fullName;
  final String email;
  final String role;
  final String token;

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return _$AuthUserFromJson(json);
  }

  Map<String, dynamic> toJson() {
    return _$AuthUserToJson(this);
  }
}
