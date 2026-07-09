import 'package:flutter/material.dart';

import '../../../core/widgets/simple_detail_screen.dart';
import '../models/academic_year.dart';

class AcademicYearDetailScreen extends StatelessWidget {
  const AcademicYearDetailScreen({
    super.key,
    required this.academicYear,
  });

  final AcademicYear academicYear;

  @override
  Widget build(BuildContext context) {
    return SimpleDetailScreen(
      title: academicYear.name,
      rows: [
        DetailRow(label: 'ID', value: '${academicYear.id}'),
        DetailRow(label: 'Name', value: academicYear.name),
        DetailRow(label: 'Start date', value: academicYear.startDate),
        DetailRow(label: 'End date', value: academicYear.endDate),
        DetailRow(label: 'Status', value: academicYear.status),
      ],
    );
  }
}
