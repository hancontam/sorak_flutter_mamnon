import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../modules/auth/providers/auth_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

class RoleGuard extends StatelessWidget {
  const RoleGuard({super.key, required this.allowedRoles, required this.child});

  final Set<String> allowedRoles;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final role =
        context.watch<AuthProvider>().currentUser?.role.toUpperCase() ?? '';
    final allowed = allowedRoles.map((item) => item.toUpperCase()).toSet();

    if (allowed.contains(role)) {
      return child;
    }

    return const AccessDeniedScreen();
  }
}

class AccessDeniedScreen extends StatelessWidget {
  const AccessDeniedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Access denied')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 32,
                backgroundColor: AppColors.error.withValues(alpha: 0.12),
                foregroundColor: AppColors.error,
                child: const Icon(Icons.lock_outline, size: 32),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Access denied',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Your account role cannot open this module.',
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: AppColors.textGray),
              ),
              const SizedBox(height: AppSpacing.md),
              FilledButton.icon(
                onPressed: () => Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/home',
                  (_) => false,
                ),
                icon: const Icon(Icons.home_outlined),
                label: const Text('Back home'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
