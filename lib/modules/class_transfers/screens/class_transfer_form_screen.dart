import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_options.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_date_field.dart';
import '../../../core/widgets/app_dropdown_field.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../academic_years/providers/active_academic_year_provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../classes/models/school_class.dart';
import '../../classes/providers/class_provider.dart';
import '../../form_options/providers/form_options_provider.dart';
import '../../students/models/student.dart';
import '../models/class_transfer.dart';
import '../providers/class_transfer_provider.dart';

class ClassTransferFormScreen extends StatefulWidget {
  const ClassTransferFormScreen({super.key, this.classTransfer});

  final ClassTransfer? classTransfer;

  @override
  State<ClassTransferFormScreen> createState() =>
      _ClassTransferFormScreenState();
}

class _ClassTransferFormScreenState extends State<ClassTransferFormScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _reasonController = TextEditingController();
  final TextEditingController _effectiveDateController =
      TextEditingController();

  bool _isSaving = false;
  bool _didApplyInitialValues = false;
  String? _fromClassId;
  String? _studentId;
  String? _toClassId;
  String? _status;

  @override
  void initState() {
    super.initState();
    final item = widget.classTransfer;
    _studentId = item == null ? null : '${item.studentId}';
    _toClassId = item == null ? null : '${item.toClassId}';
    _reasonController.text = item?.reason ?? '';
    _effectiveDateController.text = item?.effectiveDate ?? '';
    _status = item?.status ?? TransferStatusOptions.pending;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadOptionsAndClassScope();
    });
  }

  Future<void> _loadOptionsAndClassScope() async {
    final futures = <Future<void>>[
      context.read<FormOptionsProvider>().loadInitialOptions(),
    ];
    if (_isTeacher(context)) {
      final classProvider = context.read<ClassProvider>();
      final yearId = context.read<ActiveAcademicYearProvider>().selectedYearId;
      futures.add(
        yearId == null
            ? classProvider.loadItems()
            : classProvider.loadForAcademicYear(yearId),
      );
    }
    await Future.wait(futures);
  }

  @override
  void dispose() {
    _reasonController.dispose();
    _effectiveDateController.dispose();
    super.dispose();
  }

  Future<void> _save(
    FormOptionsProvider optionsProvider, {
    required bool isTeacher,
  }) async {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) {
      return;
    }

    final scopedClasses = _scopedClasses(optionsProvider);
    final student = _selectedStudent(optionsProvider, scopedClasses);
    final fromClass = _selectedFromClass(scopedClasses);
    final toClass = _selectedToClass(scopedClasses);
    if (student == null || fromClass == null || toClass == null) {
      return;
    }

    setState(() => _isSaving = true);

    final provider = context.read<ClassTransferProvider>();
    final success = widget.classTransfer == null
        ? await provider.createItem({
            'student_id': _studentId,
            'student_name': student.fullName,
            'from_class_name': fromClass.className,
            'to_class_id': _toClassId,
            'to_class_name': toClass.className,
            'reason': _reasonController.text.trim(),
            'effective_date': _effectiveDateController.text.trim(),
            'status': _status ?? TransferStatusOptions.pending,
          })
        : await provider.updateItem(widget.classTransfer!.id, {
            'action': isTeacher ? 'cancel' : _actionFromStatus(_status),
          });

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
        final isTeacher = _isTeacher(context);
        final isClassScopeLoading =
            isTeacher && context.watch<ClassProvider>().isLoading;
        final scopedClasses = _scopedClasses(optionsProvider);
        _applyInitialValuesAfterOptionsLoaded(optionsProvider, scopedClasses);

        final sourceClassOptions = _classOptions(scopedClasses);
        final studentOptions = _studentOptions(optionsProvider, scopedClasses);
        final targetClassOptions = _targetClassOptions(scopedClasses);

        final selectedFromClassId = _valueIfExists(
          _fromClassId,
          sourceClassOptions,
        );
        final selectedStudentId = _valueIfExists(_studentId, studentOptions);
        final selectedToClassId = _valueIfExists(
          _toClassId,
          targetClassOptions,
        );

        return Scaffold(
          appBar: AppBar(
            title: Text(
              widget.classTransfer == null
                  ? 'Tạo yêu cầu chuyển lớp'
                  : 'Cập nhật yêu cầu chuyển lớp',
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
                if (isClassScopeLoading) ...[
                  const LinearProgressIndicator(minHeight: 2),
                  const SizedBox(height: AppSpacing.sm),
                ],
                AppDropdownField<String>(
                  key: ValueKey('class_transfer_from_$selectedFromClassId'),
                  label: 'Lớp hiện tại *',
                  options: sourceClassOptions,
                  value: selectedFromClassId,
                  hintText: 'Chọn lớp hiện tại',
                  enabled: !isClassScopeLoading,
                  validator: _requiredDropdown('lớp hiện tại'),
                  onChanged: (value) {
                    setState(() {
                      _fromClassId = value;
                      _studentId = null;
                      _toClassId = null;
                    });
                    context.read<FormOptionsProvider>().selectClass(
                      int.tryParse(value ?? ''),
                    );
                  },
                ),
                if (!isClassScopeLoading && scopedClasses.isEmpty) ...[
                  const SizedBox(height: AppSpacing.xs),
                  const _NoCompatibleClassNotice(),
                ],
                const SizedBox(height: AppSpacing.sm),
                AppDropdownField<String>(
                  key: ValueKey(
                    'class_transfer_student_${selectedFromClassId ?? ''}_${selectedStudentId ?? ''}',
                  ),
                  label: 'Học sinh *',
                  options: studentOptions,
                  value: selectedStudentId,
                  hintText: _fromClassId == null
                      ? 'Chọn lớp hiện tại trước'
                      : 'Chọn học sinh',
                  enabled: !isClassScopeLoading && _fromClassId != null,
                  validator: _requiredDropdown('học sinh'),
                  onChanged: (value) {
                    setState(() => _studentId = value);
                  },
                ),
                const SizedBox(height: AppSpacing.sm),
                AppDropdownField<String>(
                  key: ValueKey(
                    'class_transfer_to_${selectedFromClassId ?? ''}_${selectedToClassId ?? ''}',
                  ),
                  label: 'Lớp chuyển đến *',
                  options: targetClassOptions,
                  value: selectedToClassId,
                  hintText: _fromClassId == null
                      ? 'Chọn lớp hiện tại trước'
                      : 'Chọn lớp cùng khối',
                  enabled: !isClassScopeLoading && _fromClassId != null,
                  validator: _requiredDropdown('lớp chuyển đến'),
                  onChanged: (value) {
                    setState(() => _toClassId = value);
                  },
                ),
                if (!isClassScopeLoading &&
                    _fromClassId != null &&
                    targetClassOptions.isEmpty) ...[
                  const SizedBox(height: AppSpacing.xs),
                  const _NoCompatibleClassNotice(
                    message: 'Hiện tại không có lớp cùng khối phù hợp.',
                  ),
                ],
                const SizedBox(height: AppSpacing.sm),
                AppTextField(
                  controller: _reasonController,
                  label: 'Lý do *',
                  maxLines: 2,
                  validator: _requiredText('lý do'),
                ),
                const SizedBox(height: AppSpacing.sm),
                AppDateField(
                  controller: _effectiveDateController,
                  label: 'Ngày hiệu lực *',
                  validator: _requiredText('ngày hiệu lực'),
                ),
                const SizedBox(height: AppSpacing.sm),
                if (!isTeacher)
                  AppDropdownField<String>(
                    key: ValueKey('class_transfer_status_$_status'),
                    label: 'Trạng thái',
                    options: const [
                      AppOption(
                        value: TransferStatusOptions.pending,
                        label: 'Chờ duyệt',
                      ),
                      AppOption(
                        value: TransferStatusOptions.approved,
                        label: 'Đã duyệt',
                      ),
                      AppOption(
                        value: TransferStatusOptions.rejected,
                        label: 'Từ chối',
                      ),
                      AppOption(
                        value: TransferStatusOptions.cancelled,
                        label: 'Đã hủy',
                      ),
                    ],
                    value: _status,
                    hintText: 'Chọn trạng thái',
                    validator: _requiredDropdown('trạng thái'),
                    onChanged: (value) {
                      setState(() => _status = value);
                    },
                  ),
              ],
            ),
          ),
          bottomNavigationBar: _BottomSaveBar(
            isSaving: _isSaving,
            onCancel: () => Navigator.pop(context),
            saveLabel: isTeacher && widget.classTransfer != null
                ? 'Hủy yêu cầu'
                : 'Lưu',
            onSave: () => _save(optionsProvider, isTeacher: isTeacher),
          ),
        );
      },
    );
  }

  void _applyInitialValuesAfterOptionsLoaded(
    FormOptionsProvider optionsProvider,
    List<SchoolClass> scopedClasses,
  ) {
    if (_didApplyInitialValues || scopedClasses.isEmpty) {
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _didApplyInitialValues) {
        return;
      }

      final item = widget.classTransfer;
      SchoolClass? fromClass;
      if (item != null) {
        for (final schoolClass in scopedClasses) {
          if (schoolClass.className == item.fromClassName) {
            fromClass = schoolClass;
            break;
          }
        }
      }

      setState(() {
        _didApplyInitialValues = true;
        if (fromClass != null) {
          _fromClassId = '${fromClass.id}';
        } else {
          final selectedStudent = _selectedStudent(
            optionsProvider,
            scopedClasses,
          );
          if (selectedStudent != null && selectedStudent.classId != 0) {
            _fromClassId = '${selectedStudent.classId}';
          }
        }
      });

      context.read<FormOptionsProvider>().selectClass(
        int.tryParse(_fromClassId ?? ''),
      );
    });
  }

  List<AppOption<String>> _classOptions(List<SchoolClass> classes) {
    return classes
        .map(
          (schoolClass) => AppOption(
            value: '${schoolClass.id}',
            label: _classLabel(schoolClass),
          ),
        )
        .toList();
  }

  List<AppOption<String>> _studentOptions(
    FormOptionsProvider optionsProvider,
    List<SchoolClass> scopedClasses,
  ) {
    final classId = int.tryParse(_fromClassId ?? '');
    final allowedClassIds = scopedClasses
        .map((schoolClass) => schoolClass.id)
        .toSet();
    return optionsProvider.allStudents
        .where(
          (student) =>
              allowedClassIds.contains(student.classId) &&
              (classId == null || student.classId == classId),
        )
        .map(
          (student) => AppOption(
            value: '${student.id}',
            label: '${student.fullName} - ${student.className}',
          ),
        )
        .toList();
  }

  List<AppOption<String>> _targetClassOptions(List<SchoolClass> scopedClasses) {
    final fromClass = _selectedFromClass(scopedClasses);
    if (fromClass == null) {
      return const [];
    }

    return scopedClasses
        .where((schoolClass) {
          return schoolClass.id != fromClass.id &&
              schoolClass.schoolYearId == fromClass.schoolYearId &&
              schoolClass.ageGroup == fromClass.ageGroup;
        })
        .map(
          (schoolClass) => AppOption(
            value: '${schoolClass.id}',
            label: _classLabel(schoolClass),
          ),
        )
        .toList();
  }

  SchoolClass? _selectedFromClass(List<SchoolClass> classes) {
    return _findClass(classes, _fromClassId);
  }

  SchoolClass? _selectedToClass(List<SchoolClass> classes) {
    return _findClass(classes, _toClassId);
  }

  SchoolClass? _findClass(List<SchoolClass> classes, String? id) {
    final classId = int.tryParse(id ?? '');
    if (classId == null) {
      return null;
    }

    for (final schoolClass in classes) {
      if (schoolClass.id == classId) {
        return schoolClass;
      }
    }
    return null;
  }

  Student? _selectedStudent(
    FormOptionsProvider optionsProvider,
    List<SchoolClass> scopedClasses,
  ) {
    final selectedId = int.tryParse(_studentId ?? '');
    if (selectedId == null) {
      return null;
    }

    final allowedClassIds = scopedClasses
        .map((schoolClass) => schoolClass.id)
        .toSet();
    for (final student in optionsProvider.allStudents) {
      if (student.id == selectedId &&
          allowedClassIds.contains(student.classId)) {
        return student;
      }
    }
    return null;
  }

  String? _valueIfExists(String? value, List<AppOption<String>> options) {
    if (options.any((option) => option.value == value)) {
      return value;
    }
    return null;
  }

  String _classLabel(SchoolClass schoolClass) {
    final grade = schoolClass.ageGroup.isEmpty
        ? ''
        : ' - ${schoolClass.ageGroup}';
    return '${schoolClass.className}$grade';
  }

  String _actionFromStatus(String? status) {
    return switch (status) {
      TransferStatusOptions.approved => 'approve',
      TransferStatusOptions.rejected => 'reject',
      TransferStatusOptions.pending => 'revert',
      _ => 'cancel',
    };
  }

  bool _isTeacher(BuildContext context) {
    try {
      return context.read<AuthProvider>().currentUser?.role.toUpperCase() ==
          'TEACHER';
    } on ProviderNotFoundException {
      // Isolated form tests intentionally omit an auth provider.
      return false;
    }
  }

  List<SchoolClass> _scopedClasses(FormOptionsProvider optionsProvider) {
    if (!_isTeacher(context)) {
      return optionsProvider.classes;
    }

    final assignedIds = context
        .watch<ClassProvider>()
        .items
        .map((schoolClass) => schoolClass.id)
        .toSet();
    return optionsProvider.classes
        .where((schoolClass) => assignedIds.contains(schoolClass.id))
        .toList();
  }

  FormFieldValidator<String> _requiredText(String label) {
    return (value) {
      if (value == null || value.trim().isEmpty) {
        return 'Vui lòng nhập $label';
      }
      return null;
    };
  }

  FormFieldValidator<String> _requiredDropdown(String label) {
    return (value) {
      if (value == null || value.trim().isEmpty) {
        return 'Vui lòng chọn $label';
      }
      return null;
    };
  }
}

class _BottomSaveBar extends StatelessWidget {
  const _BottomSaveBar({
    required this.isSaving,
    required this.onCancel,
    required this.onSave,
    this.saveLabel = 'Lưu',
  });

  final bool isSaving;
  final VoidCallback onCancel;
  final VoidCallback onSave;
  final String saveLabel;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
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
                onPressed: isSaving ? null : onCancel,
                child: const Text('Hủy'),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: FilledButton(
                onPressed: isSaving ? null : onSave,
                child: isSaving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(saveLabel),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NoCompatibleClassNotice extends StatelessWidget {
  const _NoCompatibleClassNotice({
    this.message = 'Hiện tại không có lớp phù hợp.',
  });

  final String message;

  @override
  Widget build(BuildContext context) {
    return Text(
      message,
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
        color: AppColors.primary,
        fontWeight: FontWeight.w600,
        fontStyle: FontStyle.italic,
      ),
    );
  }
}
