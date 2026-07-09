// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'school_class.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SchoolClass _$SchoolClassFromJson(Map<String, dynamic> json) => SchoolClass(
  id: (json['class_id'] as num).toInt(),
  className: json['class_name'] as String,
  schoolYearId: (json['school_year_id'] as num).toInt(),
  ageGroup: json['age_group'] as String? ?? '',
  room: json['room'] as String? ?? '',
  teacherName:
      SchoolClass._readTeacherName(json, 'teacher_name') as String? ?? '',
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
      'is_deleted': instance.isDeleted,
    };
