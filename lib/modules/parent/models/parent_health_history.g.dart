// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'parent_health_history.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ParentHealthHistory _$ParentHealthHistoryFromJson(Map<String, dynamic> json) =>
    ParentHealthHistory(
      student: Student.fromJson(json['student'] as Map<String, dynamic>),
      records:
          (json['records'] as List<dynamic>?)
              ?.map((e) => HealthAssessment.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );

Map<String, dynamic> _$ParentHealthHistoryToJson(
  ParentHealthHistory instance,
) => <String, dynamic>{
  'student': instance.student.toJson(),
  'records': instance.records.map((e) => e.toJson()).toList(),
};
