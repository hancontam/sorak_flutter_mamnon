// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'academic_year.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AcademicYear _$AcademicYearFromJson(Map<String, dynamic> json) => AcademicYear(
  id: (json['school_year_id'] as num).toInt(),
  name: json['name'] as String,
  startDate: json['start_date'] as String? ?? '',
  endDate: json['end_date'] as String? ?? '',
  status: json['status'] as String? ?? 'inactive',
  isDeleted: AcademicYear._readIsDeleted(json, 'is_deleted') as bool? ?? false,
);

Map<String, dynamic> _$AcademicYearToJson(AcademicYear instance) =>
    <String, dynamic>{
      'school_year_id': instance.id,
      'name': instance.name,
      'start_date': instance.startDate,
      'end_date': instance.endDate,
      'status': instance.status,
      'is_deleted': instance.isDeleted,
    };
