// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'school_class.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ClassTeacher _$ClassTeacherFromJson(Map<String, dynamic> json) => ClassTeacher(
  id: (json['teacher_id'] as num).toInt(),
  accountId: (json['account_id'] as num).toInt(),
  fullName: json['full_name'] as String,
  position: json['position'] as String? ?? '',
);

Map<String, dynamic> _$ClassTeacherToJson(ClassTeacher instance) =>
    <String, dynamic>{
      'teacher_id': instance.id,
      'account_id': instance.accountId,
      'full_name': instance.fullName,
      'position': instance.position,
    };

SchoolClass _$SchoolClassFromJson(Map<String, dynamic> json) => SchoolClass(
  id: (json['class_id'] as num).toInt(),
  className: json['class_name'] as String,
  schoolYearId: (json['school_year_id'] as num).toInt(),
  ageGroup: json['age_group'] as String? ?? '',
  room: json['room'] as String? ?? '',
  teacherName:
      SchoolClass._readTeacherName(json, 'teacher_name') as String? ?? '',
  assignedTeachers:
      (SchoolClass._readAssignedTeachers(json, 'assigned_teachers')
              as List<dynamic>?)
          ?.map((e) => ClassTeacher.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  studentCount:
      (SchoolClass._readStudentCount(json, 'student_count') as num?)?.toInt() ??
      0,
  isDeleted: SchoolClass._readIsDeleted(json, 'is_deleted') as bool? ?? false,
);

Map<String, dynamic> _$SchoolClassToJson(SchoolClass instance) =>
    <String, dynamic>{
      'class_id': instance.id,
      'class_name': instance.className,
      'school_year_id': instance.schoolYearId,
      'age_group': instance.ageGroup,
      'room': instance.room,
      'teacher_name': instance.teacherName,
      'assigned_teachers': instance.assignedTeachers,
      'student_count': instance.studentCount,
      'is_deleted': instance.isDeleted,
    };
