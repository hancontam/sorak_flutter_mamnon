import 'package:json_annotation/json_annotation.dart';

part 'academic_year.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class AcademicYear {
  const AcademicYear({
    required this.id,
    required this.name,
    required this.startDate,
    required this.endDate,
    this.status = 'inactive',
    this.isDeleted = false,
  });

  @JsonKey(name: 'school_year_id')
  final int id;
  final String name;
  @JsonKey(defaultValue: '')
  final String startDate;
  @JsonKey(defaultValue: '')
  final String endDate;
  @JsonKey(defaultValue: 'inactive')
  final String status;
  @JsonKey(readValue: _readIsDeleted)
  final bool isDeleted;

  factory AcademicYear.fromJson(Map<String, dynamic> json) {
    return _$AcademicYearFromJson(json);
  }

  Map<String, dynamic> toJson() {
    return _$AcademicYearToJson(this);
  }

  AcademicYear copyWith({
    int? id,
    String? name,
    String? startDate,
    String? endDate,
    String? status,
    bool? isDeleted,
  }) {
    return AcademicYear(
      id: id ?? this.id,
      name: name ?? this.name,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      status: status ?? this.status,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }

  static Object? _readIsDeleted(Map<dynamic, dynamic> json, String key) {
    return json['is_deleted'] == true || json['deleted_at'] != null;
  }
}
