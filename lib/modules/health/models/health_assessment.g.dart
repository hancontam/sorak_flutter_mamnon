// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'health_assessment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HealthAssessment _$HealthAssessmentFromJson(
  Map<String, dynamic> json,
) => HealthAssessment(
  // Live GET /by-class-date may omit school_year_id / assessment_date and
  // can return null numeric fields — never hard-cast null to num.
  id: (json['assessment_id'] as num?)?.toInt() ?? 0,
  studentId: (json['student_id'] as num?)?.toInt() ?? 0,
  schoolYearId: (json['school_year_id'] as num?)?.toInt() ?? 0,
  assessmentDate: json['assessment_date']?.toString() ?? '',
  heightCm: (json['height_cm'] as num?)?.toDouble() ?? 0,
  weightKg: (json['weight_kg'] as num?)?.toDouble() ?? 0,
  classId:
      (HealthAssessment._readClassId(json, 'class_id') as num?)?.toInt() ?? 0,
  studentName:
      HealthAssessment._readStudentName(json, 'student_name') as String? ?? '',
  studentCode:
      HealthAssessment._readStudentCode(json, 'student_code') as String? ?? '',
  className:
      HealthAssessment._readClassName(json, 'class_name') as String? ?? '',
  schoolYearName:
      HealthAssessment._readSchoolYearName(json, 'school_year_name')
          as String? ??
      '',
  bmi: (json['bmi'] as num?)?.toDouble() ?? 0,
  bmiStatus: json['bmi_status'] as String? ?? '',
  heightStatus: json['height_status'] as String? ?? '',
  weightStatus: json['weight_status'] as String? ?? '',
  note: json['note'] as String? ?? '',
  isDeleted:
      HealthAssessment._readIsDeleted(json, 'is_deleted') as bool? ?? false,
);

Map<String, dynamic> _$HealthAssessmentToJson(HealthAssessment instance) =>
    <String, dynamic>{
      'assessment_id': instance.id,
      'student_id': instance.studentId,
      'class_id': instance.classId,
      'school_year_id': instance.schoolYearId,
      'assessment_date': instance.assessmentDate,
      'height_cm': instance.heightCm,
      'weight_kg': instance.weightKg,
      'student_name': instance.studentName,
      'student_code': instance.studentCode,
      'class_name': instance.className,
      'school_year_name': instance.schoolYearName,
      'bmi': instance.bmi,
      'bmi_status': instance.bmiStatus,
      'height_status': instance.heightStatus,
      'weight_status': instance.weightStatus,
      'note': instance.note,
      'is_deleted': instance.isDeleted,
    };
