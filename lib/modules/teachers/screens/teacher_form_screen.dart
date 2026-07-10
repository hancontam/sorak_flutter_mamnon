import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_options.dart';
import '../../../core/widgets/simple_form_screen.dart';
import '../models/teacher.dart';
import '../providers/teacher_provider.dart';

class TeacherFormScreen extends StatelessWidget {
  const TeacherFormScreen({super.key, this.teacher});

  final Teacher? teacher;

  @override
  Widget build(BuildContext context) {
    return SimpleFormScreen(
      title: teacher == null ? 'Tạo giáo viên' : 'Cập nhật giáo viên',
      fields: const [
        FormFieldConfig(name: 'full_name', label: 'Họ và tên'),
        FormFieldConfig(
          name: 'email',
          label: 'Email',
          keyboardType: TextInputType.emailAddress,
        ),
        FormFieldConfig(name: 'position', label: 'Chức vụ'),
        FormFieldConfig(
          name: 'phone',
          label: 'Số điện thoại',
          keyboardType: TextInputType.phone,
        ),
        FormFieldConfig(
          name: 'gender',
          label: 'Giới tính',
          type: SimpleFormFieldType.dropdown,
          options: GenderOptions.teacher,
          hintText: 'Chọn giới tính',
        ),
        FormFieldConfig(
          name: 'work_status',
          label: 'Trạng thái làm việc',
          type: SimpleFormFieldType.dropdown,
          options: TeacherWorkStatusOptions.all,
          hintText: 'Chọn trạng thái',
        ),
      ],
      initialValues: {
        'full_name': teacher?.fullName ?? '',
        'email': teacher?.email ?? '',
        'position': teacher?.position ?? 'Giáo viên',
        'phone': teacher?.phone ?? '',
        'gender': _normalizeGender(teacher?.gender),
        'work_status': _normalizeWorkStatus(teacher?.workStatus),
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

  String _normalizeGender(String? value) {
    return switch (value?.trim().toLowerCase()) {
      'male' || 'nam' => GenderOptions.male,
      'female' || 'nu' || 'nữ' => GenderOptions.female,
      'other' || 'khác' || 'khac' => GenderOptions.other,
      _ => value ?? '',
    };
  }

  String _normalizeWorkStatus(String? value) {
    return switch (value?.trim().toLowerCase()) {
      'dang lam viec' || 'đang làm việc' => TeacherWorkStatusOptions.working,
      _ => value ?? TeacherWorkStatusOptions.working,
    };
  }
}
