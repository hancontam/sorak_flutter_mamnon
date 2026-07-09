import 'package:flutter/material.dart';

import '../../../core/widgets/simple_detail_screen.dart';
import '../models/school_class.dart';

class ClassDetailScreen extends StatelessWidget {
  const ClassDetailScreen({super.key, required this.schoolClass});

  final SchoolClass schoolClass;

  @override
  Widget build(BuildContext context) {
    return SimpleDetailScreen(
      title: schoolClass.className,
      rows: [
        DetailRow(label: 'ID', value: '${schoolClass.id}'),
        DetailRow(
          label: 'Academic year ID',
          value: '${schoolClass.schoolYearId}',
        ),
        DetailRow(label: 'Age group', value: schoolClass.ageGroup),
        DetailRow(label: 'Room', value: schoolClass.room),
        DetailRow(label: 'Teacher', value: schoolClass.teacherName),
      ],
    );
  }
}
