import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class StatusChip extends StatelessWidget {
  const StatusChip({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = _colorsFor(label);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: colors.border),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: colors.text,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  _StatusColors _colorsFor(String value) {
    final normalized = value.trim().toLowerCase();

    if (normalized.contains('active') ||
        normalized.contains('approve') ||
        normalized.contains('complete')) {
      return _StatusColors(
        text: const Color(0xFF166534),
        border: AppColors.success.withValues(alpha: 0.55),
        background: AppColors.success.withValues(alpha: 0.16),
      );
    }

    if (normalized.contains('pending') || normalized.contains('waiting')) {
      return _StatusColors(
        text: const Color(0xFF92400E),
        border: AppColors.accent.withValues(alpha: 0.55),
        background: AppColors.accent.withValues(alpha: 0.16),
      );
    }

    if (normalized.contains('reject') ||
        normalized.contains('cancel') ||
        normalized.contains('archive') ||
        normalized.contains('inactive')) {
      return _StatusColors(
        text: const Color(0xFF991B1B),
        border: AppColors.error.withValues(alpha: 0.55),
        background: AppColors.error.withValues(alpha: 0.12),
      );
    }

    return _StatusColors(
      text: AppColors.primary,
      border: AppColors.primary.withValues(alpha: 0.22),
      background: AppColors.primary.withValues(alpha: 0.08),
    );
  }
}

class _StatusColors {
  const _StatusColors({
    required this.text,
    required this.border,
    required this.background,
  });

  final Color text;
  final Color border;
  final Color background;
}
