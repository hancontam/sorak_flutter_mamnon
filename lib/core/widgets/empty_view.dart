import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

enum EmptyViewType { data, search, permission, unsupported }

class EmptyView extends StatelessWidget {
  const EmptyView({
    super.key,
    this.title = 'Chưa có dữ liệu',
    this.message = 'Dữ liệu sẽ xuất hiện tại đây khi được cập nhật.',
    this.icon = LucideIcons.inbox,
    this.actionLabel,
    this.onAction,
    this.type = EmptyViewType.data,
  });

  final String title;
  final String message;
  final IconData icon;
  final String? actionLabel;
  final VoidCallback? onAction;
  final EmptyViewType type;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      key: ValueKey('empty_state_${type.name}'),
      container: true,
      label: '$title. $message',
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 128,
                height: 128,
                child: Lottie.asset(
                  'assets/lottie/empty.json',
                  repeat: false,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(
                      icon,
                      size: 56,
                      color: AppColors.mutedForeground,
                    );
                  },
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                message,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.mutedForeground,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (actionLabel != null && onAction != null) ...[
                const SizedBox(height: AppSpacing.md),
                FilledButton.icon(
                  key: const ValueKey('empty_state_action'),
                  onPressed: onAction,
                  icon: const Icon(LucideIcons.plus, size: 18),
                  label: Text(actionLabel!),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
