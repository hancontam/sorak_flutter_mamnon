import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/widgets/simple_form_screen.dart';
import '../models/nutrition_assessment.dart';
import '../providers/nutrition_assessment_provider.dart';

class NutritionAssessmentFormScreen extends StatelessWidget {
  const NutritionAssessmentFormScreen({super.key, this.assessment});

  final NutritionAssessment? assessment;

  @override
  Widget build(BuildContext context) {
    return SimpleFormScreen(
      title: assessment == null
          ? 'Create Nutrition Record'
          : 'Update Nutrition Record',
      fields: const [
        FormFieldConfig(
          name: 'student_id',
          label: 'Student ID',
          keyboardType: TextInputType.number,
        ),
        FormFieldConfig(name: 'student_name', label: 'Student name'),
        FormFieldConfig(
          name: 'class_id',
          label: 'Class ID',
          keyboardType: TextInputType.number,
        ),
        FormFieldConfig(name: 'class_name', label: 'Class name'),
        FormFieldConfig(
          name: 'school_year_id',
          label: 'School year ID',
          keyboardType: TextInputType.number,
        ),
        FormFieldConfig(name: 'period', label: 'Period code'),
        FormFieldConfig(
          name: 'weight_channel',
          label: 'Weight channel',
          isRequired: false,
        ),
        FormFieldConfig(name: 'is_stunting', label: 'Stunting (true/false)'),
        FormFieldConfig(
          name: 'is_severe_stunting',
          label: 'Severe stunting (true/false)',
        ),
        FormFieldConfig(name: 'is_obese', label: 'Obese (true/false)'),
        FormFieldConfig(
          name: 'note',
          label: 'Note',
          maxLines: 3,
          isRequired: false,
        ),
      ],
      initialValues: {
        'student_id': assessment?.studentId.toString() ?? '',
        'student_name': assessment?.studentName ?? '',
        'class_id': assessment?.classId.toString() ?? '',
        'class_name': assessment?.className ?? '',
        'school_year_id': assessment?.schoolYearId.toString() ?? '1',
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
