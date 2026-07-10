// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Account _$AccountFromJson(Map<String, dynamic> json) => Account(
  id: (Account._readId(json, 'id') as num).toInt(),
  fullName: json['full_name'] as String,
  role: Account._readRole(json, 'role') as String,
  accountId: (Account._readAccountId(json, 'account_id') as num?)?.toInt() ?? 0,
  teacherId: (Account._readTeacherId(json, 'teacher_id') as num?)?.toInt() ?? 0,
  studentId: (Account._readStudentId(json, 'student_id') as num?)?.toInt() ?? 0,
  email: json['email'] as String? ?? '',
  phone: Account._readPhone(json, 'phone') as String? ?? '',
  gender: json['gender'] as String? ?? '',
  position: json['position'] as String? ?? '',
  workStatus: Account._readWorkStatus(json, 'work_status') as String? ?? '',
  studentStatus: json['student_status'] as String? ?? '',
  className: Account._readClassName(json, 'class_name') as String? ?? '',
  cardNumber: Account._readCardNumber(json, 'card_number') as String? ?? '',
  accountType: json['account_type'] as String? ?? 'staff',
  isActive: Account._readIsActive(json, 'is_active') as bool? ?? true,
  isDeleted: Account._readIsDeleted(json, 'is_deleted') as bool? ?? false,
);

Map<String, dynamic> _$AccountToJson(Account instance) => <String, dynamic>{
  'id': instance.id,
  'account_id': instance.accountId,
  'teacher_id': instance.teacherId,
  'student_id': instance.studentId,
  'full_name': instance.fullName,
  'email': instance.email,
  'role': instance.role,
  'phone': instance.phone,
  'gender': instance.gender,
  'position': instance.position,
  'work_status': instance.workStatus,
  'student_status': instance.studentStatus,
  'class_name': instance.className,
  'card_number': instance.cardNumber,
  'account_type': instance.accountType,
  'is_active': instance.isActive,
  'is_deleted': instance.isDeleted,
};
