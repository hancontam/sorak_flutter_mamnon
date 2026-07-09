import 'package:flutter/material.dart';

import '../../../core/widgets/simple_detail_screen.dart';
import '../models/class_transfer.dart';

class ClassTransferDetailScreen extends StatelessWidget {
  const ClassTransferDetailScreen({
    super.key,
    required this.classTransfer,
  });

  final ClassTransfer classTransfer;

  @override
  Widget build(BuildContext context) {
    return SimpleDetailScreen(
      title: classTransfer.studentName,
      rows: [
        DetailRow(label: 'ID', value: '${classTransfer.id}'),
        DetailRow(label: 'From class', value: classTransfer.fromClassName),
        DetailRow(label: 'To class', value: classTransfer.toClassName),
        DetailRow(label: 'Reason', value: classTransfer.reason),
        DetailRow(label: 'Effective date', value: classTransfer.effectiveDate),
        DetailRow(label: 'Status', value: classTransfer.status),
      ],
    );
  }
}
