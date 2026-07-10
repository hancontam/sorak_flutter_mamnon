// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'student.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Student _$StudentFromJson(Map<String, dynamic> json) => Student(
  id: (json['student_id'] as num).toInt(),
  fullName: json['full_name'] as String,
  dateOfBirth: json['date_of_birth'] as String,
  gender: json['gender'] as String,
  classId: (Student._readClassId(json, 'class_id') as num?)?.toInt() ?? 0,
  className: Student._readClassName(json, 'class_name') as String? ?? '',
  studentStatus: json['student_status'] as String? ?? 'Đang học',
  contactPhone: json['contact_phone'] as String? ?? '',
  isActive: Student._readIsActive(json, 'is_active') as bool? ?? true,
  isDeleted: Student._readIsDeleted(json, 'is_deleted') as bool? ?? false,
);

Map<String, dynamic> _$StudentToJson(Student instance) => <String, dynamic>{
  'student_id': instance.id,
  'full_name': instance.fullName,
  'date_of_birth': instance.dateOfBirth,
  'gender': instance.gender,
  'class_id': instance.classId,
  'class_name': instance.className,
  'student_status': instance.studentStatus,
  'contact_phone': instance.contactPhone,
  'is_active': instance.isActive,
  'is_deleted': instance.isDeleted,
};
