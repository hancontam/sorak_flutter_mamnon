import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/widgets/simple_form_screen.dart';
import '../models/student.dart';
import '../providers/student_provider.dart';

class StudentFormScreen extends StatelessWidget {
  const StudentFormScreen({super.key, this.student});

  final Student? student;

  @override
  Widget build(BuildContext context) {
    return SimpleFormScreen(
      title: student == null ? 'Create Student' : 'Update Student',
      fields: const [
        FormFieldConfig(name: 'full_name', label: 'Full name'),
        FormFieldConfig(
          name: 'date_of_birth',
          label: 'Date of birth (YYYY-MM-DD)',
        ),
        FormFieldConfig(name: 'gender', label: 'Gender'),
        FormFieldConfig(
          name: 'class_id',
          label: 'Class ID',
          keyboardType: TextInputType.number,
        ),
        FormFieldConfig(name: 'class_name', label: 'Class name'),
        FormFieldConfig(
          name: 'contact_phone',
          label: 'Contact phone',
          keyboardType: TextInputType.phone,
        ),
        FormFieldConfig(name: 'student_status', label: 'Student status'),
      ],
      initialValues: {
        'full_name': student?.fullName ?? '',
        'date_of_birth': student?.dateOfBirth ?? '',
        'gender': student?.gender ?? 'Nam',
        'class_id': '${student?.classId ?? 1}',
        'class_name': student?.className ?? '',
        'contact_phone': student?.contactPhone ?? '',
        'student_status': student?.studentStatus ?? 'Dang hoc',
      },
      onSave: (data) {
        final provider = context.read<StudentProvider>();
        if (student == null) {
          return provider.createItem(data);
        }
        return provider.updateItem(student!.id, data);
      },
    );
  }
}
