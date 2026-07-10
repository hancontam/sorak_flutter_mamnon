import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_options.dart';
import '../../../core/widgets/simple_form_screen.dart';
import '../../form_options/providers/form_options_provider.dart';
import '../models/school_class.dart';
import '../providers/class_provider.dart';

class ClassFormScreen extends StatefulWidget {
  const ClassFormScreen({super.key, this.schoolClass});

  final SchoolClass? schoolClass;

  @override
  State<ClassFormScreen> createState() => _ClassFormScreenState();
}

class _ClassFormScreenState extends State<ClassFormScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FormOptionsProvider>().loadInitialOptions();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FormOptionsProvider>(
      builder: (context, optionsProvider, _) {
        final teacherOptions = optionsProvider.workingTeachers.map((teacher) {
          final position = teacher.position.isEmpty
              ? ''
              : ' - ${teacher.position}';
          return AppOption(
            value: '${teacher.accountId}',
            label: '${teacher.fullName}$position',
          );
        }).toList();

        return SimpleFormScreen(
          title: widget.schoolClass == null ? 'Tạo lớp' : 'Cập nhật lớp',
          fields: [
            const FormFieldConfig(name: 'class_name', label: 'Tên lớp'),
            FormFieldConfig(
              name: 'school_year_id',
              label: 'Năm học',
              type: SimpleFormFieldType.dropdown,
              options: _stringOptions(optionsProvider.academicYearOptions),
              hintText: optionsProvider.isLoading
                  ? 'Đang tải...'
                  : 'Chọn năm học',
            ),
            const FormFieldConfig(
              name: 'age_group',
              label: 'Khối',
              type: SimpleFormFieldType.dropdown,
              options: GradeOptions.all,
              hintText: 'Chọn khối',
            ),
            const FormFieldConfig(name: 'room', label: 'Phòng'),
            FormFieldConfig(
              name: 'teacher_account_id',
              label: 'Giáo viên',
              type: SimpleFormFieldType.dropdown,
              options: teacherOptions,
              hintText: optionsProvider.isLoading
                  ? 'Đang tải...'
                  : 'Chọn giáo viên đang làm việc',
              isRequired: false,
            ),
          ],
          initialValues: {
            'class_name': widget.schoolClass?.className ?? '',
            'school_year_id':
                '${widget.schoolClass?.schoolYearId ?? optionsProvider.selectedAcademicYearId ?? ''}',
            'age_group': _normalizeGrade(widget.schoolClass?.ageGroup),
            'room': widget.schoolClass?.room ?? '',
            'teacher_account_id': _teacherAccountId(
              optionsProvider,
              widget.schoolClass?.teacherName,
            ),
          },
          onSave: (data) {
            final provider = context.read<ClassProvider>();
            if (widget.schoolClass == null) {
              return provider.createItem(data);
            }
            return provider.updateItem(widget.schoolClass!.id, data);
          },
        );
      },
    );
  }

  List<AppOption<String>> _stringOptions(List<AppOption<int>> options) {
    return options
        .map(
          (option) => AppOption(value: '${option.value}', label: option.label),
        )
        .toList();
  }

  String _normalizeGrade(String? value) {
    return switch (value?.trim().toLowerCase()) {
      '3-4' || 'mầm' || 'mam' => GradeOptions.mam,
      '4-5' || 'chồi' || 'choi' => GradeOptions.choi,
      '5-6' || 'lá' || 'la' => GradeOptions.la,
      'nhà trẻ' || 'nha tre' => GradeOptions.nursery,
      _ => value ?? '',
    };
  }

  String _teacherAccountId(FormOptionsProvider provider, String? teacherName) {
    if (teacherName == null || teacherName.isEmpty) return '';
    for (final teacher in provider.workingTeachers) {
      if (teacher.fullName == teacherName && teacher.accountId > 0) {
        return '${teacher.accountId}';
      }
    }
    return '';
  }
}
