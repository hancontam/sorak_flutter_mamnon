import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

class SuccessView extends StatelessWidget {
  const SuccessView({
    super.key,
    this.title = 'Success',
    this.message = 'The action was completed successfully.',
  });

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 136,
              height: 136,
              child: Lottie.asset(
                'assets/lottie/success.json',
                repeat: false,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(
                    Icons.check_circle_outline,
                    size: 56,
                    color: AppColors.success,
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
          ],
        ),
      ),
    );
  }
}
