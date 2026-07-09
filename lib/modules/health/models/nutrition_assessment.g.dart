// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'nutrition_assessment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NutritionAssessment _$NutritionAssessmentFromJson(
  Map<String, dynamic> json,
) => NutritionAssessment(
  id: (NutritionAssessment._readId(json, 'id') as num).toInt(),
  studentId: (json['student_id'] as num).toInt(),
  schoolYearId: (json['school_year_id'] as num).toInt(),
  period: json['period'] as String? ?? 'dau_nam',
  classId: (json['class_id'] as num?)?.toInt() ?? 0,
  studentName:
      NutritionAssessment._readStudentName(json, 'student_name') as String? ??
      '',
  studentCode:
      NutritionAssessment._readStudentCode(json, 'student_code') as String? ??
      '',
  className: json['class_name'] as String? ?? '',
  weightChannel: json['weight_channel'] as String? ?? '',
  isStunting: json['is_stunting'] as bool? ?? false,
  isSevereStunting: json['is_severe_stunting'] as bool? ?? false,
  isObese: json['is_obese'] as bool? ?? false,
  latestBmi: (json['latest_bmi'] as num?)?.toDouble() ?? 0,
  latestBmiStatus: json['latest_bmi_status'] as String? ?? '',
  note: json['note'] as String? ?? '',
  isDeleted:
      NutritionAssessment._readIsDeleted(json, 'is_deleted') as bool? ?? false,
);

Map<String, dynamic> _$NutritionAssessmentToJson(
  NutritionAssessment instance,
) => <String, dynamic>{
  'id': instance.id,
  'student_id': instance.studentId,
  'class_id': instance.classId,
  'school_year_id': instance.schoolYearId,
  'period': instance.period,
  'student_name': instance.studentName,
  'student_code': instance.studentCode,
  'class_name': instance.className,
  'weight_channel': instance.weightChannel,
  'is_stunting': instance.isStunting,
  'is_severe_stunting': instance.isSevereStunting,
  'is_obese': instance.isObese,
  'latest_bmi': instance.latestBmi,
  'latest_bmi_status': instance.latestBmiStatus,
  'note': instance.note,
  'is_deleted': instance.isDeleted,
};
