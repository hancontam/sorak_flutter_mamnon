// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'incoming_transfer.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

IncomingTransfer _$IncomingTransferFromJson(Map<String, dynamic> json) =>
    IncomingTransfer(
      id: (json['transfer_id'] as num).toInt(),
      studentId: (json['student_id'] as num).toInt(),
      studentName:
          IncomingTransfer._readStudentName(json, 'student_name') as String,
      previousSchool: json['previous_school'] as String,
      transferDate: json['transfer_date'] as String,
      reason: json['reason'] as String? ?? '',
      note: json['note'] as String? ?? '',
      status: json['status'] as String? ?? 'Recorded',
      isDeleted:
          IncomingTransfer._readIsDeleted(json, 'is_deleted') as bool? ?? false,
      className:
          IncomingTransfer._readClassName(json, 'class_name') as String? ?? '',
      schoolYearName:
          IncomingTransfer._readSchoolYearName(json, 'school_year_name')
              as String? ??
          '',
      cardNumber:
          IncomingTransfer._readCardNumber(json, 'card_number') as String? ??
          '',
    );

Map<String, dynamic> _$IncomingTransferToJson(IncomingTransfer instance) =>
    <String, dynamic>{
      'transfer_id': instance.id,
      'student_id': instance.studentId,
      'student_name': instance.studentName,
      'previous_school': instance.previousSchool,
      'transfer_date': instance.transferDate,
      'reason': instance.reason,
      'note': instance.note,
      'status': instance.status,
      'is_deleted': instance.isDeleted,
      'class_name': instance.className,
      'school_year_name': instance.schoolYearName,
      'card_number': instance.cardNumber,
    };
