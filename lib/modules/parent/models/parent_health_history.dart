import 'package:json_annotation/json_annotation.dart';

import '../../health/models/health_assessment.dart';
import '../../students/models/student.dart';

part 'parent_health_history.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class ParentHealthHistory {
  const ParentHealthHistory({required this.student, this.records = const []});

  final Student student;
  @JsonKey(defaultValue: [])
  final List<HealthAssessment> records;

  factory ParentHealthHistory.fromJson(Map<String, dynamic> json) {
    return _$ParentHealthHistoryFromJson(json);
  }

  Map<String, dynamic> toJson() => _$ParentHealthHistoryToJson(this);
}
