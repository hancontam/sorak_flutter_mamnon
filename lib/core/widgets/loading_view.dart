import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

class LoadingView extends StatelessWidget {
  const LoadingView({super.key, this.message = 'Đang tải dữ liệu...'});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      key: const ValueKey('loading_state'),
      container: true,
      liveRegion: true,
      label: message,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 128,
                height: 128,
                child: Lottie.asset(
                  'assets/lottie/loading.json',
                  repeat: true,
                  delegates: LottieDelegates(
                    values: [
                      ValueDelegate.color(const [
                        '**',
                      ], value: AppColors.primary),
                    ],
                  ),
                  errorBuilder: (context, error, stackTrace) {
                    return const Center(child: CircularProgressIndicator());
                  },
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                message,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.mutedForeground,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
