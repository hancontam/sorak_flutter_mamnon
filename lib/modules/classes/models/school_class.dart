import 'package:json_annotation/json_annotation.dart';

part 'school_class.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class SchoolClass {
  const SchoolClass({
    required this.id,
    required this.className,
    required this.schoolYearId,
    this.ageGroup = '',
    this.room = '',
    this.teacherName = '',
    this.isDeleted = false,
  });

  final int id;
  final String className;
  final int schoolYearId;
  final String ageGroup;
  final String room;
  final String teacherName;
  final bool isDeleted;

  factory SchoolClass.fromJson(Map<String, dynamic> json) {
    return _$SchoolClassFromJson(json);
  }

  Map<String, dynamic> toJson() {
    return _$SchoolClassToJson(this);
  }

  SchoolClass copyWith({
    int? id,
    String? className,
    int? schoolYearId,
    String? ageGroup,
    String? room,
    String? teacherName,
    bool? isDeleted,
  }) {
    return SchoolClass(
      id: id ?? this.id,
      className: className ?? this.className,
      schoolYearId: schoolYearId ?? this.schoolYearId,
      ageGroup: ageGroup ?? this.ageGroup,
      room: room ?? this.room,
      teacherName: teacherName ?? this.teacherName,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }
}
