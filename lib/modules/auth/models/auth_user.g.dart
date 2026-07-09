// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AuthUser _$AuthUserFromJson(Map<String, dynamic> json) => AuthUser(
  id: (json['account_id'] as num).toInt(),
  fullName: json['full_name'] as String,
  email: json['email'] as String,
  role: json['role'] as String? ?? 'TEACHER',
  token: json['token'] as String? ?? '',
);

Map<String, dynamic> _$AuthUserToJson(AuthUser instance) => <String, dynamic>{
  'account_id': instance.id,
  'full_name': instance.fullName,
  'email': instance.email,
  'role': instance.role,
  'token': instance.token,
};
