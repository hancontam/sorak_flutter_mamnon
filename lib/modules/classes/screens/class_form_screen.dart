import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_options.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_dropdown_field.dart';
import '../../../core/widgets/app_readonly_field.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/sorak_avatar.dart';
import '../../form_options/providers/form_options_provider.dart';
import '../../teachers/models/teacher.dart';
import '../models/school_class.dart';
import '../providers/class_provider.dart';

class ClassFormScreen extends StatefulWidget {
  const ClassFormScreen({super.key, this.schoolClass});

  final SchoolClass? schoolClass;

  @override
  State<ClassFormScreen> createState() => _ClassFormScreenState();
}

class _ClassFormScreenState extends State<ClassFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _classNameController = TextEditingController();
  final _roomController = TextEditingController();
  final _assignedTeachers = <ClassTeacher>[];
  final _originalTeacherIds = <int>{};
  final _teacherIdsToRemove = <int>{};
  final _teacherAccountIdsToAdd = <int>{};

  String? _selectedYearId;
  String? _selectedAgeGroup;
  String? _selectedTeacherAccountId;
  bool _isSaving = false;
  bool _didApplyDefaultYear = false;

  bool get _isEditing => widget.schoolClass != null;

  @override
  void initState() {
    super.initState();
    final schoolClass = widget.schoolClass;
    _classNameController.text = schoolClass?.className ?? '';
    _roomController.text = schoolClass?.room ?? '';
    _selectedYearId = schoolClass == null
        ? null
        : '${schoolClass.schoolYearId}';
    _selectedAgeGroup = _normalizeGrade(schoolClass?.ageGroup);
    _assignedTeachers.addAll(schoolClass?.assignedTeachers ?? const []);
    _originalTeacherIds.addAll(_assignedTeachers.map((teacher) => teacher.id));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FormOptionsProvider>().loadInitialOptions();
    });
  }

  @override
  void dispose() {
    _classNameController.dispose();
    _roomController.dispose();
    super.dispose();
  }

  void _applyDefaultYear(FormOptionsProvider optionsProvider) {
    if (_didApplyDefaultYear || _isEditing || _selectedYearId != null) return;
    final yearId = optionsProvider.selectedAcademicYearId;
    if (yearId == null) return;

    _didApplyDefaultYear = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => _selectedYearId = '$yearId');
    });
  }

  List<Teacher> _availableTeachers(FormOptionsProvider optionsProvider) {
    final assignedAccountIds = _assignedTeachers
        .map((teacher) => teacher.accountId)
        .toSet();
    return optionsProvider.workingTeachers
        .where(
          (teacher) =>
              teacher.accountId > 0 &&
              !assignedAccountIds.contains(teacher.accountId),
        )
        .toList();
  }

  void _addTeacher(List<Teacher> availableTeachers) {
    final accountId = int.tryParse(_selectedTeacherAccountId ?? '');
    if (accountId == null) return;

    Teacher? selectedTeacher;
    for (final teacher in availableTeachers) {
      if (teacher.accountId == accountId) {
        selectedTeacher = teacher;
        break;
      }
    }
    if (selectedTeacher == null) return;

    setState(() {
      _assignedTeachers.add(
        ClassTeacher(
          id: selectedTeacher!.id,
          accountId: selectedTeacher.accountId,
          fullName: selectedTeacher.fullName,
          position: selectedTeacher.position,
        ),
      );
      _teacherAccountIdsToAdd.add(selectedTeacher.accountId);
      _selectedTeacherAccountId = null;
    });
  }

  void _removeTeacher(ClassTeacher teacher) {
    setState(() {
      _assignedTeachers.removeWhere((item) => item.id == teacher.id);
      if (_originalTeacherIds.contains(teacher.id)) {
        _teacherIdsToRemove.add(teacher.id);
      } else {
        _teacherAccountIdsToAdd.remove(teacher.accountId);
      }
    });
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _isSaving = true);

    final provider = context.read<ClassProvider>();
    final ClassSetupResult? createResult;
    final bool success;
    if (_isEditing) {
      createResult = null;
      success = await provider.updateClassSetup(
        classId: widget.schoolClass!.id,
        room: _roomController.text.trim(),
        teacherAccountIdsToAdd: _teacherAccountIdsToAdd.toList(),
        teacherIdsToRemove: _teacherIdsToRemove.toList(),
      );
    } else {
      final teacherAccountId = int.tryParse(_selectedTeacherAccountId ?? '');
      createResult = await provider.createClassSetup(
        classData: {
          'class_name': _classNameController.text.trim(),
          'school_year_id': _selectedYearId ?? '',
          'age_group': _selectedAgeGroup ?? '',
          'room': _roomController.text.trim(),
        },
        teacherAccountId: teacherAccountId,
      );
      success = createResult.isSuccess;
    }

    if (!mounted) return;
    setState(() => _isSaving = false);
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isEditing ? 'Đã cập nhật lớp học' : 'Đã tạo lớp học'),
        ),
      );
      Navigator.pop(context);
      return;
    }
    if (createResult?.isPartialSuccess == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Đã tạo lớp nhưng chưa phân công giáo viên: '
            '${createResult?.errorMessage ?? 'Chưa xác định được lỗi'}',
          ),
        ),
      );
      Navigator.pop(context);
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          provider.classSetupErrorMessage ??
              provider.errorMessage ??
              'Chưa thể lưu. Vui lòng kiểm tra lại.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FormOptionsProvider>(
      builder: (context, optionsProvider, _) {
        _applyDefaultYear(optionsProvider);
        final availableTeachers = _availableTeachers(optionsProvider);
        final teacherOptions = availableTeachers
            .map(
              (teacher) => AppOption(
                value: '${teacher.accountId}',
                label: _teacherLabel(teacher.fullName, teacher.position),
              ),
            )
            .toList();

        return Scaffold(
          appBar: AppBar(title: Text(_isEditing ? 'Cập nhật lớp' : 'Tạo lớp')),
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
                _SectionTitle(
                  title: _isEditing ? 'Thông tin lớp học' : 'Tạo lớp học',
                  subtitle: _isEditing
                      ? 'Tên lớp và khối được giữ nguyên khi cập nhật.'
                      : 'Các trường có dấu * là bắt buộc.',
                ),
                const SizedBox(height: AppSpacing.sm),
                if (_isEditing)
                  AppReadonlyField(
                    label: 'Tên lớp',
                    value: _classNameController.text,
                  )
                else
                  AppTextField(
                    controller: _classNameController,
                    label: 'Tên lớp *',
                    validator: _required('tên lớp'),
                  ),
                const SizedBox(height: AppSpacing.sm),
                if (_isEditing)
                  AppReadonlyField(
                    label: 'Năm học',
                    value: _selectedYearLabel(optionsProvider),
                  )
                else
                  AppDropdownField<String>(
                    key: ValueKey('class_year_${_selectedYearId ?? ''}'),
                    label: 'Năm học *',
                    options: _yearOptions(optionsProvider),
                    value: _selectedYearId,
                    hintText: optionsProvider.isLoading
                        ? 'Đang tải...'
                        : 'Chọn năm học',
                    validator: _required('năm học'),
                    onChanged: (value) =>
                        setState(() => _selectedYearId = value),
                  ),
                const SizedBox(height: AppSpacing.sm),
                if (_isEditing)
                  AppReadonlyField(
                    label: 'Khối',
                    value: _selectedAgeGroup ?? 'Chưa có',
                  )
                else
                  AppDropdownField<String>(
                    key: ValueKey('class_grade_${_selectedAgeGroup ?? ''}'),
                    label: 'Khối',
                    options: GradeOptions.all,
                    value: _selectedAgeGroup,
                    hintText: 'Chọn khối',
                    onChanged: (value) =>
                        setState(() => _selectedAgeGroup = value),
                  ),
                const SizedBox(height: AppSpacing.sm),
                AppTextField(controller: _roomController, label: 'Phòng'),
                const SizedBox(height: AppSpacing.lg),
                _SectionTitle(
                  title: _isEditing
                      ? 'Phân công giáo viên'
                      : 'Giáo viên phụ trách',
                  subtitle: _isEditing
                      ? 'Có thể thêm hoặc hủy phân công giáo viên của lớp.'
                      : 'Có thể phân công sau khi tạo lớp.',
                ),
                const SizedBox(height: AppSpacing.sm),
                if (_isEditing) ...[
                  _AssignedTeacherList(
                    teachers: _assignedTeachers,
                    onRemove: _isSaving ? null : _removeTeacher,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                ],
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: AppDropdownField<String>(
                        key: ValueKey(
                          'class_teacher_${_selectedTeacherAccountId ?? ''}',
                        ),
                        label: _isEditing
                            ? 'Thêm giáo viên'
                            : 'Giáo viên phụ trách',
                        options: teacherOptions,
                        value: _selectedTeacherAccountId,
                        hintText: optionsProvider.isLoading
                            ? 'Đang tải...'
                            : teacherOptions.isEmpty
                            ? 'Không còn giáo viên để phân công'
                            : 'Chọn giáo viên đang làm việc',
                        onChanged: (value) =>
                            setState(() => _selectedTeacherAccountId = value),
                      ),
                    ),
                    if (_isEditing) ...[
                      const SizedBox(width: AppSpacing.xs),
                      IconButton.filledTonal(
                        tooltip: 'Thêm giáo viên vào lớp',
                        onPressed:
                            _isSaving || _selectedTeacherAccountId == null
                            ? null
                            : () => _addTeacher(availableTeachers),
                        icon: const Icon(LucideIcons.plus, size: 20),
                      ),
                    ],
                  ],
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
                      onPressed: _isSaving ? null : _save,
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

  List<AppOption<String>> _yearOptions(FormOptionsProvider provider) {
    return provider.academicYearOptions
        .map((year) => AppOption(value: '${year.value}', label: year.label))
        .toList();
  }

  String _selectedYearLabel(FormOptionsProvider provider) {
    final selectedId = _selectedYearId;
    for (final year in _yearOptions(provider)) {
      if (year.value == selectedId) return year.label;
    }
    return selectedId ?? 'Chưa có';
  }

  String _normalizeGrade(String? value) {
    return switch (value?.trim().toLowerCase()) {
      '3-4' || 'mầm' || 'mam' => GradeOptions.mam,
      '4-5' || 'chồi' || 'choi' => GradeOptions.choi,
      '5-6' || 'lá' || 'la' => GradeOptions.la,
      'nhà trẻ' || 'nha tre' => GradeOptions.nursery,
      _ => value?.trim() ?? '',
    };
  }

  String _teacherLabel(String fullName, String position) {
    return position.trim().isEmpty ? fullName : '$fullName - $position';
  }

  FormFieldValidator<String> _required(String field) {
    return (value) {
      if (value == null || value.trim().isEmpty) {
        return 'Vui lòng nhập $field';
      }
      return null;
    };
  }
}

