import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/widgets/simple_form_screen.dart';
import '../models/outgoing_transfer.dart';
import '../providers/outgoing_transfer_provider.dart';

class OutgoingTransferFormScreen extends StatelessWidget {
  const OutgoingTransferFormScreen({
    super.key,
    this.outgoingTransfer,
  });

  final OutgoingTransfer? outgoingTransfer;

  @override
  Widget build(BuildContext context) {
    return SimpleFormScreen(
      title: outgoingTransfer == null ? 'Create Outgoing Transfer' : 'Update Outgoing Transfer',
      fields: const [
        FormFieldConfig(name: 'student_id', label: 'Student ID', keyboardType: TextInputType.number),
        FormFieldConfig(name: 'student_name', label: 'Student name'),
        FormFieldConfig(name: 'destination_school', label: 'Destination school'),
        FormFieldConfig(name: 'transfer_date', label: 'Transfer date (YYYY-MM-DD)'),
        FormFieldConfig(name: 'reason', label: 'Reason', maxLines: 2),
        FormFieldConfig(name: 'note', label: 'Note', maxLines: 2),
      ],
      initialValues: {
        'student_id': '${outgoingTransfer?.studentId ?? 1}',
        'student_name': outgoingTransfer?.studentName ?? '',
        'destination_school': outgoingTransfer?.destinationSchool ?? '',
        'transfer_date': outgoingTransfer?.transferDate ?? '',
        'reason': outgoingTransfer?.reason ?? '',
        'note': outgoingTransfer?.note ?? '',
      },
      onSave: (data) {
        final provider = context.read<OutgoingTransferProvider>();
        if (outgoingTransfer == null) {
          return provider.createItem(data);
        }
        return provider.updateItem(outgoingTransfer!.id, data);
      },
    );
  }
}
