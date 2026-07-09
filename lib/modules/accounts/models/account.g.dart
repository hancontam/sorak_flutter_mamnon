// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Account _$AccountFromJson(Map<String, dynamic> json) => Account(
  id: (json['id'] as num).toInt(),
  fullName: json['full_name'] as String,
  email: json['email'] as String,
  role: json['role'] as String,
  phone: json['phone'] as String? ?? '',
  gender: json['gender'] as String? ?? '',
  isActive: json['is_active'] as bool? ?? true,
  isDeleted: json['is_deleted'] as bool? ?? false,
);

Map<String, dynamic> _$AccountToJson(Account instance) => <String, dynamic>{
  'id': instance.id,
  'full_name': instance.fullName,
  'email': instance.email,
  'role': instance.role,
  'phone': instance.phone,
  'gender': instance.gender,
  'is_active': instance.isActive,
  'is_deleted': instance.isDeleted,
};
