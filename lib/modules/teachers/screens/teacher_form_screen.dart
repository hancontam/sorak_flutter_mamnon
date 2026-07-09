import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/widgets/simple_form_screen.dart';
import '../models/teacher.dart';
import '../providers/teacher_provider.dart';

class TeacherFormScreen extends StatelessWidget {
  const TeacherFormScreen({super.key, this.teacher});

  final Teacher? teacher;

  @override
  Widget build(BuildContext context) {
    return SimpleFormScreen(
      title: teacher == null ? 'Create Teacher' : 'Update Teacher',
      fields: const [
        FormFieldConfig(name: 'full_name', label: 'Full name'),
        FormFieldConfig(
          name: 'email',
          label: 'Email',
          keyboardType: TextInputType.emailAddress,
        ),
        FormFieldConfig(name: 'position', label: 'Position'),
        FormFieldConfig(
          name: 'phone',
          label: 'Phone',
          keyboardType: TextInputType.phone,
        ),
        FormFieldConfig(name: 'gender', label: 'Gender'),
        FormFieldConfig(name: 'work_status', label: 'Work status'),
      ],
      initialValues: {
        'full_name': teacher?.fullName ?? '',
        'email': teacher?.email ?? '',
        'position': teacher?.position ?? 'Teacher',
        'phone': teacher?.phone ?? '',
        'gender': teacher?.gender ?? '',
        'work_status': teacher?.workStatus ?? 'Dang lam viec',
      },
      onSave: (data) {
        final provider = context.read<TeacherProvider>();
        if (teacher == null) {
          return provider.createItem(data);
        }
        return provider.updateItem(teacher!.id, data);
      },
    );
  }
}
