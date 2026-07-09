import 'package:json_annotation/json_annotation.dart';

part 'incoming_transfer.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class IncomingTransfer {
  const IncomingTransfer({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.previousSchool,
    required this.transferDate,
    this.reason = '',
    this.note = '',
    this.status = 'Recorded',
    this.isDeleted = false,
  });

  @JsonKey(name: 'transfer_id')
  final int id;
  final int studentId;
  @JsonKey(readValue: _readStudentName)
  final String studentName;
  final String previousSchool;
  final String transferDate;
  @JsonKey(defaultValue: '')
  final String reason;
  @JsonKey(defaultValue: '')
  final String note;
  @JsonKey(defaultValue: 'Recorded')
  final String status;
  @JsonKey(readValue: _readIsDeleted)
  final bool isDeleted;

  factory IncomingTransfer.fromJson(Map<String, dynamic> json) {
    return _$IncomingTransferFromJson(json);
  }

  Map<String, dynamic> toJson() {
    return _$IncomingTransferToJson(this);
  }

  IncomingTransfer copyWith({
    int? id,
    int? studentId,
    String? studentName,
    String? previousSchool,
    String? transferDate,
    String? reason,
    String? note,
    String? status,
    bool? isDeleted,
  }) {
    return IncomingTransfer(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      studentName: studentName ?? this.studentName,
      previousSchool: previousSchool ?? this.previousSchool,
      transferDate: transferDate ?? this.transferDate,
      reason: reason ?? this.reason,
      note: note ?? this.note,
      status: status ?? this.status,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }

  static Object? _readStudentName(Map<dynamic, dynamic> json, String key) {
    final student = json['student'];
    if (student is Map) {
      return student['full_name'] ?? '';
    }
    return json[key] ?? '';
  }

  static Object? _readIsDeleted(Map<dynamic, dynamic> json, String key) {
    return json['is_deleted'] == true || json['deleted_at'] != null;
  }
}
