import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/widgets/simple_form_screen.dart';
import '../models/academic_year.dart';
import '../providers/academic_year_provider.dart';

class AcademicYearFormScreen extends StatelessWidget {
  const AcademicYearFormScreen({super.key, this.academicYear});

  final AcademicYear? academicYear;

  @override
  Widget build(BuildContext context) {
    return SimpleFormScreen(
      title: academicYear == null ? 'Tạo năm học' : 'Cập nhật năm học',
      fields: const [
        FormFieldConfig(name: 'name', label: 'Tên năm học (YYYY-YYYY)'),
        FormFieldConfig(name: 'start_date', label: 'Ngày bắt đầu'),
        FormFieldConfig(name: 'end_date', label: 'Ngày kết thúc'),
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
