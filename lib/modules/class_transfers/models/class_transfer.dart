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
    this.fromClassId = 0,
    this.appliedAt = '',
    this.status = 'Pending',
    this.note = '',
    this.requesterName = '',
  });

  @JsonKey(name: 'request_id')
  final int id;
  final int studentId;
  @JsonKey(readValue: _readStudentName)
  final String studentName;
  @JsonKey(readValue: _readFromClassName)
  final String fromClassName;
  @JsonKey(readValue: _readFromClassId, defaultValue: 0)
  final int fromClassId;
  final int toClassId;
  @JsonKey(readValue: _readToClassName)
  final String toClassName;
  final String reason;
  final String effectiveDate;
  @JsonKey(defaultValue: '')
  final String appliedAt;
  @JsonKey(defaultValue: 'Pending')
  final String status;
  @JsonKey(readValue: _readNote)
  final String note;

  /// Display name of requester (web: requester.teacher.full_name).
  @JsonKey(readValue: _readRequesterName, defaultValue: '')
  final String requesterName;

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
    int? fromClassId,
    int? toClassId,
    String? toClassName,
    String? reason,
    String? effectiveDate,
    String? appliedAt,
    String? status,
    String? note,
    String? requesterName,
  }) {
    return ClassTransfer(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      studentName: studentName ?? this.studentName,
      fromClassName: fromClassName ?? this.fromClassName,
      fromClassId: fromClassId ?? this.fromClassId,
      toClassId: toClassId ?? this.toClassId,
      toClassName: toClassName ?? this.toClassName,
      reason: reason ?? this.reason,
      effectiveDate: effectiveDate ?? this.effectiveDate,
      appliedAt: appliedAt ?? this.appliedAt,
      status: status ?? this.status,
      note: note ?? this.note,
      requesterName: requesterName ?? this.requesterName,
    );
  }

  static Object? _readStudentName(Map<dynamic, dynamic> json, String key) {
    final student = json['student'];
    if (student is Map) {
      return student['full_name'] ?? '';
    }
    return json[key] ?? '';
  }

  static Object? _readFromClassName(Map<dynamic, dynamic> json, String key) {
    final fromClass = json['from_class'];
    if (fromClass is Map) {
      return fromClass['class_name'] ?? '';
    }
    return json[key] ?? '';
  }

  static Object? _readFromClassId(Map<dynamic, dynamic> json, String key) {
    final fromClass = json['from_class'];
    if (fromClass is Map) {
      return fromClass['class_id'] ?? 0;
    }
    return json[key] ?? 0;
  }

  static Object? _readToClassName(Map<dynamic, dynamic> json, String key) {
    final toClass = json['to_class'];
    if (toClass is Map) {
      return toClass['class_name'] ?? '';
    }
    return json[key] ?? '';
  }

  static Object? _readNote(Map<dynamic, dynamic> json, String key) {
    return json['review_note'] ?? json[key] ?? '';
  }

  static Object? _readRequesterName(Map<dynamic, dynamic> json, String key) {
    final requester = json['requester'];
    if (requester is Map) {
      final teacher = requester['teacher'];
      if (teacher is Map) {
        final name = teacher['full_name'];
        if (name != null && '$name'.trim().isNotEmpty) {
          return name;
        }
      }
      final direct = requester['full_name'];
      if (direct != null && '$direct'.trim().isNotEmpty) {
        return direct;
      }
    }
    return json[key] ?? '';
  }
}
