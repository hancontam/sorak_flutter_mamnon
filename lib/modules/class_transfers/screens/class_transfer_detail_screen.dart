import 'package:flutter/material.dart';

import '../../../core/utils/ui_labels.dart';
import '../../../core/widgets/simple_detail_screen.dart';
import '../models/class_transfer.dart';

class ClassTransferDetailScreen extends StatelessWidget {
  const ClassTransferDetailScreen({super.key, required this.classTransfer});

  final ClassTransfer classTransfer;

  @override
  Widget build(BuildContext context) {
    return SimpleDetailScreen(
      title: classTransfer.studentName,
      rows: [
        DetailRow(label: 'ID', value: '${classTransfer.id}'),
        DetailRow(label: 'Lớp hiện tại', value: classTransfer.fromClassName),
        DetailRow(label: 'Lớp chuyển đến', value: classTransfer.toClassName),
        DetailRow(label: 'Lý do', value: classTransfer.reason),
        DetailRow(label: 'Ngày hiệu lực', value: classTransfer.effectiveDate),
        DetailRow(
          label: 'Trạng thái',
          value: UiLabels.status(classTransfer.status),
        ),
      ],
    );
  }
}
