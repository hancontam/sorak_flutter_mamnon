import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/widgets/simple_form_screen.dart';
import '../models/incoming_transfer.dart';
import '../providers/incoming_transfer_provider.dart';

class IncomingTransferFormScreen extends StatelessWidget {
  const IncomingTransferFormScreen({super.key, this.incomingTransfer});

  final IncomingTransfer? incomingTransfer;

  @override
  Widget build(BuildContext context) {
    return SimpleFormScreen(
      title: incomingTransfer == null
          ? 'Create Incoming Transfer'
          : 'Update Incoming Transfer',
      fields: const [
        FormFieldConfig(
          name: 'student_id',
          label: 'Student ID',
          keyboardType: TextInputType.number,
        ),
        FormFieldConfig(name: 'student_name', label: 'Student name'),
        FormFieldConfig(name: 'previous_school', label: 'Previous school'),
        FormFieldConfig(
          name: 'transfer_date',
          label: 'Transfer date (YYYY-MM-DD)',
        ),
        FormFieldConfig(name: 'reason', label: 'Reason', maxLines: 2),
        FormFieldConfig(name: 'note', label: 'Note', maxLines: 2),
      ],
      initialValues: {
        'student_id': '${incomingTransfer?.studentId ?? 1}',
        'student_name': incomingTransfer?.studentName ?? '',
        'previous_school': incomingTransfer?.previousSchool ?? '',
        'transfer_date': incomingTransfer?.transferDate ?? '',
        'reason': incomingTransfer?.reason ?? '',
        'note': incomingTransfer?.note ?? '',
      },
      onSave: (data) {
        final provider = context.read<IncomingTransferProvider>();
        if (incomingTransfer == null) {
          return provider.createItem(data);
        }
        return provider.updateItem(incomingTransfer!.id, data);
      },
    );
  }
}
