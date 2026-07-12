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
  final TextEditingController _enrollmentDateController =
      TextEditingController();
  final TextEditingController _birthPlaceController = TextEditingController();
  final TextEditingController _ethnicityController = TextEditingController();
  final TextEditingController _nationalityController = TextEditingController();
  final TextEditingController _religionController = TextEditingController();
  final TextEditingController _bloodTypeController = TextEditingController();
  final TextEditingController _currentAddressController =
      TextEditingController();

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
    _dateOfBirthController.text = _dateOnlyForField(student?.dateOfBirth);
    _contactPhoneController.text = student?.contactPhone ?? '';
    _enrollmentDateController.text = _dateOnlyForField(student?.enrollmentDate);
    _birthPlaceController.text = student?.birthPlace ?? '';
    _ethnicityController.text = student?.ethnicity ?? '';
    _nationalityController.text = student?.nationality ?? '';
    _religionController.text = student?.religion ?? '';
    _bloodTypeController.text = student?.bloodType ?? '';
    _currentAddressController.text = student?.currentAddress ?? '';
    _selectedGender = _normalizeGender(student?.gender);
    _selectedClassId = student?.classId == null || student!.classId == 0
        ? null
        : '${student.classId}';
    _selectedStatus = _normalizeStudentStatus(student?.studentStatus);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FormOptionsProvider>().loadInitialOptions();
    });
  }

  String _dateOnlyForField(String? raw) {
    final value = raw?.trim() ?? '';
    if (value.isEmpty) {
      return '';
    }

    final parsed = DateTime.tryParse(value);
    if (parsed == null) {
      return value.length >= 10 ? value.substring(0, 10) : value;
    }

    final month = parsed.month.toString().padLeft(2, '0');
    final day = parsed.day.toString().padLeft(2, '0');
    return '${parsed.year}-$month-$day';
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _dateOfBirthController.dispose();
    _contactPhoneController.dispose();
    _enrollmentDateController.dispose();
    _birthPlaceController.dispose();
    _ethnicityController.dispose();
    _nationalityController.dispose();
    _religionController.dispose();
    _bloodTypeController.dispose();
    _currentAddressController.dispose();
    super.dispose();
  }

  Future<void> _save(FormOptionsProvider optionsProvider) async {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) {
      return;
    }

    setState(() => _isSaving = true);

    final data = <String, dynamic>{
      'full_name': _fullNameController.text.trim(),
      'date_of_birth': _dateOfBirthController.text.trim(),
      'gender': _selectedGender ?? GenderOptions.male,
      'contact_phone': _contactPhoneController.text.trim(),
      'student_status': _selectedStatus ?? StudentStatusOptions.studying,
      'enrollment_date': _enrollmentDateController.text.trim(),
      'birth_place': _birthPlaceController.text.trim(),
      'ethnicity': _ethnicityController.text.trim(),
      'nationality': _nationalityController.text.trim(),
      'religion': _religionController.text.trim(),
      'blood_type': _bloodTypeController.text.trim(),
      'current_address': _currentAddressController.text.trim(),
    };
    if (widget.student == null) {
      final selectedClass = _selectedClass(optionsProvider);
      data.addAll({
        'grade_level': _selectedGrade ?? '',
        'class_id': _selectedClassId ?? '',
        'class_name': selectedClass?.className ?? '',
      });
    }

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
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.md,
                AppSpacing.md,
                96,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _SectionTitle(
                    title: 'Thông tin cơ bản',
                    subtitle:
                        'Các trường có dấu * là bắt buộc. Các trường còn lại có thể bỏ trống.',
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  AppTextField(
                    controller: _fullNameController,
                    label: 'Họ tên *',
                    validator: _requiredValidator('họ tên'),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  AppDateField(
                    controller: _dateOfBirthController,
                    label: 'Ngày sinh *',
                    firstDate: DateTime(2015),
                    lastDate: DateTime.now(),
                    validator: _requiredValidator('ngày sinh'),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  AppDropdownField<String>(
                    key: ValueKey('student_gender_${_selectedGender ?? ''}'),
                    label: 'Giới tính *',
                    options: GenderOptions.student,
                    value: _selectedGender,
                    hintText: 'Chọn giới tính',
                    validator: _dropdownRequiredValidator('giới tính'),
                    onChanged: (value) {
                      setState(() => _selectedGender = value);
                    },
                  ),
                  if (widget.student == null) ...[
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
                      label: 'Lớp (tùy chọn)',
                      options: classOptions,
                      value: selectedClassId,
                      hintText: _selectedGrade == null
                          ? 'Chọn khối trước'
                          : optionsProvider.isLoading
                          ? 'Đang tải lớp...'
                          : 'Chọn lớp',
                      enabled:
                          _selectedGrade != null && !optionsProvider.isLoading,
                      onChanged: (value) {
                        setState(() => _selectedClassId = value);
                      },
                    ),
                  ] else ...[
                    const SizedBox(height: AppSpacing.sm),
                    _EnrollmentReadOnlyCard(
                      className: widget.student?.className ?? '',
                    ),
                  ],
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
                    onChanged: (value) {
                      setState(() => _selectedStatus = value);
                    },
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  const _SectionTitle(
                    title: 'Nhập học và liên hệ',
                    subtitle: 'Có thể bổ sung sau nếu chưa đủ thông tin.',
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  AppDateField(
                    controller: _enrollmentDateController,
                    label: 'Ngày nhập học',
                    firstDate: DateTime(2015),
                    lastDate: DateTime(DateTime.now().year + 1, 12, 31),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  AppTextField(
                    controller: _birthPlaceController,
                    label: 'Nơi sinh',
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  AppTextField(
                    controller: _currentAddressController,
                    label: 'Địa chỉ hiện tại',
                    maxLines: 2,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  const _SectionTitle(
                    title: 'Thông tin bổ sung',
                    subtitle: 'Dùng để hoàn thiện hồ sơ trẻ.',
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  AppTextField(
                    controller: _ethnicityController,
                    label: 'Dân tộc',
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  AppTextField(
                    controller: _nationalityController,
                    label: 'Quốc tịch',
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  AppTextField(
                    controller: _religionController,
                    label: 'Tôn giáo',
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  AppTextField(
                    controller: _bloodTypeController,
                    label: 'Nhóm máu',
                  ),
                ],
              ),
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

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            color: AppColors.foreground,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          subtitle,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppColors.mutedForeground,
            height: 1.35,
          ),
        ),
      ],
    );
  }
}

class _EnrollmentReadOnlyCard extends StatelessWidget {
  const _EnrollmentReadOnlyCard({required this.className});

  final String className;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.muted,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(AppSpacing.radius),
      ),
      child: Text(
        className.trim().isEmpty
            ? 'Chưa có lớp. Dùng Chuyển lớp để xếp lớp cho trẻ.'
            : 'Lớp hiện tại: $className. Dùng Chuyển lớp để thay đổi lớp.',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: AppColors.secondaryForeground,
          fontWeight: FontWeight.w600,
          height: 1.35,
        ),
      ),
    );
  }
}
