import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/widgets/simple_form_screen.dart';
import '../models/school_class.dart';
import '../providers/class_provider.dart';

class ClassFormScreen extends StatelessWidget {
  const ClassFormScreen({super.key, this.schoolClass});

  final SchoolClass? schoolClass;

  @override
  Widget build(BuildContext context) {
    return SimpleFormScreen(
      title: schoolClass == null ? 'Create Class' : 'Update Class',
      fields: const [
        FormFieldConfig(name: 'class_name', label: 'Class name'),
        FormFieldConfig(
          name: 'school_year_id',
          label: 'Academic year ID',
          keyboardType: TextInputType.number,
        ),
        FormFieldConfig(name: 'age_group', label: 'Age group'),
        FormFieldConfig(name: 'room', label: 'Room'),
        FormFieldConfig(name: 'teacher_name', label: 'Teacher name'),
      ],
      initialValues: {
        'class_name': schoolClass?.className ?? '',
        'school_year_id': '${schoolClass?.schoolYearId ?? 1}',
        'age_group': schoolClass?.ageGroup ?? '',
        'room': schoolClass?.room ?? '',
        'teacher_name': schoolClass?.teacherName ?? '',
      },
      onSave: (data) {
        final provider = context.read<ClassProvider>();
        if (schoolClass == null) {
          return provider.createItem(data);
        }
        return provider.updateItem(schoolClass!.id, data);
      },
    );
  }
}
