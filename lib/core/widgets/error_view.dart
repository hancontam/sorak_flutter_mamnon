import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

class ErrorView extends StatelessWidget {
  const ErrorView({
    super.key,
    required this.message,
    required this.onRetry,
    this.title = 'Không thể tải dữ liệu',
  });

  final String message;
  final VoidCallback onRetry;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      key: const ValueKey('error_state'),
      container: true,
      liveRegion: true,
      label: '$title. $message',
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.destructive,
                  borderRadius: BorderRadius.circular(AppSpacing.radius),
                ),
                child: const Icon(
                  LucideIcons.triangleAlert,
                  size: 32,
                  color: AppColors.primaryForeground,
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
              const SizedBox(height: AppSpacing.md),
              OutlinedButton.icon(
                key: const ValueKey('error_retry_button'),
                onPressed: onRetry,
                icon: const Icon(LucideIcons.refreshCcw, size: 18),
                label: const Text('Thử lại'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
