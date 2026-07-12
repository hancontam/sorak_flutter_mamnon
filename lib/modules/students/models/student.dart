import 'package:json_annotation/json_annotation.dart';

part 'student.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class Student {
  const Student({
    required this.id,
    required this.fullName,
    required this.dateOfBirth,
    required this.gender,
    this.classId = 0,
    this.className = '',
    this.studentStatus = 'Đang học',
    this.contactPhone = '',
    this.parents = const [],
    this.studentIdCardNumber = '',
    this.gradeLevel = '',
    this.enrollmentDate = '',
    this.ethnicity = '',
    this.nationality = '',
    this.religion = '',
    this.bloodType = '',
    this.birthPlace = '',
    this.currentAddress = '',
    this.isActive = true,
    this.isDeleted = false,
  });

  @JsonKey(name: 'student_id')
  final int id;
  final String fullName;
  final String dateOfBirth;
  final String gender;
  @JsonKey(readValue: _readClassId)
  final int classId;
  @JsonKey(readValue: _readClassName)
  final String className;
  @JsonKey(defaultValue: 'Đang học')
  final String studentStatus;
  @JsonKey(defaultValue: '')
  final String contactPhone;
  @JsonKey(defaultValue: [])
  final List<StudentParent> parents;
  @JsonKey(name: 'student_id_card_number', defaultValue: '')
  final String studentIdCardNumber;
  @JsonKey(defaultValue: '')
  final String gradeLevel;
  @JsonKey(defaultValue: '')
  final String enrollmentDate;
  @JsonKey(defaultValue: '')
  final String ethnicity;
  @JsonKey(defaultValue: '')
  final String nationality;
  @JsonKey(defaultValue: '')
  final String religion;
  @JsonKey(defaultValue: '')
  final String bloodType;
  @JsonKey(defaultValue: '')
  final String birthPlace;
  @JsonKey(defaultValue: '')
  final String currentAddress;
  @JsonKey(readValue: _readIsActive)
  final bool isActive;
  @JsonKey(readValue: _readIsDeleted)
  final bool isDeleted;

  factory Student.fromJson(Map<String, dynamic> json) {
    return _$StudentFromJson(json);
  }

  Map<String, dynamic> toJson() {
    return _$StudentToJson(this);
  }

  Student copyWith({
    int? id,
    String? fullName,
    String? dateOfBirth,
    String? gender,
    String? studentIdCardNumber,
    int? classId,
    String? className,
    String? studentStatus,
    String? contactPhone,
    List<StudentParent>? parents,
    String? gradeLevel,
    String? enrollmentDate,
    String? ethnicity,
    String? nationality,
    String? religion,
    String? bloodType,
    String? birthPlace,
    String? currentAddress,
    bool? isActive,
    bool? isDeleted,
  }) {
    return Student(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      classId: classId ?? this.classId,
      className: className ?? this.className,
      studentStatus: studentStatus ?? this.studentStatus,
      contactPhone: contactPhone ?? this.contactPhone,
      parents: parents ?? this.parents,
      studentIdCardNumber: studentIdCardNumber ?? this.studentIdCardNumber,
      gradeLevel: gradeLevel ?? this.gradeLevel,
      enrollmentDate: enrollmentDate ?? this.enrollmentDate,
      ethnicity: ethnicity ?? this.ethnicity,
      nationality: nationality ?? this.nationality,
      religion: religion ?? this.religion,
      bloodType: bloodType ?? this.bloodType,
      birthPlace: birthPlace ?? this.birthPlace,
      currentAddress: currentAddress ?? this.currentAddress,
      isActive: isActive ?? this.isActive,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }

  static Object? _readClassId(Map<dynamic, dynamic> json, String key) {
    final enrollments = json['enrollments'];
    if (enrollments is List && enrollments.isNotEmpty) {
      final first = enrollments.first;
      if (first is Map) {
        return first['class_id'] ?? 0;
      }
    }
    return json[key] ?? 0;
  }

  static Object? _readClassName(Map<dynamic, dynamic> json, String key) {
    final enrollments = json['enrollments'];
    if (enrollments is List && enrollments.isNotEmpty) {
      final first = enrollments.first;
      if (first is Map && first['class'] is Map) {
        return (first['class'] as Map)['class_name'] ?? '';
      }
    }
    return json[key] ?? '';
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

@JsonSerializable(fieldRename: FieldRename.snake)
class StudentParent {
  const StudentParent({
    this.id,
    this.fullName = '',
    this.relationship = '',
    this.phone = '',
  });

  @JsonKey(name: 'parent_id')
  final int? id;
  @JsonKey(defaultValue: '')
  final String fullName;
  @JsonKey(defaultValue: '')
  final String relationship;
  @JsonKey(defaultValue: '')
  final String phone;

  factory StudentParent.fromJson(Map<String, dynamic> json) {
    return _$StudentParentFromJson(json);
  }

  Map<String, dynamic> toJson() {
    return _$StudentParentToJson(this);
  }
}
