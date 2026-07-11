import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_options.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_date_field.dart';
import '../../../core/widgets/app_dropdown_field.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../classes/models/school_class.dart';
import '../../form_options/providers/form_options_provider.dart';
import '../models/student.dart';
import '../providers/student_provider.dart';

class StudentFormScreen extends StatefulWidget {
  const StudentFormScreen({super.key, this.student});

  final Student? student;

  @override
  State<StudentFormScreen> createState() => _StudentFormScreenState();
}

class _StudentFormScreenState extends State<StudentFormScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _dateOfBirthController = TextEditingController();
  final TextEditingController _contactPhoneController = TextEditingController();

  bool _isSaving = false;
  bool _didApplyInitialClass = false;
  String? _selectedGender;
  String? _selectedGrade;
  String? _selectedClassId;
  String? _selectedStatus;

  @override
  void initState() {
    super.initState();
    final student = widget.student;
    _fullNameController.text = student?.fullName ?? '';
    _dateOfBirthController.text = student?.dateOfBirth ?? '';
    _contactPhoneController.text = student?.contactPhone ?? '';
    _selectedGender = _normalizeGender(student?.gender);
    _selectedClassId = student?.classId == null || student!.classId == 0
        ? null
        : '${student.classId}';
    _selectedStatus = _normalizeStudentStatus(student?.studentStatus);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FormOptionsProvider>().loadInitialOptions();
    });
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _dateOfBirthController.dispose();
    _contactPhoneController.dispose();
    super.dispose();
  }

  Future<void> _save(FormOptionsProvider optionsProvider) async {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) {
      return;
    }

    setState(() => _isSaving = true);

    final selectedClass = _selectedClass(optionsProvider);
    final data = <String, dynamic>{
      'full_name': _fullNameController.text.trim(),
      'date_of_birth': _dateOfBirthController.text.trim(),
      'gender': _selectedGender ?? GenderOptions.male,
      'grade_level': _selectedGrade ?? '',
      'class_id': _selectedClassId ?? '',
      'class_name': selectedClass?.className ?? '',
      'contact_phone': _contactPhoneController.text.trim(),
      'student_status': _selectedStatus ?? StudentStatusOptions.studying,
    };

    final provider = context.read<StudentProvider>();
    final success = widget.student == null
        ? await provider.createItem(data)
        : await provider.updateItem(widget.student!.id, data);

    if (!mounted) {
      return;
    }

    setState(() => _isSaving = false);

    if (success) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Đã lưu thành công')));
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Chưa thể lưu. Vui lòng kiểm tra lại.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FormOptionsProvider>(
      builder: (context, optionsProvider, _) {
        _applyInitialClassAfterOptionsLoaded(optionsProvider);

        final classOptions = _classOptions(optionsProvider);
        final classIds = classOptions.map((option) => option.value).toSet();
        final selectedClassId = classIds.contains(_selectedClassId)
            ? _selectedClassId
            : null;

        return Scaffold(
          appBar: AppBar(
            title: Text(
              widget.student == null
                  ? 'Tạo hồ sơ học sinh'
                  : 'Cập nhật hồ sơ học sinh',
            ),
          ),
          body: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.md,
                AppSpacing.md,
                96,
              ),
              children: [
                AppTextField(
                  controller: _fullNameController,
                  label: 'Họ tên',
                  validator: _requiredValidator('họ tên'),
                ),
                const SizedBox(height: AppSpacing.sm),
                AppDateField(
                  controller: _dateOfBirthController,
                  label: 'Ngày sinh',
                  firstDate: DateTime(2015),
                  lastDate: DateTime.now(),
                  validator: _requiredValidator('ngày sinh'),
                ),
                const SizedBox(height: AppSpacing.sm),
                AppDropdownField<String>(
                  key: ValueKey('student_gender_${_selectedGender ?? ''}'),
                  label: 'Giới tính',
                  options: GenderOptions.student,
                  value: _selectedGender,
                  hintText: 'Chọn giới tính',
                  validator: _dropdownRequiredValidator('giới tính'),
                  onChanged: (value) {
                    setState(() => _selectedGender = value);
                  },
                ),
                const SizedBox(height: AppSpacing.sm),
                AppDropdownField<String>(
                  key: ValueKey('student_grade_${_selectedGrade ?? ''}'),
                  label: 'Khối',
                  options: GradeOptions.all,
                  value: _selectedGrade,
                  hintText: 'Chọn khối',
                  onChanged: (value) {
                    setState(() {
                      _selectedGrade = value;
                      _selectedClassId = null;
                    });
                  },
                ),
                const SizedBox(height: AppSpacing.sm),
                AppDropdownField<String>(
                  key: ValueKey(
                    'student_class_${_selectedGrade ?? ''}_${selectedClassId ?? ''}',
                  ),
                  label: 'Lớp',
                  options: classOptions,
                  value: selectedClassId,
                  hintText: _selectedGrade == null
                      ? 'Chọn khối trước'
                      : optionsProvider.isLoading
                      ? 'Đang tải lớp...'
                      : 'Chọn lớp',
                  enabled: _selectedGrade != null && !optionsProvider.isLoading,
                  onChanged: (value) {
                    setState(() => _selectedClassId = value);
                  },
                ),
                const SizedBox(height: AppSpacing.sm),
                AppTextField(
                  controller: _contactPhoneController,
                  label: 'SĐT phụ huynh',
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: AppSpacing.sm),
                AppDropdownField<String>(
                  key: ValueKey('student_status_${_selectedStatus ?? ''}'),
                  label: 'Tình trạng học vụ',
                  options: StudentStatusOptions.all,
                  value: _selectedStatus,
                  hintText: 'Chọn tình trạng',
                  validator: _dropdownRequiredValidator('tình trạng học vụ'),
                  onChanged: (value) {
                    setState(() => _selectedStatus = value);
                  },
                ),
              ],
            ),
          ),
          bottomNavigationBar: SafeArea(
            top: false,
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: const BoxDecoration(
                color: AppColors.background,
                border: Border(top: BorderSide(color: AppColors.border)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isSaving
                          ? null
                          : () => Navigator.pop(context),
                      child: const Text('Hủy'),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: FilledButton(
                      onPressed: _isSaving
                          ? null
                          : () => _save(optionsProvider),
                      child: _isSaving
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text('Lưu'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _applyInitialClassAfterOptionsLoaded(
    FormOptionsProvider optionsProvider,
  ) {
    if (_didApplyInitialClass || optionsProvider.classes.isEmpty) {
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _didApplyInitialClass) {
        return;
      }

      final currentClass = _selectedClass(optionsProvider);
      setState(() {
        _didApplyInitialClass = true;
        _selectedGrade ??= currentClass == null
            ? null
            : _normalizeGrade(currentClass.ageGroup);
      });
    });
  }

  List<AppOption<String>> _classOptions(FormOptionsProvider optionsProvider) {
    return optionsProvider.classes
        .where((schoolClass) {
          if (_selectedGrade == null) {
            return false;
          }
          return _normalizeGrade(schoolClass.ageGroup) == _selectedGrade;
        })
        .map((schoolClass) {
          final room = schoolClass.room.isEmpty ? '' : ' - ${schoolClass.room}';
          return AppOption(
            value: '${schoolClass.id}',
            label: '${schoolClass.className}$room',
          );
        })
        .toList();
  }

  SchoolClass? _selectedClass(FormOptionsProvider optionsProvider) {
    final selectedId = int.tryParse(_selectedClassId ?? '');
    if (selectedId == null) {
      return null;
    }

    for (final schoolClass in optionsProvider.classes) {
      if (schoolClass.id == selectedId) {
        return schoolClass;
      }
    }
    return null;
  }

  FormFieldValidator<String> _requiredValidator(String label) {
    return (value) {
      if (value == null || value.trim().isEmpty) {
        return 'Vui lòng nhập $label';
      }
      return null;
    };
  }

  FormFieldValidator<String> _dropdownRequiredValidator(String label) {
    return (value) {
      if (value == null || value.trim().isEmpty) {
        return 'Vui lòng chọn $label';
      }
      return null;
    };
  }

  String _normalizeGender(String? value) {
    return switch (value?.trim().toLowerCase()) {
      'male' || 'nam' => GenderOptions.male,
      'female' || 'nu' || 'nữ' => GenderOptions.female,
      _ => value ?? GenderOptions.male,
    };
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

  String _normalizeStudentStatus(String? value) {
    return switch (value?.trim().toLowerCase()) {
      'dang hoc' || 'đang học' => StudentStatusOptions.studying,
      _ => value ?? StudentStatusOptions.studying,
    };
  }
}
