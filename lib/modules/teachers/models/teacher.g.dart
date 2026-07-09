// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'teacher.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Teacher _$TeacherFromJson(Map<String, dynamic> json) => Teacher(
  id: (json['id'] as num).toInt(),
  fullName: json['full_name'] as String,
  email: json['email'] as String,
  position: json['position'] as String,
  phone: json['phone'] as String? ?? '',
  gender: json['gender'] as String? ?? '',
  workStatus: json['work_status'] as String? ?? 'Dang lam viec',
  isDeleted: json['is_deleted'] as bool? ?? false,
);

Map<String, dynamic> _$TeacherToJson(Teacher instance) => <String, dynamic>{
  'id': instance.id,
  'full_name': instance.fullName,
  'email': instance.email,
  'position': instance.position,
  'phone': instance.phone,
  'gender': instance.gender,
  'work_status': instance.workStatus,
  'is_deleted': instance.isDeleted,
};
