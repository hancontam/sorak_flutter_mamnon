import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

enum EmptyViewType { data, search, permission, unsupported }

class EmptyView extends StatelessWidget {
  const EmptyView({
    super.key,
    this.title = 'Chưa có dữ liệu',
    this.message = 'Dữ liệu sẽ xuất hiện tại đây khi được cập nhật.',
    this.icon = Icons.inbox_outlined,
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
                width: 136,
                height: 136,
                child: Lottie.asset(
                  'assets/lottie/empty.json',
                  repeat: false,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(icon, size: 56, color: AppColors.textGray);
                  },
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                message,
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: AppColors.textGray),
              ),
              if (actionLabel != null && onAction != null) ...[
                const SizedBox(height: AppSpacing.md),
                FilledButton.icon(
                  key: const ValueKey('empty_state_action'),
                  onPressed: onAction,
                  icon: const Icon(Icons.add),
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
