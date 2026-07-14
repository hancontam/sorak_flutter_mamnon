// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'class_transfer.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ClassTransfer _$ClassTransferFromJson(
  Map<String, dynamic> json,
) => ClassTransfer(
  id: (json['request_id'] as num).toInt(),
  studentId: (json['student_id'] as num).toInt(),
  studentName: ClassTransfer._readStudentName(json, 'student_name') as String,
  toClassId: (json['to_class_id'] as num).toInt(),
  toClassName: ClassTransfer._readToClassName(json, 'to_class_name') as String,
  reason: json['reason'] as String,
  effectiveDate: json['effective_date'] as String,
  fromClassName:
      ClassTransfer._readFromClassName(json, 'from_class_name') as String? ??
      '',
  fromClassId:
      (ClassTransfer._readFromClassId(json, 'from_class_id') as num?)
          ?.toInt() ??
      0,
  appliedAt: json['applied_at'] as String? ?? '',
  status: json['status'] as String? ?? 'Pending',
  note: ClassTransfer._readNote(json, 'note') as String? ?? '',
  requesterName:
      ClassTransfer._readRequesterName(json, 'requester_name') as String? ?? '',
);

Map<String, dynamic> _$ClassTransferToJson(ClassTransfer instance) =>
    <String, dynamic>{
      'request_id': instance.id,
      'student_id': instance.studentId,
      'student_name': instance.studentName,
      'from_class_name': instance.fromClassName,
      'from_class_id': instance.fromClassId,
      'to_class_id': instance.toClassId,
      'to_class_name': instance.toClassName,
      'reason': instance.reason,
      'effective_date': instance.effectiveDate,
      'applied_at': instance.appliedAt,
      'status': instance.status,
      'note': instance.note,
      'requester_name': instance.requesterName,
    };
