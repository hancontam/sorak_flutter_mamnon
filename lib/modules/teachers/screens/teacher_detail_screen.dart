import 'package:flutter/material.dart';

import '../../../core/utils/ui_labels.dart';
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
        DetailRow(label: 'Chức vụ', value: teacher.position),
        DetailRow(label: 'Số điện thoại', value: teacher.phone),
        DetailRow(label: 'Giới tính', value: UiLabels.gender(teacher.gender)),
        DetailRow(
          label: 'Trạng thái công tác',
          value: UiLabels.workStatus(teacher.workStatus),
        ),
      ],
    );
  }
}