class _AssignedTeacherList extends StatelessWidget {
  const _AssignedTeacherList({required this.teachers, required this.onRemove});

  final List<ClassTeacher> teachers;
  final ValueChanged<ClassTeacher>? onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.muted,
        borderRadius: BorderRadius.circular(AppSpacing.radius),
        border: Border.all(color: AppColors.border),
      ),
      child: teachers.isEmpty
          ? const Padding(
              padding: EdgeInsets.all(AppSpacing.md),
              child: Center(child: Text('Chưa có giáo viên được phân công')),
            )
          : Column(
              children: [
                for (var index = 0; index < teachers.length; index++) ...[
                  _AssignedTeacherRow(
                    teacher: teachers[index],
                    onRemove: onRemove == null
                        ? null
                        : () => onRemove!(teachers[index]),
                  ),
                  if (index != teachers.length - 1)
                    const Divider(height: 1, color: AppColors.border),
                ],
              ],
            ),
    );
  }
}

class _AssignedTeacherRow extends StatelessWidget {
  const _AssignedTeacherRow({required this.teacher, required this.onRemove});

  final ClassTeacher teacher;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final position = teacher.position.trim().isEmpty
        ? 'Chưa có chức vụ'
        : teacher.position;
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      leading: SorakAvatar(
        seed: teacher.accountId == 0 ? teacher.id : teacher.accountId,
        fallbackLabel: teacher.fullName,
        size: 40,
      ),
      title: Text(
        teacher.fullName,
        style: Theme.of(
          context,
        ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
      ),
      subtitle: Text(position),
      trailing: IconButton(
        tooltip: 'Hủy phân công giáo viên',
        onPressed: onRemove,
        icon: const Icon(LucideIcons.x, size: 20),
      ),
    );
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
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
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
