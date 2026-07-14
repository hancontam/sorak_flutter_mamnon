import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/services/academic_data_refresh_service.dart';
import '../../academic_years/providers/active_academic_year_provider.dart';
import '../../transfers/widgets/school_transfer_form.dart';
import '../models/outgoing_transfer.dart';
import '../providers/outgoing_transfer_provider.dart';

class OutgoingTransferFormScreen extends StatelessWidget {
  const OutgoingTransferFormScreen({super.key, this.outgoingTransfer});

  final OutgoingTransfer? outgoingTransfer;

  @override
  Widget build(BuildContext context) {
    return SchoolTransferForm(
      title: outgoingTransfer == null
          ? 'Ghi nhận chuyển trường đi'
          : 'Cập nhật chuyển trường đi',
      schoolLabel: 'Trường chuyển đến',
      schoolField: 'destination_school',
      defaultStatus: 'Recorded',
      initialStudentId: outgoingTransfer?.studentId,
      initialSchool: outgoingTransfer?.destinationSchool ?? '',
      initialTransferDate: outgoingTransfer?.transferDate ?? '',
      initialReason: outgoingTransfer?.reason ?? '',
      initialNote: outgoingTransfer?.note ?? '',
      initialStatus: outgoingTransfer?.status,
      onSave: (formData) async {
        final provider = context.read<OutgoingTransferProvider>();
        final data = formData.toJson('destination_school');
        if (outgoingTransfer == null) {
          data['school_year_id'] = context
              .read<ActiveAcademicYearProvider>()
              .selectedYearId;
          final success = await provider.createItem(data);
          if (success && context.mounted) {
            await AcademicDataRefreshService.afterEnrollmentMutation(
              context,
              refreshAccounts: true,
            );
          }
          return success;
        }
        final success = await provider.updateItem(outgoingTransfer!.id, data);
        if (success && context.mounted) {
          await AcademicDataRefreshService.afterEnrollmentMutation(
            context,
            refreshAccounts: true,
          );
        }
        return success;
      },
    );
  }
}
