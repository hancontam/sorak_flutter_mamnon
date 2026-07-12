import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/sorak_avatar.dart';
import '../models/student.dart';

/// Presentation-only guardian editor. The existing Student repository has no
/// parents endpoint method, so this screen intentionally does not fake a save.
class StudentGuardianFormScreen extends StatefulWidget {
  const StudentGuardianFormScreen({super.key, required this.student});

  final Student student;

  @override
  State<StudentGuardianFormScreen> createState() =>
      _StudentGuardianFormScreenState();
}

class _StudentGuardianFormScreenState extends State<StudentGuardianFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final List<_GuardianDraft> _guardians;

  @override
  void initState() {
    super.initState();
    _guardians = [_GuardianDraft(phone: widget.student.contactPhone)];
  }

  @override
  void dispose() {
    for (final guardian in _guardians) {
      guardian.dispose();
    }
    super.dispose();
  }

  void _addGuardian() {
    if (_guardians.length >= 2) {
      return;
    }
    setState(() => _guardians.add(_GuardianDraft()));
  }

  void _removeGuardian(int index) {
    if (_guardians.length <= 1) {
      return;
    }
    setState(() {
      final guardian = _guardians.removeAt(index);
      guardian.dispose();
    });
  }

  void _showUnavailableMessage() {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Chưa thể lưu phụ huynh vì luồng API này chưa được nối.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cập nhật phụ huynh')),
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
            _StudentSummary(student: widget.student),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Liên hệ phụ huynh',
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 2),
            Text(
              'Tối đa 2 người liên hệ. Khi thêm phụ huynh, các trường có dấu * là bắt buộc.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.mutedForeground,
                height: 1.35,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            for (var index = 0; index < _guardians.length; index++) ...[
              _GuardianEditorCard(
                index: index,
                draft: _guardians[index],
                canRemove: _guardians.length > 1,
                onChanged: () => setState(() {}),
                onRemove: () => _removeGuardian(index),
              ),
              const SizedBox(height: AppSpacing.sm),
            ],
            if (_guardians.length < 2)
              OutlinedButton.icon(
                key: const ValueKey('add_guardian_button'),
                onPressed: _addGuardian,
                icon: const Icon(LucideIcons.plus, size: 18),
                label: const Text('Thêm phụ huynh'),
              ),
            const SizedBox(height: AppSpacing.md),
            _ApiNotice(),
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
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Hủy'),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: FilledButton(
                  onPressed: _showUnavailableMessage,
                  child: const Text('Lưu'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StudentSummary extends StatelessWidget {
  const _StudentSummary({required this.student});

  final Student student;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            SorakAvatar(
              seed: student.id,
              fallbackLabel: student.fullName,
              size: 48,
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    student.fullName.isEmpty ? 'Trẻ' : student.fullName,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Mã thẻ: ${student.studentIdCardNumber.isEmpty ? 'Chưa có' : student.studentIdCardNumber}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.mutedForeground,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GuardianEditorCard extends StatelessWidget {
  const _GuardianEditorCard({
    required this.index,
    required this.draft,
    required this.canRemove,
    required this.onChanged,
    required this.onRemove,
  });

  final int index;
  final _GuardianDraft draft;
  final bool canRemove;
  final VoidCallback onChanged;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Phụ huynh ${index + 1}',
                    key: ValueKey('guardian_title_${index + 1}'),
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                if (canRemove)
                  IconButton(
                    tooltip: 'Bỏ phụ huynh này',
                    onPressed: onRemove,
                    icon: const Icon(LucideIcons.x, size: 20),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            AppTextField(
              controller: draft.fullNameController,
              label: 'Họ tên phụ huynh *',
              validator: _requiredWhenGuardianHasData(
                draft,
                'họ tên phụ huynh',
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            AppTextField(
              controller: draft.phoneController,
              label: 'Số điện thoại *',
              keyboardType: TextInputType.phone,
              validator: _requiredWhenGuardianHasData(draft, 'số điện thoại'),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Quan hệ với trẻ',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: AppSpacing.xs),
            Wrap(
              spacing: 4,
              runSpacing: 4,
              children: [
                for (final relationship in _relationships)
                  FilterChip(
                    visualDensity: VisualDensity.compact,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    labelPadding: const EdgeInsets.symmetric(horizontal: 2),
                    label: Text(relationship),
                    selected: draft.relationship == relationship,
                    showCheckmark: false,
                    onSelected: (_) {
                      draft.relationship = relationship;
                      onChanged();
                    },
                    backgroundColor: AppColors.popover,
                    selectedColor: AppColors.secondary,
                    side: BorderSide(
                      color: draft.relationship == relationship
                          ? AppColors.input
                          : AppColors.border,
                    ),
                    labelStyle: Theme.of(context).textTheme.labelSmall
                        ?.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                          color: draft.relationship == relationship
                              ? AppColors.foreground
                              : AppColors.secondaryForeground,
                        ),
                  ),
              ],
            ),
            if (draft.relationship == 'Khác') ...[
              const SizedBox(height: AppSpacing.sm),
              AppTextField(
                controller: draft.customRelationshipController,
                label: 'Nhập quan hệ',
              ),
            ],
          ],
        ),
      ),
    );
  }

  static const _relationships = [
    'Cha',
    'Mẹ',
    'Ông nội',
    'Bà nội',
    'Ông ngoại',
    'Bà ngoại',
    'Người giám hộ',
    'Khác',
  ];

  FormFieldValidator<String> _requiredWhenGuardianHasData(
    _GuardianDraft draft,
    String field,
  ) {
    return (value) {
      if (draft.hasEnteredData && (value == null || value.trim().isEmpty)) {
        return 'Vui lòng nhập $field';
      }
      return null;
    };
  }
}

class _ApiNotice extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.muted,
        borderRadius: BorderRadius.circular(AppSpacing.radius),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(LucideIcons.info, size: 18),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Text(
              'Thông tin phụ huynh sẽ được lưu khi luồng API phụ huynh được nối.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.secondaryForeground,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GuardianDraft {
  _GuardianDraft({String phone = ''})
    : fullNameController = TextEditingController(),
      phoneController = TextEditingController(text: phone),
      customRelationshipController = TextEditingController();

  final TextEditingController fullNameController;
  final TextEditingController phoneController;
  final TextEditingController customRelationshipController;
  String relationship = '';

  bool get hasEnteredData =>
      fullNameController.text.trim().isNotEmpty ||
      phoneController.text.trim().isNotEmpty ||
      relationship.isNotEmpty ||
      customRelationshipController.text.trim().isNotEmpty;

  void dispose() {
    fullNameController.dispose();
    phoneController.dispose();
    customRelationshipController.dispose();
  }
}
