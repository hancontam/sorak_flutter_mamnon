import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/widgets/simple_form_screen.dart';
import '../models/health_assessment.dart';
import '../providers/health_assessment_provider.dart';

class HealthAssessmentFormScreen extends StatelessWidget {
  const HealthAssessmentFormScreen({super.key, this.assessment});

  final HealthAssessment? assessment;

  @override
  Widget build(BuildContext context) {
    return SimpleFormScreen(
      title: assessment == null
          ? 'Quick Health Entry'
          : 'Update Health Assessment',
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
          isRequired: false,
        ),
        FormFieldConfig(
          name: 'class_name',
          label: 'Class name',
          isRequired: false,
        ),
        FormFieldConfig(
          name: 'school_year_id',
          label: 'School year ID',
          keyboardType: TextInputType.number,
        ),
        FormFieldConfig(
          name: 'assessment_date',
          label: 'Assessment date (yyyy-mm-dd)',
          keyboardType: TextInputType.datetime,
        ),
        FormFieldConfig(
          name: 'height_cm',
          label: 'Height (cm)',
          keyboardType: TextInputType.numberWithOptions(decimal: true),
        ),
        FormFieldConfig(
          name: 'weight_kg',
          label: 'Weight (kg)',
          keyboardType: TextInputType.numberWithOptions(decimal: true),
        ),
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
        'class_id': assessment?.classId == null
            ? ''
            : assessment!.classId.toString(),
        'class_name': assessment?.className ?? '',
        'school_year_id': assessment?.schoolYearId.toString() ?? '1',
        'assessment_date':
            assessment?.assessmentDate.substring(0, 10) ??
            DateTime.now().toIso8601String().substring(0, 10),
        'height_cm': assessment?.heightCm.toString() ?? '',
        'weight_kg': assessment?.weightKg.toString() ?? '',
        'note': assessment?.note ?? '',
      },
      onSave: (data) {
        final provider = context.read<HealthAssessmentProvider>();
        if (assessment == null) {
          return provider.createItem(data);
        }
        return provider.updateItem(assessment!.id, data);
      },
    );
  }
}
