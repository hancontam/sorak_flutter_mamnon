import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_options.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/class_sort.dart';
import '../../../core/utils/student_enrollment.dart';
import '../../../core/widgets/app_date_field.dart';
import '../../../core/widgets/app_dropdown_field.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../classes/models/school_class.dart';
import '../../academic_years/providers/active_academic_year_provider.dart';
import '../../form_options/providers/form_options_provider.dart';
import '../../students/models/student.dart';

class SchoolTransferFormData {
  const SchoolTransferFormData({
    required this.studentId,
    required this.studentName,
    required this.school,
    required this.transferDate,
    required this.reason,
    required this.note,
    required this.status,
  });

  final String studentId;
  final String studentName;
  final String school;
  final String transferDate;
  final String reason;
  final String note;
  final String status;

  Map<String, dynamic> toJson(String schoolField) {
    return {
      'student_id': studentId,
      schoolField: school,
      'transfer_date': transferDate,
      'reason': reason,
      'note': note,
    };
  }
}

class SchoolTransferForm extends StatefulWidget {
  const SchoolTransferForm({
    super.key,
    required this.title,
    required this.schoolLabel,
    required this.schoolField,
    required this.defaultStatus,
    required this.onSave,
    this.errorMessage,
    this.initialStudentId,
    this.initialSchool = '',
    this.initialTransferDate = '',
    this.initialReason = '',
    this.initialNote = '',
    this.initialStatus,
    this.allowInactiveStudents = false,
  });

  final String title;
  final String schoolLabel;
  final String schoolField;
  final String defaultStatus;
  final Future<bool> Function(SchoolTransferFormData data) onSave;
  final String? Function()? errorMessage;
  final int? initialStudentId;
  final String initialSchool;
  final String initialTransferDate;
  final String initialReason;
  final String initialNote;
  final String? initialStatus;
  final bool allowInactiveStudents;

  @override
  State<SchoolTransferForm> createState() => _SchoolTransferFormState();
}

