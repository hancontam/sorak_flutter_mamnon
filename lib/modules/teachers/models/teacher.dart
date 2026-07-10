import 'package:json_annotation/json_annotation.dart';

part 'teacher.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class Teacher {
  const Teacher({
    required this.id,
    required this.fullName,
    required this.email,
    required this.position,
    this.phone = '',
    this.gender = '',
    this.accountId = 0,
    this.workStatus = 'Đang làm việc',
    this.isDeleted = false,
  });

  @JsonKey(name: 'teacher_id')
  final int id;
  final String fullName;
  final String email;
  final String position;
  @JsonKey(defaultValue: '')
  final String phone;
  @JsonKey(defaultValue: '')
  final String gender;
  @JsonKey(readValue: _readAccountId)
  final int accountId;
  @JsonKey(defaultValue: 'Đang làm việc')
  final String workStatus;
  @JsonKey(readValue: _readIsDeleted)
  final bool isDeleted;

  factory Teacher.fromJson(Map<String, dynamic> json) {
    return _$TeacherFromJson(json);
  }

  Map<String, dynamic> toJson() {
    return _$TeacherToJson(this);
  }

  Teacher copyWith({
    int? id,
    String? fullName,
    String? email,
    String? position,
    String? phone,
    String? gender,
    int? accountId,
    String? workStatus,
    bool? isDeleted,
  }) {
    return Teacher(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      position: position ?? this.position,
      phone: phone ?? this.phone,
      gender: gender ?? this.gender,
      accountId: accountId ?? this.accountId,
      workStatus: workStatus ?? this.workStatus,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }

  static Object? _readIsDeleted(Map<dynamic, dynamic> json, String key) {
    return json['is_deleted'] == true || json['deleted_at'] != null;
  }

  static Object? _readAccountId(Map<dynamic, dynamic> json, String key) {
    final account = json['account'];
    if (account is Map && account['account_id'] is num) {
      return (account['account_id'] as num).toInt();
    }
    return json['account_id'] ?? 0;
  }
}
