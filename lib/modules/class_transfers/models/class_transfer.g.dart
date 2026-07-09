// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'class_transfer.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ClassTransfer _$ClassTransferFromJson(Map<String, dynamic> json) =>
    ClassTransfer(
      id: (json['id'] as num).toInt(),
      studentId: (json['student_id'] as num).toInt(),
      studentName: json['student_name'] as String,
      toClassId: (json['to_class_id'] as num).toInt(),
      toClassName: json['to_class_name'] as String,
      reason: json['reason'] as String,
      effectiveDate: json['effective_date'] as String,
      fromClassName: json['from_class_name'] as String? ?? '',
      status: json['status'] as String? ?? 'Pending',
      note: json['note'] as String? ?? '',
    );

Map<String, dynamic> _$ClassTransferToJson(ClassTransfer instance) =>
    <String, dynamic>{
      'id': instance.id,
      'student_id': instance.studentId,
      'student_name': instance.studentName,
      'from_class_name': instance.fromClassName,
      'to_class_id': instance.toClassId,
      'to_class_name': instance.toClassName,
      'reason': instance.reason,
      'effective_date': instance.effectiveDate,
      'status': instance.status,
      'note': instance.note,
    };
