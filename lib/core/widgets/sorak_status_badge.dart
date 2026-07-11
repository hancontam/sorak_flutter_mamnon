import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../utils/ui_labels.dart';

enum SorakStatusTone { success, pending, error, neutral }

class SorakStatusBadge extends StatelessWidget {
  const SorakStatusBadge({
    super.key,
    required this.label,
    this.tone,
    this.translate = true,
  });

  final String label;
  final SorakStatusTone? tone;
  final bool translate;

  @override
  Widget build(BuildContext context) {
    final displayLabel = translate ? UiLabels.status(label) : label;
    // "Đang hoạt động" / active → primary accent (year list & status chips).
    final scheme = _isActiveStatus(label) || _isActiveStatus(displayLabel)
        ? _primaryActiveScheme
        : _schemeFor(tone ?? _toneFor(label));

    return Semantics(
      label: 'Trạng thái: $displayLabel',
      child: Container(
        constraints: const BoxConstraints(minHeight: 28),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: 5,
        ),
        decoration: BoxDecoration(
          color: scheme.background,
          borderRadius: BorderRadius.circular(AppSpacing.radius),
          border: Border.all(color: scheme.border),
        ),
        child: ExcludeSemantics(
          child: Text(
            displayLabel,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: scheme.text,
              fontWeight: FontWeight.w800,
              letterSpacing: 0,
            ),
          ),
        ),
      ),
    );
  }

  static bool _isActiveStatus(String value) {
    final normalized = value.trim().toLowerCase();
    return normalized == 'active' ||
        normalized.contains('đang hoạt động') ||
        normalized == 'đang hoạt động';
  }

  SorakStatusTone _toneFor(String value) {
    final normalized = value.trim().toLowerCase();

    // Active handled via primary scheme in build(); keep success for other OK states.
    if (normalized.contains('approve') ||
        normalized.contains('complete') ||
        normalized.contains('recorded') ||
        normalized.contains('đang học') ||
        normalized.contains('đang làm')) {
      return SorakStatusTone.success;
    }

    if (normalized.contains('pending') ||
        normalized.contains('waiting') ||
        normalized.contains('chờ') ||
        normalized.contains('warning')) {
      return SorakStatusTone.pending;
    }

    if (normalized.contains('reject') ||
        normalized.contains('cancel') ||
        normalized.contains('archive') ||
        normalized.contains('xóa') ||
        normalized.contains('hủy') ||
        normalized.contains('từ chối')) {
      return SorakStatusTone.error;
    }

    // inactive / Ngừng hoạt động → neutral muted (not black error).
    if (normalized.contains('inactive') ||
        normalized.contains('ngừng hoạt động') ||
        normalized.contains('ngung hoat dong')) {
      return SorakStatusTone.neutral;
    }

    return SorakStatusTone.neutral;
  }

  static final _primaryActiveScheme = _BadgeScheme(
    text: AppColors.primary,
    background: AppColors.primary.withValues(alpha: 0.12),
    border: AppColors.primary,
  );

  _BadgeScheme _schemeFor(SorakStatusTone tone) {
    return switch (tone) {
      SorakStatusTone.success => const _BadgeScheme(
        text: AppColors.statusSuccessText,
        background: AppColors.statusSuccessBackground,
        border: AppColors.statusSuccessBorder,
      ),
      SorakStatusTone.pending => const _BadgeScheme(
        text: AppColors.statusWarningText,
        background: AppColors.statusWarningBackground,
        border: AppColors.statusWarningBorder,
      ),
      SorakStatusTone.error => const _BadgeScheme(
        text: AppColors.statusErrorText,
        background: AppColors.statusErrorBackground,
        border: AppColors.statusErrorBorder,
      ),
      SorakStatusTone.neutral => const _BadgeScheme(
        text: AppColors.statusNeutralText,
        background: AppColors.statusNeutralBackground,
        border: AppColors.statusNeutralBorder,
      ),
    };
  }
}

class _BadgeScheme {
  const _BadgeScheme({
    required this.text,
    required this.background,
    required this.border,
  });

  final Color text;
  final Color background;
  final Color border;
}
