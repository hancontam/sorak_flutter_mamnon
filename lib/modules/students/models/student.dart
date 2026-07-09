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
    this.studentStatus = 'Dang hoc',
    this.contactPhone = '',
    this.isActive = true,
    this.isDeleted = false,
  });

  final int id;
  final String fullName;
  final String dateOfBirth;
  final String gender;
  final int classId;
  final String className;
  final String studentStatus;
  final String contactPhone;
  final bool isActive;
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
    int? classId,
    String? className,
    String? studentStatus,
    String? contactPhone,
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
      isActive: isActive ?? this.isActive,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }
}
