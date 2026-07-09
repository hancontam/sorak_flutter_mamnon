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

  @JsonKey(name: 'class_id')
  final int id;
  final String className;
  final int schoolYearId;
  @JsonKey(defaultValue: '')
  final String ageGroup;
  @JsonKey(defaultValue: '')
  final String room;
  @JsonKey(readValue: _readTeacherName)
  final String teacherName;
  @JsonKey(readValue: _readIsDeleted)
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

  static Object? _readTeacherName(Map<dynamic, dynamic> json, String key) {
    final teacherClasses = json['teacher_classes'];
    if (teacherClasses is List && teacherClasses.isNotEmpty) {
      final first = teacherClasses.first;
      if (first is Map && first['teacher'] is Map) {
        return (first['teacher'] as Map)['full_name'] ?? '';
      }
    }
    return json[key] ?? '';
  }

  static Object? _readIsDeleted(Map<dynamic, dynamic> json, String key) {
    return json['is_deleted'] == true || json['deleted_at'] != null;
  }
}
