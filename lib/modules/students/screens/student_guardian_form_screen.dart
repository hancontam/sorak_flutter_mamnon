import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/sorak_avatar.dart';
import '../models/student.dart';
import '../providers/student_provider.dart';

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
    _guardians = widget.student.parents.isEmpty
        ? [_GuardianDraft(phone: widget.student.contactPhone)]
        : widget.student.parents
              .take(2)
              .map(_GuardianDraft.fromParent)
              .toList();
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
    if (_guardians.length <= 1 || _guardians[index].parentId != null) {
      return;
    }
    setState(() {
      final guardian = _guardians.removeAt(index);
      guardian.dispose();
    });
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final parents = _guardians
        .where((guardian) => guardian.hasEnteredData)
        .map((guardian) => guardian.toJson())
        .toList();
    if (parents.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cần nhập ít nhất một phụ huynh.')),
      );
      return;
    }

    final provider = context.read<StudentProvider>();
    final saved = await provider.updateParents(widget.student.id, parents);
    if (!mounted) return;
    if (saved) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Đã cập nhật phụ huynh')));
      Navigator.pop(context, true);
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          provider.parentsErrorMessage ?? 'Chưa thể cập nhật phụ huynh.',
        ),
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
                canRemove:
                    _guardians.length > 1 && _guardians[index].parentId == null,
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
                  onPressed: context.watch<StudentProvider>().isSavingParents
                      ? null
                      : () => Navigator.pop(context),
                  child: const Text('Hủy'),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: FilledButton(
                  onPressed: context.watch<StudentProvider>().isSavingParents
                      ? null
                      : _save,
                  child: context.watch<StudentProvider>().isSavingParents
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.primaryForeground,
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
                validator: (value) {
                  if (draft.relationship == 'Khác' &&
                      (value == null || value.trim().isEmpty)) {
                    return 'Vui lòng nhập quan hệ';
                  }
                  return null;
                },
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

class _GuardianDraft {
  _GuardianDraft({this.parentId, String fullName = '', String phone = ''})
    : fullNameController = TextEditingController(text: fullName),
      phoneController = TextEditingController(text: phone),
      customRelationshipController = TextEditingController();

  factory _GuardianDraft.fromParent(StudentParent parent) {
    final relationship = parent.relationship.trim();
    final isKnown = _knownRelationships.contains(relationship);
    final draft = _GuardianDraft(
      parentId: parent.id,
      fullName: parent.fullName,
      phone: parent.phone,
    );
    draft.relationship = relationship.isEmpty
        ? ''
        : isKnown
        ? relationship
        : 'Khác';
    if (!isKnown && relationship.isNotEmpty) {
      draft.customRelationshipController.text = relationship;
    }
    return draft;
  }

  final int? parentId;
  final TextEditingController fullNameController;
  final TextEditingController phoneController;
  final TextEditingController customRelationshipController;
  String relationship = '';

  bool get hasEnteredData =>
      fullNameController.text.trim().isNotEmpty ||
      phoneController.text.trim().isNotEmpty ||
      relationship.isNotEmpty ||
      customRelationshipController.text.trim().isNotEmpty;

  Map<String, dynamic> toJson() {
    final customRelationship = customRelationshipController.text.trim();
    return {
      if (parentId != null) 'parent_id': parentId,
      'full_name': fullNameController.text.trim(),
      'phone': phoneController.text.trim(),
      if (relationship.isNotEmpty)
        'relationship': relationship == 'Khác'
            ? customRelationship
            : relationship,
    };
  }

  void dispose() {
    fullNameController.dispose();
    phoneController.dispose();
    customRelationshipController.dispose();
  }
}

const _knownRelationships = {
  'Cha',
  'Mẹ',
  'Ông nội',
  'Bà nội',
  'Ông ngoại',
  'Bà ngoại',
  'Người giám hộ',
};
