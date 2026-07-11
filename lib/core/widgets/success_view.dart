import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

class SuccessView extends StatelessWidget {
  const SuccessView({
    super.key,
    this.title = 'Thành công',
    this.message = 'Thao tác đã được hoàn tất.',
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
              width: 128,
              height: 128,
              child: Lottie.asset(
                'assets/lottie/success.json',
                repeat: false,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(
                    LucideIcons.circleCheck,
                    size: 56,
                    color: AppColors.foreground,
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
          ],
        ),
      ),
    );
  }
}
