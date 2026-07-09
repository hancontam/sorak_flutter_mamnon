// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'outgoing_transfer.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OutgoingTransfer _$OutgoingTransferFromJson(Map<String, dynamic> json) =>
    OutgoingTransfer(
      id: (json['transfer_id'] as num).toInt(),
      studentId: (json['student_id'] as num).toInt(),
      studentName:
          OutgoingTransfer._readStudentName(json, 'student_name') as String,
      destinationSchool: json['destination_school'] as String,
      transferDate: json['transfer_date'] as String,
      reason: json['reason'] as String? ?? '',
      note: json['note'] as String? ?? '',
      status: json['status'] as String? ?? 'Recorded',
      isDeleted:
          OutgoingTransfer._readIsDeleted(json, 'is_deleted') as bool? ?? false,
    );

Map<String, dynamic> _$OutgoingTransferToJson(OutgoingTransfer instance) =>
    <String, dynamic>{
      'transfer_id': instance.id,
      'student_id': instance.studentId,
      'student_name': instance.studentName,
      'destination_school': instance.destinationSchool,
      'transfer_date': instance.transferDate,
      'reason': instance.reason,
      'note': instance.note,
      'status': instance.status,
      'is_deleted': instance.isDeleted,
    };
