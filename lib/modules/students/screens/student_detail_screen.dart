import 'package:flutter/material.dart';

import '../../../core/widgets/simple_detail_screen.dart';
import '../models/student.dart';

class StudentDetailScreen extends StatelessWidget {
  const StudentDetailScreen({super.key, required this.student});

  final Student student;

  @override
  Widget build(BuildContext context) {
    return SimpleDetailScreen(
      title: student.fullName,
      rows: [
        DetailRow(label: 'ID', value: '${student.id}'),
        DetailRow(label: 'Date of birth', value: student.dateOfBirth),
        DetailRow(label: 'Gender', value: student.gender),
        DetailRow(label: 'Class', value: student.className),
        DetailRow(label: 'Status', value: student.studentStatus),
        DetailRow(label: 'Phone', value: student.contactPhone),
      ],
    );
  }
}
