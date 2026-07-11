import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
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
      key: const ValueKey('permission_denied_state'),
      appBar: AppBar(title: const Text('Không có quyền truy cập')),
      body: Center(
        child: Padding(
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
                  LucideIcons.lock,
                  size: 32,
                  color: AppColors.primaryForeground,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Không có quyền truy cập',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Vai trò hiện tại không được phép mở chức năng này.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.mutedForeground,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              FilledButton.icon(
                onPressed: () => Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/home',
                  (_) => false,
                ),
                icon: const Icon(LucideIcons.house, size: 18),
                label: const Text('Về trang chính'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
