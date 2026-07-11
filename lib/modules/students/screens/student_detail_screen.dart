import 'package:flutter/material.dart';

import '../../../core/utils/ui_labels.dart';
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
        DetailRow(label: 'Ngày sinh', value: student.dateOfBirth),
        DetailRow(label: 'Giới tính', value: UiLabels.gender(student.gender)),
        DetailRow(label: 'Lớp', value: student.className),
        DetailRow(
          label: 'Trạng thái',
          value: UiLabels.status(student.studentStatus),
        ),
        DetailRow(label: 'Số điện thoại', value: student.contactPhone),
      ],
    );
  }
}