class _SchoolTransferFormState extends State<SchoolTransferForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _schoolController = TextEditingController();
  final TextEditingController _transferDateController = TextEditingController();
  final TextEditingController _reasonController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  bool _isSaving = false;
  bool _didApplyInitialStudent = false;
  String? _selectedClassId;
  String? _selectedStudentId;
  String? _selectedStatus;

  @override
  void initState() {
    super.initState();
    _selectedStudentId = widget.initialStudentId == null
        ? null
        : '${widget.initialStudentId}';
    _schoolController.text = widget.initialSchool;
    _transferDateController.text = widget.initialTransferDate;
    _reasonController.text = widget.initialReason;
    _noteController.text = widget.initialNote;
    _selectedStatus = widget.initialStatus ?? widget.defaultStatus;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final yearId = _activeAcademicYearId();
      context.read<FormOptionsProvider>().refreshForAcademicYear(yearId);
    });
  }

  int? _activeAcademicYearId() {
    try {
      return context.read<ActiveAcademicYearProvider>().selectedYearId;
    } on ProviderNotFoundException {
      return context.read<FormOptionsProvider>().selectedAcademicYearId;
    }
  }

  @override
  void dispose() {
    _schoolController.dispose();
    _transferDateController.dispose();
    _reasonController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _save(FormOptionsProvider optionsProvider) async {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) {
      return;
    }

    final student = _selectedStudent(optionsProvider);
    if (student == null) {
      return;
    }

    setState(() => _isSaving = true);

    final success = await widget.onSave(
      SchoolTransferFormData(
        studentId: _selectedStudentId ?? '',
        studentName: student.fullName,
        school: _schoolController.text.trim(),
        transferDate: _transferDateController.text.trim(),
        reason: _reasonController.text.trim(),
        note: _noteController.text.trim(),
        status: _selectedStatus ?? widget.defaultStatus,
      ),
    );

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
        SnackBar(
          content: Text(
            widget.errorMessage?.call() ??
                'Chưa thể lưu. Vui lòng kiểm tra lại.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FormOptionsProvider>(
      builder: (context, optionsProvider, _) {
        _applyInitialStudentAfterOptionsLoaded(optionsProvider);

        final classOptions = _classOptions(optionsProvider);
        final studentOptions = _studentOptions(optionsProvider);
        final selectedClassId = _valueIfExists(_selectedClassId, classOptions);
        final selectedStudentId = _valueIfExists(
          _selectedStudentId,
          studentOptions,
        );

        return Scaffold(
          appBar: AppBar(title: Text(widget.title)),
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
                AppDropdownField<String>(
                  key: ValueKey('school_transfer_class_$selectedClassId'),
                  label: 'Lớp *',
                  options: classOptions,
                  value: selectedClassId,
                  hintText: 'Chọn lớp',
                  validator: _requiredDropdown('lớp'),
                  onChanged: (value) {
                    setState(() {
                      _selectedClassId = value;
                      _selectedStudentId = null;
                    });
                  },
                ),
                const SizedBox(height: AppSpacing.sm),
                AppDropdownField<String>(
                  key: ValueKey(
                    'school_transfer_student_${selectedClassId ?? ''}_${selectedStudentId ?? ''}',
                  ),
                  label: 'Học sinh *',
                  options: studentOptions,
                  value: selectedStudentId,
                  hintText: _selectedClassId == null
                      ? 'Chọn lớp trước'
                      : 'Chọn học sinh',
                  enabled: _selectedClassId != null,
                  validator: _requiredDropdown('học sinh'),
                  onChanged: (value) {
                    setState(() => _selectedStudentId = value);
                  },
                ),
                const SizedBox(height: AppSpacing.sm),
                AppTextField(
                  controller: _schoolController,
                  label: '${widget.schoolLabel} *',
                  validator: _requiredText(widget.schoolLabel.toLowerCase()),
                ),
                const SizedBox(height: AppSpacing.sm),
                AppDateField(
                  controller: _transferDateController,
                  label: 'Ngày chuyển *',
                  validator: _requiredText('ngày chuyển'),
                ),
                const SizedBox(height: AppSpacing.sm),
                AppTextField(
                  controller: _reasonController,
                  label: 'Lý do',
                  maxLines: 2,
                ),
                const SizedBox(height: AppSpacing.sm),
                AppTextField(
                  controller: _noteController,
                  label: 'Ghi chú',
                  maxLines: 2,
                ),
              ],
            ),
          ),
          bottomNavigationBar: _BottomSaveBar(
            isSaving: _isSaving,
            onCancel: () => Navigator.pop(context),
            onSave: () => _save(optionsProvider),
          ),
        );
      },
    );
  }

  void _applyInitialStudentAfterOptionsLoaded(
    FormOptionsProvider optionsProvider,
  ) {
    if (_didApplyInitialStudent || optionsProvider.allStudents.isEmpty) {
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _didApplyInitialStudent) {
        return;
      }

      final initialStudent = _selectedStudent(optionsProvider);
      setState(() {
        _didApplyInitialStudent = true;
        if (initialStudent != null && initialStudent.classId != 0) {
          _selectedClassId = '${initialStudent.classId}';
        }
      });
    });
  }

  List<AppOption<String>> _classOptions(FormOptionsProvider optionsProvider) {
    return sortedClassesByGrade(optionsProvider.classes)
        .map(
          (schoolClass) => AppOption(
            value: '${schoolClass.id}',
            label: _classLabel(schoolClass),
          ),
        )
        .toList();
  }

  List<AppOption<String>> _studentOptions(FormOptionsProvider optionsProvider) {
    final classId = int.tryParse(_selectedClassId ?? '');
    return optionsProvider.allStudents
        .where(
          (student) =>
              (widget.allowInactiveStudents ||
                  isStudentCurrentlyEnrolled(student)) &&
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

  Student? _selectedStudent(FormOptionsProvider optionsProvider) {
    final studentId = int.tryParse(_selectedStudentId ?? '');
    if (studentId == null) {
      return null;
    }

    for (final student in optionsProvider.allStudents) {
      if (student.id == studentId) {
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
    final room = schoolClass.room.isEmpty ? '' : ' - ${schoolClass.room}';
    return '${schoolClass.className}$room';
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
  });

  final bool isSaving;
  final VoidCallback onCancel;
  final VoidCallback onSave;

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
                    : const Text('Lưu'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
