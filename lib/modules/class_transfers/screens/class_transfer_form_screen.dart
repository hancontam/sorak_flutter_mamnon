import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/widgets/simple_form_screen.dart';
import '../models/class_transfer.dart';
import '../providers/class_transfer_provider.dart';

class ClassTransferFormScreen extends StatelessWidget {
  const ClassTransferFormScreen({super.key, this.classTransfer});

  final ClassTransfer? classTransfer;

  @override
  Widget build(BuildContext context) {
    return SimpleFormScreen(
      title: classTransfer == null
          ? 'Create Class Transfer'
          : 'Update Class Transfer',
      fields: const [
        FormFieldConfig(
          name: 'student_id',
          label: 'Student ID',
          keyboardType: TextInputType.number,
        ),
        FormFieldConfig(name: 'student_name', label: 'Student name'),
        FormFieldConfig(name: 'from_class_name', label: 'From class'),
        FormFieldConfig(
          name: 'to_class_id',
          label: 'To class ID',
          keyboardType: TextInputType.number,
        ),
        FormFieldConfig(name: 'to_class_name', label: 'To class'),
        FormFieldConfig(name: 'reason', label: 'Reason', maxLines: 2),
        FormFieldConfig(
          name: 'effective_date',
          label: 'Effective date (YYYY-MM-DD)',
        ),
      ],
      initialValues: {
        'student_id': '${classTransfer?.studentId ?? 1}',
        'student_name': classTransfer?.studentName ?? '',
        'from_class_name': classTransfer?.fromClassName ?? '',
        'to_class_id': '${classTransfer?.toClassId ?? 2}',
        'to_class_name': classTransfer?.toClassName ?? '',
        'reason': classTransfer?.reason ?? '',
        'effective_date': classTransfer?.effectiveDate ?? '',
      },
      onSave: (data) {
        final provider = context.read<ClassTransferProvider>();
        if (classTransfer == null) {
          return provider.createItem(data);
        }
        return provider.updateItem(classTransfer!.id, {'action': 'cancel'});
      },
    );
  }
}
