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
  studentIdCardNumber: json['student_id_card_number'] as String? ?? '',
  gradeLevel: json['grade_level'] as String? ?? '',
  enrollmentDate: json['enrollment_date'] as String? ?? '',
  ethnicity: json['ethnicity'] as String? ?? '',
  nationality: json['nationality'] as String? ?? '',
  religion: json['religion'] as String? ?? '',
  bloodType: json['blood_type'] as String? ?? '',
  birthPlace: json['birth_place'] as String? ?? '',
  currentAddress: json['current_address'] as String? ?? '',
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
  'student_id_card_number': instance.studentIdCardNumber,
  'grade_level': instance.gradeLevel,
  'enrollment_date': instance.enrollmentDate,
  'ethnicity': instance.ethnicity,
  'nationality': instance.nationality,
  'religion': instance.religion,
  'blood_type': instance.bloodType,
  'birth_place': instance.birthPlace,
  'current_address': instance.currentAddress,
  'is_active': instance.isActive,
  'is_deleted': instance.isDeleted,
};
