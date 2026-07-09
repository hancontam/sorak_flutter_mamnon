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
    this.workStatus = 'Dang lam viec',
    this.isDeleted = false,
  });

  final int id;
  final String fullName;
  final String email;
  final String position;
  final String phone;
  final String gender;
  final String workStatus;
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
      workStatus: workStatus ?? this.workStatus,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }
}
