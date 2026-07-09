import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/widgets/simple_form_screen.dart';
import '../models/academic_year.dart';
import '../providers/academic_year_provider.dart';

class AcademicYearFormScreen extends StatelessWidget {
  const AcademicYearFormScreen({
    super.key,
    this.academicYear,
  });

  final AcademicYear? academicYear;

  @override
  Widget build(BuildContext context) {
    return SimpleFormScreen(
      title: academicYear == null ? 'Create Academic Year' : 'Update Academic Year',
      fields: const [
        FormFieldConfig(name: 'name', label: 'Name (YYYY-YYYY)'),
        FormFieldConfig(name: 'start_date', label: 'Start date (YYYY-MM-DD)'),
        FormFieldConfig(name: 'end_date', label: 'End date (YYYY-MM-DD)'),
      ],
      initialValues: {
        'name': academicYear?.name ?? '',
        'start_date': academicYear?.startDate ?? '',
        'end_date': academicYear?.endDate ?? '',
      },
      onSave: (data) {
        final provider = context.read<AcademicYearProvider>();
        if (academicYear == null) {
          return provider.createItem(data);
        }
        return provider.updateItem(academicYear!.id, data);
      },
    );
  }
}
