import 'package:flutter/material.dart';

import '../../../core/utils/ui_labels.dart';
import '../../../core/widgets/simple_detail_screen.dart';
import '../models/incoming_transfer.dart';

class IncomingTransferDetailScreen extends StatelessWidget {
  const IncomingTransferDetailScreen({
    super.key,
    required this.incomingTransfer,
  });

  final IncomingTransfer incomingTransfer;

  @override
  Widget build(BuildContext context) {
    return SimpleDetailScreen(
      title: incomingTransfer.studentName,
      rows: [
        DetailRow(label: 'ID', value: '${incomingTransfer.id}'),
        DetailRow(
          label: 'Trường chuyển đến từ',
          value: incomingTransfer.previousSchool,
        ),
        DetailRow(
          label: 'Ngày chuyển trường',
          value: incomingTransfer.transferDate,
        ),
        DetailRow(label: 'Lý do', value: incomingTransfer.reason),
        DetailRow(label: 'Ghi chú', value: incomingTransfer.note),
        DetailRow(
          label: 'Trạng thái',
          value: UiLabels.status(incomingTransfer.status),
        ),
      ],
    );
  }
}
