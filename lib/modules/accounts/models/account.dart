import 'package:json_annotation/json_annotation.dart';

part 'account.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class Account {
  const Account({
    required this.id,
    required this.fullName,
    required this.role,
    this.accountId = 0,
    this.teacherId = 0,
    this.studentId = 0,
    this.email = '',
    this.phone = '',
    this.gender = '',
    this.position = '',
    this.workStatus = '',
    this.studentStatus = '',
    this.className = '',
    this.cardNumber = '',
    this.accountType = 'staff',
    this.isActive = true,
    this.isDeleted = false,
  });

  @JsonKey(readValue: _readId)
  final int id;
  @JsonKey(readValue: _readAccountId)
  final int accountId;
  @JsonKey(readValue: _readTeacherId)
  final int teacherId;
  @JsonKey(readValue: _readStudentId)
  final int studentId;
  final String fullName;
  @JsonKey(defaultValue: '')
  final String email;
  @JsonKey(readValue: _readRole)
  final String role;
  @JsonKey(readValue: _readPhone)
  final String phone;
  @JsonKey(defaultValue: '')
  final String gender;
  @JsonKey(defaultValue: '')
  final String position;
  @JsonKey(readValue: _readWorkStatus)
  final String workStatus;
  @JsonKey(defaultValue: '')
  final String studentStatus;
  @JsonKey(readValue: _readClassName)
  final String className;
  @JsonKey(readValue: _readCardNumber)
  final String cardNumber;
  @JsonKey(defaultValue: 'staff')
  final String accountType;
  @JsonKey(readValue: _readIsActive)
  final bool isActive;
  @JsonKey(readValue: _readIsDeleted)
  final bool isDeleted;

  bool get hasAccount => accountId != 0 || role.toLowerCase() != 'none';

  factory Account.fromJson(Map<String, dynamic> json) {
    return _$AccountFromJson(json);
  }

  Map<String, dynamic> toJson() {
    return _$AccountToJson(this);
  }

  Account copyWith({
    int? id,
    int? accountId,
    int? teacherId,
    int? studentId,
    String? fullName,
    String? email,
    String? role,
    String? phone,
    String? gender,
    String? position,
    String? workStatus,
    String? studentStatus,
    String? className,
    String? cardNumber,
    String? accountType,
    bool? isActive,
    bool? isDeleted,
  }) {
    return Account(
      id: id ?? this.id,
      accountId: accountId ?? this.accountId,
      teacherId: teacherId ?? this.teacherId,
      studentId: studentId ?? this.studentId,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      role: role ?? this.role,
      phone: phone ?? this.phone,
      gender: gender ?? this.gender,
      position: position ?? this.position,
      workStatus: workStatus ?? this.workStatus,
      studentStatus: studentStatus ?? this.studentStatus,
      className: className ?? this.className,
      cardNumber: cardNumber ?? this.cardNumber,
      accountType: accountType ?? this.accountType,
      isActive: isActive ?? this.isActive,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }

  static Object? _readId(Map<dynamic, dynamic> json, String key) {
    return json['account_id'] ??
        json['teacher_id'] ??
        json['student_id'] ??
        json[key] ??
        0;
  }

  static Object? _readAccountId(Map<dynamic, dynamic> json, String key) {
    final account = json['account'];
    if (account is Map) {
      return account['account_id'] ?? 0;
    }
    return json['account_id'] ?? json[key] ?? 0;
  }

  static Object? _readTeacherId(Map<dynamic, dynamic> json, String key) {
    return json['teacher_id'] ?? json[key] ?? 0;
  }

  static Object? _readStudentId(Map<dynamic, dynamic> json, String key) {
    return json['student_id'] ?? json[key] ?? 0;
  }

  static Object? _readRole(Map<dynamic, dynamic> json, String key) {
    final account = json['account'];
    if (account is Map) {
      return account['role'] ?? 'none';
    }
    return json[key] ?? 'none';
  }

  static Object? _readWorkStatus(Map<dynamic, dynamic> json, String key) {
    return json['work_status'] ?? json[key] ?? '';
  }

  static Object? _readPhone(Map<dynamic, dynamic> json, String key) {
    final direct = json['phone'] ?? json['contact_phone'];
    if (direct != null && '$direct'.isNotEmpty) return direct;
    final parents = json['parents'];
    if (parents is List && parents.isNotEmpty && parents.first is Map) {
      return (parents.first as Map)['phone'] ?? '';
    }
    return '';
  }

  static Object? _readClassName(Map<dynamic, dynamic> json, String key) {
    final enrollments = json['enrollments'];
    if (enrollments is List && enrollments.isNotEmpty) {
      final first = enrollments.first;
      if (first is Map && first['class'] is Map) {
        return (first['class'] as Map)['class_name'] ?? '';
      }
    }
    return json['class_name'] ?? json[key] ?? '';
  }

  static Object? _readCardNumber(Map<dynamic, dynamic> json, String key) {
    return json['student_id_card_number'] ?? json[key] ?? '';
  }

  static Object? _readIsActive(Map<dynamic, dynamic> json, String key) {
    final account = json['account'];
    if (account is Map && account['is_active'] is bool) {
      return account['is_active'];
    }
    return json[key] ?? true;
  }

  static Object? _readIsDeleted(Map<dynamic, dynamic> json, String key) {
    return json['is_deleted'] == true || json['deleted_at'] != null;
  }
}
