import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/ui_labels.dart';
import '../../../core/widgets/sorak_avatar.dart';
import '../../../core/widgets/sorak_status_badge.dart';
import '../models/student.dart';

class StudentDetailScreen extends StatelessWidget {
  const StudentDetailScreen({
    super.key,
    required this.student,
    required this.grade,
    this.onEditStudent,
    this.onEditGuardian,
  });

  final Student student;
  final String grade;
  final VoidCallback? onEditStudent;
  final VoidCallback? onEditGuardian;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Hồ sơ trẻ')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.md,
          AppSpacing.md,
          104,
        ),
        children: [
          _StudentHero(student: student),
          const SizedBox(height: AppSpacing.md),
          _DetailSection(
            title: 'Thông tin cơ bản',
            icon: LucideIcons.contactRound,
            rows: [
              _DetailRowData(
                'Mã thẻ',
                _valueOrMissing(student.studentIdCardNumber),
              ),
              _DetailRowData('Họ tên', _valueOrMissing(student.fullName)),
              _DetailRowData('Ngày sinh', _formatDateOnly(student.dateOfBirth)),
              _DetailRowData('Giới tính', UiLabels.gender(student.gender)),
              _DetailRowData('Khối', _valueOrMissing(grade)),
              _DetailRowData('Lớp', _valueOrMissing(student.className)),
              _DetailRowData('Học vụ', UiLabels.status(student.studentStatus)),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          _DetailSection(
            title: 'Nhập học và liên hệ',
            icon: LucideIcons.school,
            rows: [
              _DetailRowData(
                'Ngày nhập học',
                _formatDateOnly(student.enrollmentDate),
              ),
              _DetailRowData('Nơi sinh', _valueOrMissing(student.birthPlace)),
              _DetailRowData(
                'Địa chỉ hiện tại',
                _valueOrMissing(student.currentAddress),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          _ParentContactSection(parents: student.parents),
          const SizedBox(height: AppSpacing.sm),
          _DetailSection(
            title: 'Thông tin bổ sung',
            icon: LucideIcons.notebookTabs,
            rows: [
              _DetailRowData('Dân tộc', _valueOrMissing(student.ethnicity)),
              _DetailRowData('Quốc tịch', _valueOrMissing(student.nationality)),
              _DetailRowData('Tôn giáo', _valueOrMissing(student.religion)),
              _DetailRowData('Nhóm máu', _valueOrMissing(student.bloodType)),
            ],
          ),
        ],
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
                  onPressed: onEditGuardian,
                  child: const Text('Phụ huynh'),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: FilledButton(
                  onPressed: onEditStudent,
                  child: const Text('Cập nhật trẻ'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ParentContactSection extends StatelessWidget {
  const _ParentContactSection({required this.parents});

  final List<StudentParent> parents;

  @override
  Widget build(BuildContext context) {
    final contacts = parents.where((parent) => parent.phone.trim().isNotEmpty);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  LucideIcons.usersRound,
                  size: 20,
                  color: AppColors.primary,
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  'Liên hệ phụ huynh',
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            if (contacts.isEmpty)
              Text(
                'Chưa có',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                  fontStyle: FontStyle.italic,
                ),
              )
            else
              for (final parent in contacts)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          parent.relationship.trim().isEmpty
                              ? 'Phụ huynh'
                              : parent.relationship.trim(),
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: AppColors.mutedForeground,
                                fontWeight: FontWeight.w500,
                              ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        parent.phone.trim(),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.foreground,
                          fontWeight: FontWeight.w700,
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

class _StudentHero extends StatelessWidget {
  const _StudentHero({required this.student});

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
              size: 64,
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _valueOrMissing(student.fullName),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Mã thẻ: ${_valueOrMissing(student.studentIdCardNumber)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.mutedForeground,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'monospace',
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  SorakStatusBadge(label: student.studentStatus),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailSection extends StatelessWidget {
  const _DetailSection({
    required this.title,
    required this.icon,
    required this.rows,
  });

  final String title;
  final IconData icon;
  final List<_DetailRowData> rows;

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
                Icon(icon, size: 20, color: AppColors.primary),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  title,
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            for (var index = 0; index < rows.length; index++) ...[
              _DetailValueRow(data: rows[index]),
              if (index < rows.length - 1) const Divider(height: AppSpacing.md),
            ],
          ],
        ),
      ),
    );
  }
}

class _DetailRowData {
  const _DetailRowData(this.label, this.value);

  final String label;
  final String value;
}

class _DetailValueRow extends StatelessWidget {
  const _DetailValueRow({required this.data});

  final _DetailRowData data;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            data.label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.mutedForeground,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          flex: 2,
          child: Text(
            data.value,
            textAlign: TextAlign.right,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.foreground,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

String _valueOrMissing(String? value) {
  final trimmed = value?.trim() ?? '';
  return trimmed.isEmpty ? 'Chưa có' : trimmed;
}

String _formatDateOnly(String? value) {
  final raw = value?.trim() ?? '';
  if (raw.isEmpty) {
    return 'Chưa có';
  }
  final date = DateTime.tryParse(raw);
  if (date == null) {
    return raw.length >= 10 ? raw.substring(0, 10) : raw;
  }
  final day = date.day.toString().padLeft(2, '0');
  final month = date.month.toString().padLeft(2, '0');
  return '$day/$month/${date.year}';
}
