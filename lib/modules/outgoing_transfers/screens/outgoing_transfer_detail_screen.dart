import 'package:flutter/material.dart';

import '../../../core/utils/ui_labels.dart';
import '../../../core/widgets/simple_detail_screen.dart';
import '../models/outgoing_transfer.dart';

class OutgoingTransferDetailScreen extends StatelessWidget {
  const OutgoingTransferDetailScreen({
    super.key,
    required this.outgoingTransfer,
  });

  final OutgoingTransfer outgoingTransfer;

  @override
  Widget build(BuildContext context) {
    return SimpleDetailScreen(
      title: outgoingTransfer.studentName,
      rows: [
        DetailRow(label: 'ID', value: '${outgoingTransfer.id}'),
        DetailRow(
          label: 'Trường chuyển đến',
          value: outgoingTransfer.destinationSchool,
        ),
        DetailRow(
          label: 'Ngày chuyển trường',
          value: outgoingTransfer.transferDate,
        ),
        DetailRow(label: 'Lý do', value: outgoingTransfer.reason),
        DetailRow(label: 'Ghi chú', value: outgoingTransfer.note),
        DetailRow(
          label: 'Trạng thái',
          value: UiLabels.status(outgoingTransfer.status),
        ),
      ],
    );
  }
}
