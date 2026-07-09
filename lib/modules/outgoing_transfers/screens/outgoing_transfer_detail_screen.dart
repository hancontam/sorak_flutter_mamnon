import 'package:flutter/material.dart';

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
          label: 'Destination school',
          value: outgoingTransfer.destinationSchool,
        ),
        DetailRow(label: 'Transfer date', value: outgoingTransfer.transferDate),
        DetailRow(label: 'Reason', value: outgoingTransfer.reason),
        DetailRow(label: 'Note', value: outgoingTransfer.note),
        DetailRow(label: 'Status', value: outgoingTransfer.status),
      ],
    );
  }
}
