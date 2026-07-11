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
        FormFieldConfig(
          name: 'start_date',
          label: 'Ngày bắt đầu',
          type: SimpleFormFieldType.date,
        ),
        FormFieldConfig(
          name: 'end_date',
          label: 'Ngày kết thúc',
          type: SimpleFormFieldType.date,
        ),
      ],
      initialValues: {
        'name': academicYear?.name ?? '',
        'start_date': _dateOnly(academicYear?.startDate),
        'end_date': _dateOnly(academicYear?.endDate),
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

/// Normalize API ISO datetime to yyyy-MM-dd for the date picker field.
String _dateOnly(String? raw) {
  final trimmed = (raw ?? '').trim();
  if (trimmed.isEmpty) {
    return '';
  }
  final datePart = trimmed.split(RegExp(r'[T\s]')).first;
  if (datePart.length >= 10) {
    return datePart.substring(0, 10);
  }
  final parsed = DateTime.tryParse(trimmed);
  if (parsed == null) {
    return datePart;
  }
  final month = parsed.month.toString().padLeft(2, '0');
  final day = parsed.day.toString().padLeft(2, '0');
  return '${parsed.year}-$month-$day';
}
