import 'package:flutter/material.dart';

import '../../../core/utils/ui_labels.dart';
import '../../../core/widgets/simple_detail_screen.dart';
import '../models/academic_year.dart';

class AcademicYearDetailScreen extends StatelessWidget {
  const AcademicYearDetailScreen({super.key, required this.academicYear});

  final AcademicYear academicYear;

  @override
  Widget build(BuildContext context) {
    return SimpleDetailScreen(
      title: academicYear.name,
      rows: [
        DetailRow(label: 'ID', value: '${academicYear.id}'),
        DetailRow(label: 'Tên năm học', value: academicYear.name),
        DetailRow(label: 'Ngày bắt đầu', value: academicYear.startDate),
        DetailRow(label: 'Ngày kết thúc', value: academicYear.endDate),
        DetailRow(
          label: 'Trạng thái',
          value: UiLabels.status(academicYear.status),
        ),
      ],
    );
  }
}
