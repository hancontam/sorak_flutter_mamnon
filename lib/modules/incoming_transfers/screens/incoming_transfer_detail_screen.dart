import 'package:flutter/material.dart';

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
          label: 'Previous school',
          value: incomingTransfer.previousSchool,
        ),
        DetailRow(label: 'Transfer date', value: incomingTransfer.transferDate),
        DetailRow(label: 'Reason', value: incomingTransfer.reason),
        DetailRow(label: 'Note', value: incomingTransfer.note),
        DetailRow(label: 'Status', value: incomingTransfer.status),
      ],
    );
  }
}
