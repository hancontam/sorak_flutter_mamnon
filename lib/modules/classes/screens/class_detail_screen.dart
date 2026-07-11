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
        DetailRow(label: 'Mã năm học', value: '${schoolClass.schoolYearId}'),
        DetailRow(label: 'Khối tuổi', value: schoolClass.ageGroup),
        DetailRow(label: 'Phòng học', value: schoolClass.room),
        DetailRow(label: 'Giáo viên phụ trách', value: schoolClass.teacherName),
      ],
    );
  }
}
