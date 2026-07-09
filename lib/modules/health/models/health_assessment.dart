import 'package:json_annotation/json_annotation.dart';

part 'health_assessment.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class HealthAssessment {
  const HealthAssessment({
    required this.id,
    required this.studentId,
    required this.schoolYearId,
    required this.assessmentDate,
    required this.heightCm,
    required this.weightKg,
    this.classId = 0,
    this.studentName = '',
    this.studentCode = '',
    this.className = '',
    this.schoolYearName = '',
    this.bmi = 0,
    this.bmiStatus = '',
    this.heightStatus = '',
    this.weightStatus = '',
    this.note = '',
    this.isDeleted = false,
  });

  @JsonKey(name: 'assessment_id')
  final int id;
  final int studentId;
  @JsonKey(readValue: _readClassId)
  final int classId;
  final int schoolYearId;
  final String assessmentDate;
  final double heightCm;
  final double weightKg;
  @JsonKey(readValue: _readStudentName)
  final String studentName;
  @JsonKey(readValue: _readStudentCode)
  final String studentCode;
  @JsonKey(readValue: _readClassName)
  final String className;
  @JsonKey(readValue: _readSchoolYearName)
  final String schoolYearName;
  @JsonKey(defaultValue: 0)
  final double bmi;
  @JsonKey(defaultValue: '')
  final String bmiStatus;
  @JsonKey(defaultValue: '')
  final String heightStatus;
  @JsonKey(defaultValue: '')
  final String weightStatus;
  @JsonKey(defaultValue: '')
  final String note;
  @JsonKey(readValue: _readIsDeleted)
  final bool isDeleted;

  factory HealthAssessment.fromJson(Map<String, dynamic> json) {
    return _$HealthAssessmentFromJson(json);
  }

  Map<String, dynamic> toJson() {
    return _$HealthAssessmentToJson(this);
  }

  HealthAssessment copyWith({
    int? id,
    int? studentId,
    int? classId,
    int? schoolYearId,
    String? assessmentDate,
    double? heightCm,
    double? weightKg,
    String? studentName,
    String? studentCode,
    String? className,
    String? schoolYearName,
    double? bmi,
    String? bmiStatus,
    String? heightStatus,
    String? weightStatus,
    String? note,
    bool? isDeleted,
  }) {
    return HealthAssessment(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      classId: classId ?? this.classId,
      schoolYearId: schoolYearId ?? this.schoolYearId,
      assessmentDate: assessmentDate ?? this.assessmentDate,
      heightCm: heightCm ?? this.heightCm,
      weightKg: weightKg ?? this.weightKg,
      studentName: studentName ?? this.studentName,
      studentCode: studentCode ?? this.studentCode,
      className: className ?? this.className,
      schoolYearName: schoolYearName ?? this.schoolYearName,
      bmi: bmi ?? this.bmi,
      bmiStatus: bmiStatus ?? this.bmiStatus,
      heightStatus: heightStatus ?? this.heightStatus,
      weightStatus: weightStatus ?? this.weightStatus,
      note: note ?? this.note,
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

  static Object? _readStudentCode(Map<dynamic, dynamic> json, String key) {
    final student = json['student'];
    if (student is Map) {
      return student['student_id_card_number'] ?? '';
    }
    return json[key] ?? '';
  }

  static Object? _readClassId(Map<dynamic, dynamic> json, String key) {
    final schoolClass = json['class'];
    if (schoolClass is Map) {
      return schoolClass['class_id'] ?? 0;
    }
    return json[key] ?? 0;
  }

  static Object? _readClassName(Map<dynamic, dynamic> json, String key) {
    final schoolClass = json['class'];
    if (schoolClass is Map) {
      return schoolClass['class_name'] ?? '';
    }
    return json[key] ?? '';
  }

  static Object? _readSchoolYearName(Map<dynamic, dynamic> json, String key) {
    final schoolYear = json['school_year'];
    if (schoolYear is Map) {
      return schoolYear['name'] ?? '';
    }
    return json[key] ?? '';
  }

  static Object? _readIsDeleted(Map<dynamic, dynamic> json, String key) {
    return json['is_deleted'] == true || json['deleted_at'] != null;
  }
}
