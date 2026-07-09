import 'package:json_annotation/json_annotation.dart';

part 'nutrition_assessment.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class NutritionAssessment {
  const NutritionAssessment({
    required this.id,
    required this.studentId,
    required this.schoolYearId,
    required this.period,
    this.classId = 0,
    this.studentName = '',
    this.studentCode = '',
    this.className = '',
    this.weightChannel = '',
    this.isStunting = false,
    this.isSevereStunting = false,
    this.isObese = false,
    this.latestBmi = 0,
    this.latestBmiStatus = '',
    this.note = '',
    this.isDeleted = false,
  });

  @JsonKey(readValue: _readId)
  final int id;
  final int studentId;
  @JsonKey(defaultValue: 0)
  final int classId;
  final int schoolYearId;
  @JsonKey(defaultValue: 'dau_nam')
  final String period;
  @JsonKey(readValue: _readStudentName)
  final String studentName;
  @JsonKey(readValue: _readStudentCode)
  final String studentCode;
  @JsonKey(defaultValue: '')
  final String className;
  @JsonKey(defaultValue: '')
  final String weightChannel;
  @JsonKey(defaultValue: false)
  final bool isStunting;
  @JsonKey(defaultValue: false)
  final bool isSevereStunting;
  @JsonKey(defaultValue: false)
  final bool isObese;
  @JsonKey(defaultValue: 0)
  final double latestBmi;
  @JsonKey(defaultValue: '')
  final String latestBmiStatus;
  @JsonKey(defaultValue: '')
  final String note;
  @JsonKey(readValue: _readIsDeleted)
  final bool isDeleted;

  factory NutritionAssessment.fromJson(Map<String, dynamic> json) {
    return _$NutritionAssessmentFromJson(json);
  }

  Map<String, dynamic> toJson() {
    return _$NutritionAssessmentToJson(this);
  }

  NutritionAssessment copyWith({
    int? id,
    int? studentId,
    int? classId,
    int? schoolYearId,
    String? period,
    String? studentName,
    String? studentCode,
    String? className,
    String? weightChannel,
    bool? isStunting,
    bool? isSevereStunting,
    bool? isObese,
    double? latestBmi,
    String? latestBmiStatus,
    String? note,
    bool? isDeleted,
  }) {
    return NutritionAssessment(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      classId: classId ?? this.classId,
      schoolYearId: schoolYearId ?? this.schoolYearId,
      period: period ?? this.period,
      studentName: studentName ?? this.studentName,
      studentCode: studentCode ?? this.studentCode,
      className: className ?? this.className,
      weightChannel: weightChannel ?? this.weightChannel,
      isStunting: isStunting ?? this.isStunting,
      isSevereStunting: isSevereStunting ?? this.isSevereStunting,
      isObese: isObese ?? this.isObese,
      latestBmi: latestBmi ?? this.latestBmi,
      latestBmiStatus: latestBmiStatus ?? this.latestBmiStatus,
      note: note ?? this.note,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }

  String get statusSummary {
    final flags = <String>[
      if (weightChannel.isNotEmpty) weightChannel,
      if (isStunting) 'Stunting',
      if (isSevereStunting) 'Severe stunting',
      if (isObese) 'Obese',
    ];
    return flags.isEmpty ? 'Binh thuong' : flags.join(', ');
  }

  static Object? _readId(Map<dynamic, dynamic> json, String key) {
    return json['nutrition_id'] ?? json['student_id'] ?? 0;
  }

  static Object? _readStudentName(Map<dynamic, dynamic> json, String key) {
    return json['student_name'] ?? json['full_name'] ?? '';
  }

  static Object? _readStudentCode(Map<dynamic, dynamic> json, String key) {
    return json['student_code'] ?? json['student_id_card_number'] ?? '';
  }

  static Object? _readIsDeleted(Map<dynamic, dynamic> json, String key) {
    return json['is_deleted'] == true || json['deleted_at'] != null;
  }
}
