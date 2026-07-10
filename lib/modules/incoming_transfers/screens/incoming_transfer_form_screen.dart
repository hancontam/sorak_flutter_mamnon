import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../transfers/widgets/school_transfer_form.dart';
import '../models/incoming_transfer.dart';
import '../providers/incoming_transfer_provider.dart';

class IncomingTransferFormScreen extends StatelessWidget {
  const IncomingTransferFormScreen({super.key, this.incomingTransfer});

  final IncomingTransfer? incomingTransfer;

  @override
  Widget build(BuildContext context) {
    return SchoolTransferForm(
      title: incomingTransfer == null
          ? 'Ghi nhận chuyển trường đến'
          : 'Cập nhật chuyển trường đến',
      schoolLabel: 'Trường chuyển từ',
      schoolField: 'previous_school',
      defaultStatus: 'Recorded',
      initialStudentId: incomingTransfer?.studentId,
      initialSchool: incomingTransfer?.previousSchool ?? '',
      initialTransferDate: incomingTransfer?.transferDate ?? '',
      initialReason: incomingTransfer?.reason ?? '',
      initialNote: incomingTransfer?.note ?? '',
      initialStatus: incomingTransfer?.status,
      onSave: (formData) {
        final provider = context.read<IncomingTransferProvider>();
        final data = formData.toJson('previous_school');
        if (incomingTransfer == null) {
          return provider.createItem(data);
        }
        return provider.updateItem(incomingTransfer!.id, data);
      },
    );
  }
}
