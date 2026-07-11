import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_options.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_date_field.dart';
import '../../../core/widgets/app_dropdown_field.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/sorak_avatar.dart';
import '../../../core/widgets/sorak_status_badge.dart';
import '../models/teacher.dart';
import '../providers/teacher_provider.dart';

class TeacherFormScreen extends StatefulWidget {
  const TeacherFormScreen({super.key, this.teacher});

  final Teacher? teacher;

  @override
  State<TeacherFormScreen> createState() => _TeacherFormScreenState();
}

class _TeacherFormScreenState extends State<TeacherFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _positionController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _dateOfBirthController = TextEditingController();
  final _qualificationController = TextEditingController();
  final _workStartDateController = TextEditingController();
  final _addressController = TextEditingController();

  bool _isSaving = false;
  String? _selectedGender;
  String? _selectedWorkStatus;

  @override
  void initState() {
    super.initState();
    final teacher = widget.teacher;
    _fullNameController.text = teacher?.fullName ?? '';
    _positionController.text = teacher?.position ?? '';
    _emailController.text = teacher?.email ?? '';
    _phoneController.text = teacher?.phone ?? '';
    _dateOfBirthController.text = _dateOnlyForField(teacher?.dateOfBirth);
    _qualificationController.text = teacher?.qualification ?? '';
    _workStartDateController.text = _dateOnlyForField(teacher?.workStartDate);
    _addressController.text = teacher?.address ?? '';
    _selectedGender = _normalizeGender(teacher?.gender);
    _selectedWorkStatus = _normalizeWorkStatus(teacher?.workStatus);
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
    _positionController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _dateOfBirthController.dispose();
    _qualificationController.dispose();
    _workStartDateController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    setState(() => _isSaving = true);
    final data = <String, dynamic>{
      'full_name': _fullNameController.text.trim(),
      'position': _positionController.text.trim(),
      'email': _emailController.text.trim(),
      'phone': _phoneController.text.trim(),
      'gender': _selectedGender ?? GenderOptions.other,
      'date_of_birth': _dateOfBirthController.text.trim(),
      'qualification': _qualificationController.text.trim(),
      'work_start_date': _workStartDateController.text.trim(),
      'address': _addressController.text.trim(),
      'work_status': _selectedWorkStatus ?? TeacherWorkStatusOptions.working,
    };
    final provider = context.read<TeacherProvider>();
    final success = widget.teacher == null
        ? await provider.createItem(data)
        : await provider.updateItem(widget.teacher!.id, data);

    if (!mounted) {
      return;
    }
    setState(() => _isSaving = false);
    if (success) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Đã lưu thông tin cán bộ')));
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Chưa thể lưu. Vui lòng kiểm tra lại.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.teacher == null ? 'Tạo cán bộ' : 'Cập nhật cán bộ'),
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
              if (widget.teacher != null) ...[
                _TeacherEditSummary(teacher: widget.teacher!),
                const SizedBox(height: AppSpacing.md),
              ],
              const _FormSectionTitle(
                title: 'Thông tin công tác',
                subtitle:
                    'Các trường có dấu * là bắt buộc. Các trường còn lại có thể bỏ trống.',
              ),
              const SizedBox(height: AppSpacing.sm),
              AppTextField(
                controller: _fullNameController,
                label: 'Họ và tên *',
                validator: _required('họ và tên'),
              ),
              const SizedBox(height: AppSpacing.sm),
              AppTextField(
                controller: _positionController,
                label: 'Chức vụ *',
                validator: _required('chức vụ'),
              ),
              const SizedBox(height: AppSpacing.sm),
              AppDropdownField<String>(
                key: ValueKey('teacher_status_${_selectedWorkStatus ?? ''}'),
                label: 'Trạng thái làm việc',
                options: TeacherWorkStatusOptions.all,
                value: _selectedWorkStatus,
                hintText: 'Chọn trạng thái',
                onChanged: (value) =>
                    setState(() => _selectedWorkStatus = value),
              ),
              const SizedBox(height: AppSpacing.lg),
              const _FormSectionTitle(
                title: 'Liên hệ',
                subtitle: 'Email và số điện thoại để liên lạc khi cần.',
              ),
              const SizedBox(height: AppSpacing.sm),
              AppTextField(
                controller: _emailController,
                label: 'Email *',
                keyboardType: TextInputType.emailAddress,
                validator: _emailValidator,
              ),
              const SizedBox(height: AppSpacing.sm),
              AppTextField(
                controller: _phoneController,
                label: 'Số điện thoại',
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: AppSpacing.sm),
              AppTextField(
                controller: _addressController,
                label: 'Địa chỉ',
                maxLines: 2,
              ),
              const SizedBox(height: AppSpacing.lg),
              const _FormSectionTitle(
                title: 'Thông tin cá nhân',
                subtitle: 'Bổ sung để hồ sơ cán bộ đầy đủ hơn.',
              ),
              const SizedBox(height: AppSpacing.sm),
              AppDropdownField<String>(
                key: ValueKey('teacher_gender_${_selectedGender ?? ''}'),
                label: 'Giới tính',
                options: GenderOptions.teacher,
                value: _selectedGender,
                hintText: 'Chọn giới tính',
                onChanged: (value) => setState(() => _selectedGender = value),
              ),
              const SizedBox(height: AppSpacing.sm),
              AppDateField(
                controller: _dateOfBirthController,
                label: 'Ngày sinh',
                firstDate: DateTime(1940),
                lastDate: DateTime.now(),
              ),
              const SizedBox(height: AppSpacing.sm),
              AppTextField(
                controller: _qualificationController,
                label: 'Trình độ',
              ),
              const SizedBox(height: AppSpacing.sm),
              AppDateField(
                controller: _workStartDateController,
                label: 'Ngày vào làm',
                firstDate: DateTime(1950),
                lastDate: DateTime(DateTime.now().year + 1, 12, 31),
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
                  onPressed: _isSaving ? null : () => Navigator.pop(context),
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
                      : Text(widget.teacher == null ? 'Tạo cán bộ' : 'Lưu'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  FormFieldValidator<String> _required(String label) {
    return (value) {
      if (value == null || value.trim().isEmpty) {
        return 'Vui lòng nhập $label';
      }
      return null;
    };
  }

  String? _emailValidator(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) {
      return 'Vui lòng nhập email';
    }
    if (!email.contains('@')) {
      return 'Email chưa đúng định dạng';
    }
    return null;
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

class _TeacherEditSummary extends StatelessWidget {
  const _TeacherEditSummary({required this.teacher});

  final Teacher teacher;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            SorakAvatar(
              seed: teacher.accountId == 0 ? teacher.id : teacher.accountId,
              fallbackLabel: teacher.fullName,
              size: 56,
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    teacher.fullName,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    teacher.position.isEmpty
                        ? 'Chưa có chức vụ'
                        : teacher.position,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.secondaryForeground,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  SorakStatusBadge(label: teacher.workStatus),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FormSectionTitle extends StatelessWidget {
  const _FormSectionTitle({required this.title, required this.subtitle});

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
