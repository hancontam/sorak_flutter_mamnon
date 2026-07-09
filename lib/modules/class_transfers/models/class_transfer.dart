import 'package:json_annotation/json_annotation.dart';

part 'class_transfer.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class ClassTransfer {
  const ClassTransfer({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.toClassId,
    required this.toClassName,
    required this.reason,
    required this.effectiveDate,
    this.fromClassName = '',
    this.status = 'Pending',
    this.note = '',
  });

  final int id;
  final int studentId;
  final String studentName;
  final String fromClassName;
  final int toClassId;
  final String toClassName;
  final String reason;
  final String effectiveDate;
  final String status;
  final String note;

  factory ClassTransfer.fromJson(Map<String, dynamic> json) {
    return _$ClassTransferFromJson(json);
  }

  Map<String, dynamic> toJson() {
    return _$ClassTransferToJson(this);
  }

  ClassTransfer copyWith({
    int? id,
    int? studentId,
    String? studentName,
    String? fromClassName,
    int? toClassId,
    String? toClassName,
    String? reason,
    String? effectiveDate,
    String? status,
    String? note,
  }) {
    return ClassTransfer(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      studentName: studentName ?? this.studentName,
      fromClassName: fromClassName ?? this.fromClassName,
      toClassId: toClassId ?? this.toClassId,
      toClassName: toClassName ?? this.toClassName,
      reason: reason ?? this.reason,
      effectiveDate: effectiveDate ?? this.effectiveDate,
      status: status ?? this.status,
      note: note ?? this.note,
    );
  }
}
