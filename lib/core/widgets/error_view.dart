import 'package:flutter/material.dart';

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
              const Icon(Icons.error_outline, size: 56, color: AppColors.error),
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
              const SizedBox(height: AppSpacing.md),
              OutlinedButton.icon(
                key: const ValueKey('error_retry_button'),
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Thử lại'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
