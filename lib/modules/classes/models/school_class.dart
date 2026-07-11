import 'package:json_annotation/json_annotation.dart';

part 'school_class.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class ClassTeacher {
  const ClassTeacher({
    required this.id,
    required this.accountId,
    required this.fullName,
    this.position = '',
  });

  @JsonKey(name: 'teacher_id')
  final int id;
  final int accountId;
  final String fullName;
  @JsonKey(defaultValue: '')
  final String position;

  factory ClassTeacher.fromJson(Map<String, dynamic> json) {
    return _$ClassTeacherFromJson(json);
  }

  Map<String, dynamic> toJson() => _$ClassTeacherToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class SchoolClass {
  const SchoolClass({
    required this.id,
    required this.className,
    required this.schoolYearId,
    this.ageGroup = '',
    this.room = '',
    this.teacherName = '',
    this.assignedTeachers = const [],
    this.studentCount = 0,
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
  @JsonKey(readValue: _readAssignedTeachers)
  final List<ClassTeacher> assignedTeachers;
  @JsonKey(readValue: _readStudentCount)
  final int studentCount;
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
    List<ClassTeacher>? assignedTeachers,
    int? studentCount,
    bool? isDeleted,
  }) {
    return SchoolClass(
      id: id ?? this.id,
      className: className ?? this.className,
      schoolYearId: schoolYearId ?? this.schoolYearId,
      ageGroup: ageGroup ?? this.ageGroup,
      room: room ?? this.room,
      teacherName: teacherName ?? this.teacherName,
      assignedTeachers: assignedTeachers ?? this.assignedTeachers,
      studentCount: studentCount ?? this.studentCount,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }

  static Object? _readTeacherName(Map<dynamic, dynamic> json, String key) {
    final teacherClasses = json['teacher_classes'];
    if (teacherClasses is List) {
      final names = <String>[];
      for (final item in teacherClasses) {
        if (item is Map && item['teacher'] is Map) {
          final name = '${(item['teacher'] as Map)['full_name'] ?? ''}'.trim();
          if (name.isNotEmpty) {
            names.add(name);
          }
        }
      }
      if (names.isNotEmpty) return names.join(', ');
    }
    return json[key] ?? '';
  }

  static Object? _readAssignedTeachers(Map<dynamic, dynamic> json, String key) {
    final teacherClasses = json['teacher_classes'];
    if (teacherClasses is! List) return const <Map<String, dynamic>>[];

    return teacherClasses
        .whereType<Map>()
        .map((item) => item['teacher'])
        .whereType<Map>()
        .map((teacher) => Map<String, dynamic>.from(teacher))
        .toList();
  }

  static Object? _readStudentCount(Map<dynamic, dynamic> json, String key) {
    final count = json['_count'];
    if (count is Map && count['enrollments'] is num) {
      return (count['enrollments'] as num).toInt();
    }
    if (json['student_count'] is num) {
      return (json['student_count'] as num).toInt();
    }
    if (json['enrollment_count'] is num) {
      return (json['enrollment_count'] as num).toInt();
    }
    return 0;
  }

  static Object? _readIsDeleted(Map<dynamic, dynamic> json, String key) {
    return json['is_deleted'] == true || json['deleted_at'] != null;
  }
}
