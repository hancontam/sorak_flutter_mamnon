import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/sorak_avatar.dart';
import '../../../core/widgets/sorak_status_badge.dart';

/// Shared school-transfer card for outgoing + incoming lists (web columns).
class SchoolTransferCard extends StatelessWidget {
  const SchoolTransferCard({
    super.key,
    required this.studentId,
    required this.studentName,
    required this.cardNumber,
    required this.className,
    required this.schoolYearName,
    required this.schoolLabel,
    required this.schoolValue,
    required this.transferDate,
    required this.status,
    this.reason = '',
    this.note = '',
    this.showEdit = false,
    this.showCancel = false,
    this.showDelete = false,
    this.onEdit,
    this.onCancel,
    this.onDelete,
  });

  final int studentId;
  final String studentName;
  final String cardNumber;
  final String className;
  final String schoolYearName;
  final String schoolLabel;
  final String schoolValue;
  final String transferDate;
  final String status;
  final String reason;
  final String note;
  final bool showEdit;
  final bool showCancel;
  final bool showDelete;
  final VoidCallback? onEdit;
  final VoidCallback? onCancel;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final statusLabel = schoolTransferStatusLabel(status);
    final statusTone = schoolTransferStatusTone(status);
    final hasActions = showEdit || showCancel || showDelete;
    final transferDay = DateTime.tryParse(transferDate);
    final isFutureTransfer =
        status == 'Recorded' &&
        transferDay != null &&
        transferDay.isAfter(DateTime.now());

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SorakAvatar(
                  seed: studentId,
                  fallbackLabel: studentName,
                  size: 44,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        studentName.isEmpty ? 'Học sinh' : studentName,
                        softWrap: true,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              fontWeight: FontWeight.w800,
                              height: 1.25,
                            ),
                      ),
                      if (cardNumber.isNotEmpty) ...[
                        const SizedBox(height: AppSpacing.xs / 2),
                        Text(
                          cardNumber,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: AppColors.mutedForeground,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ],
                      const SizedBox(height: AppSpacing.xs),
                      _CompactStatusBadge(label: statusLabel, tone: statusTone),
                    ],
                  ),
                ),
                if (hasActions)
                  PopupMenuButton<String>(
                    tooltip: 'Thao tác',
                    icon: const Icon(LucideIcons.ellipsisVertical, size: 20),
                    onSelected: (value) {
                      switch (value) {
                        case 'edit':
                          onEdit?.call();
                        case 'cancel':
                          onCancel?.call();
                        case 'delete':
                          onDelete?.call();
                      }
                    },
                    itemBuilder: (context) => [
                      if (showEdit)
                        const PopupMenuItem(
                          value: 'edit',
                          child: Text('Chỉnh sửa'),
                        ),
                      if (showCancel)
                        const PopupMenuItem(
                          value: 'cancel',
                          child: Text('Hủy hồ sơ'),
                        ),
                      if (showDelete)
                        const PopupMenuItem(
                          value: 'delete',
                          child: Text('Xóa'),
                        ),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.muted,
                borderRadius: BorderRadius.circular(AppSpacing.radius),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  _InfoLine(
                    label: 'Học sinh',
                    value: studentName.isEmpty ? '—' : studentName,
                  ),
                  _InfoLine(
                    label: 'Lớp',
                    value: className.isEmpty ? '—' : className,
                  ),
                  _InfoLine(
                    label: 'Năm học',
                    value: schoolYearName.isEmpty ? '—' : schoolYearName,
                  ),
                  _InfoLine(
                    label: schoolLabel,
                    value: schoolValue.isEmpty ? '—' : schoolValue,
                  ),
                  _InfoLine(
                    label: 'Ngày chuyển',
                    value: isFutureTransfer
                        ? 'Chưa tới ngày (${formatTransferDate(transferDate)})'
                        : formatTransferDate(transferDate),
                    isMissing: isFutureTransfer,
                  ),
                  if (reason.isNotEmpty)
                    _InfoLine(label: 'Lý do', value: reason),
                  if (note.isNotEmpty) _InfoLine(label: 'Ghi chú', value: note),
                  _InfoLine(label: 'Trạng thái', value: statusLabel),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CompactStatusBadge extends StatelessWidget {
  const _CompactStatusBadge({required this.label, required this.tone});

  final String label;
  final SorakStatusTone tone;

  @override
  Widget build(BuildContext context) {
    final scheme = switch (tone) {
      SorakStatusTone.success => (
        text: AppColors.statusSuccessText,
        background: AppColors.statusSuccessBackground,
        border: AppColors.statusSuccessBorder,
      ),
      SorakStatusTone.pending => (
        text: AppColors.statusWarningText,
        background: AppColors.statusWarningBackground,
        border: AppColors.statusWarningBorder,
      ),
      SorakStatusTone.error => (
        text: AppColors.statusErrorText,
        background: AppColors.statusErrorBackground,
        border: AppColors.statusErrorBorder,
      ),
      SorakStatusTone.neutral => (
        text: AppColors.statusNeutralText,
        background: AppColors.statusNeutralBackground,
        border: AppColors.statusNeutralBorder,
      ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: scheme.background,
        borderRadius: BorderRadius.circular(AppSpacing.radius),
        border: Border.all(color: scheme.border),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: scheme.text,
          fontWeight: FontWeight.w700,
          fontSize: 11,
          height: 1.15,
          letterSpacing: 0,
        ),
      ),
    );
  }
}

class _InfoLine extends StatelessWidget {
  const _InfoLine({
    required this.label,
    required this.value,
    this.isMissing = false,
  });

  final String label;
  final String value;
  final bool isMissing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
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
              value,
              textAlign: TextAlign.right,
              softWrap: true,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: isMissing ? AppColors.primary : AppColors.foreground,
                fontWeight: isMissing ? FontWeight.w600 : FontWeight.w700,
                fontStyle: isMissing ? FontStyle.italic : FontStyle.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

String schoolTransferStatusLabel(String status) {
  switch (status) {
    case 'Recorded':
      return 'Đã ghi nhận';
    case 'Cancelled':
    case 'Canceled':
      return 'Đã hủy';
    case 'Pending':
      return 'Chờ duyệt';
    default:
      return status.isEmpty ? '—' : status;
  }
}

SorakStatusTone schoolTransferStatusTone(String status) {
  switch (status) {
    case 'Recorded':
      return SorakStatusTone.success;
    case 'Cancelled':
    case 'Canceled':
      return SorakStatusTone.neutral;
    case 'Pending':
      return SorakStatusTone.pending;
    default:
      return SorakStatusTone.neutral;
  }
}

String formatTransferDate(String raw) {
  final trimmed = raw.trim();
  if (trimmed.isEmpty) {
    return '—';
  }
  final parsed = DateTime.tryParse(trimmed);
  if (parsed == null) {
    return trimmed;
  }
  final day = parsed.day.toString().padLeft(2, '0');
  final month = parsed.month.toString().padLeft(2, '0');
  return '$day/$month/${parsed.year}';
}
