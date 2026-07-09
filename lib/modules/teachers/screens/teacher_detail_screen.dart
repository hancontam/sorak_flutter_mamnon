import 'package:flutter/material.dart';

import '../../../core/widgets/simple_detail_screen.dart';
import '../models/teacher.dart';

class TeacherDetailScreen extends StatelessWidget {
  const TeacherDetailScreen({super.key, required this.teacher});

  final Teacher teacher;

  @override
  Widget build(BuildContext context) {
    return SimpleDetailScreen(
      title: teacher.fullName,
      rows: [
        DetailRow(label: 'ID', value: '${teacher.id}'),
        DetailRow(label: 'Email', value: teacher.email),
        DetailRow(label: 'Position', value: teacher.position),
        DetailRow(label: 'Phone', value: teacher.phone),
        DetailRow(label: 'Gender', value: teacher.gender),
        DetailRow(label: 'Work status', value: teacher.workStatus),
      ],
    );
  }
}
