import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/widgets/simple_form_screen.dart';
import '../../academic_years/providers/active_academic_year_provider.dart';
import '../models/nutrition_assessment.dart';
import '../providers/nutrition_assessment_provider.dart';

class NutritionAssessmentFormScreen extends StatelessWidget {
  const NutritionAssessmentFormScreen({super.key, this.assessment});

  final NutritionAssessment? assessment;

  @override
  Widget build(BuildContext context) {
    final selectedYearId = context
        .watch<ActiveAcademicYearProvider>()
        .selectedYearId;
    return SimpleFormScreen(
      title: assessment == null
          ? 'Tạo đánh giá nuôi dưỡng'
          : 'Cập nhật đánh giá nuôi dưỡng',
      fields: const [
        FormFieldConfig(
          name: 'student_id',
          label: 'Mã trẻ',
          keyboardType: TextInputType.number,
        ),
        FormFieldConfig(name: 'student_name', label: 'Tên trẻ'),
        FormFieldConfig(
          name: 'class_id',
          label: 'Mã lớp',
          keyboardType: TextInputType.number,
        ),
        FormFieldConfig(name: 'class_name', label: 'Tên lớp'),
        FormFieldConfig(
          name: 'school_year_id',
          label: 'Mã năm học',
          keyboardType: TextInputType.number,
        ),
        FormFieldConfig(name: 'period', label: 'Mã giai đoạn'),
        FormFieldConfig(
          name: 'weight_channel',
          label: 'Kênh cân nặng',
          isRequired: false,
        ),
        FormFieldConfig(name: 'is_stunting', label: 'Thấp còi (true/false)'),
        FormFieldConfig(
          name: 'is_severe_stunting',
          label: 'Thấp còi nặng (true/false)',
        ),
        FormFieldConfig(name: 'is_obese', label: 'Béo phì (true/false)'),
        FormFieldConfig(
          name: 'note',
          label: 'Ghi chú',
          maxLines: 3,
          isRequired: false,
        ),
      ],
      initialValues: {
        'student_id': assessment?.studentId.toString() ?? '',
        'student_name': assessment?.studentName ?? '',
        'class_id': assessment?.classId.toString() ?? '',
        'class_name': assessment?.className ?? '',
        'school_year_id':
            assessment?.schoolYearId.toString() ??
            selectedYearId?.toString() ??
            '',
        'period': assessment?.period ?? 'dau_nam',
        'weight_channel': assessment?.weightChannel ?? '',
        'is_stunting': assessment?.isStunting.toString() ?? 'false',
        'is_severe_stunting':
            assessment?.isSevereStunting.toString() ?? 'false',
        'is_obese': assessment?.isObese.toString() ?? 'false',
        'note': assessment?.note ?? '',
      },
      onSave: (data) {
        final provider = context.read<NutritionAssessmentProvider>();
        if (assessment == null) {
          return provider.createItem(data);
        }
        return provider.updateItem(assessment!.id, data);
      },
    );
  }
}
