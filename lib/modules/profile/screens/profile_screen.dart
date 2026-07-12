import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/ui_labels.dart';
import '../../../core/widgets/error_view.dart';
import '../../../core/widgets/loading_view.dart';
import '../../../core/widgets/sorak_avatar.dart';
import '../../../core/widgets/status_chip.dart';
import '../../auth/providers/auth_provider.dart';
import '../../parent/widgets/parent_profile_info_cards.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Refresh quietly when profile already filled by Parent portal.
      context.read<AuthProvider>().loadProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, provider, _) {
        final user = provider.currentUser;
        final profile = provider.profile;

        if (provider.isLoading && profile.isEmpty) {
          return const Scaffold(body: LoadingView());
        }

        if (provider.errorMessage != null && profile.isEmpty) {
          return Scaffold(
            appBar: AppBar(title: const Text('Hồ sơ')),
            body: ErrorView(
              message: provider.errorMessage!,
              onRetry: provider.loadProfile,
            ),
          );
        }

        final role = (profile['role'] ?? user?.role ?? '').toString();
        final isParent = role.toUpperCase() == 'PARENT';
        final email = (profile['email'] ?? user?.email ?? '').toString();
        // Parent /auth/me is student-centric; prefer first guardian name on Profile.
        final fullName = isParent
            ? _parentDisplayName(profile, user?.fullName)
            : (profile['full_name'] ?? user?.fullName ?? 'Người dùng')
                .toString();
        final accountId = profile['account_id'] ?? user?.id ?? fullName;

        return Scaffold(
          appBar: AppBar(title: const Text('Hồ sơ')),
          body: RefreshIndicator(
            onRefresh: provider.loadProfile,
            child: ListView(
              padding: const EdgeInsets.all(AppSpacing.md),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Row(
                      children: [
                        SorakAvatar(
                          seed: accountId,
                          fallbackLabel: fullName,
                          size: 56,
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                fullName,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.w700),
                              ),
                              const SizedBox(height: AppSpacing.xs),
                              if (!isParent && email.isNotEmpty)
                                Text(
                                  email,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(color: AppColors.textGray),
                                ),
                              if (!isParent && email.isNotEmpty)
                                const SizedBox(height: AppSpacing.xs),
                              StatusChip(label: _roleLabel(role)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                if (isParent)
                  // Parent Profile: guardians only. Student lives in child report.
                  ParentProfileInfoCards(
                    profile: profile,
                    showStudentHeader: false,
                    showStudentInfo: false,
                    showParents: true,
                  )
                else ...[
                  _InfoSection(
                    title: 'Tài khoản',
                    icon: LucideIcons.userCog,
                    rows: [
                      _InfoRowData('Vai trò', _roleLabel(role)),
                      if (email.isNotEmpty) _InfoRowData('Email', email),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _StaffInfoSection(profile: profile),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  String _roleLabel(String role) {
    switch (role.toUpperCase()) {
      case 'PRINCIPAL':
        return UiLabels.role(role);
      case 'TEACHER':
        return UiLabels.role(role);
      case 'PARENT':
        return UiLabels.role(role);
      default:
        return role.isEmpty ? 'Người dùng' : UiLabels.role(role);
    }
  }

  String _parentDisplayName(Map<String, dynamic> profile, String? fallback) {
    final parents = profile['parents'];
    if (parents is List && parents.isNotEmpty) {
      final first = parents.first;
      if (first is Map) {
        final name = '${first['full_name'] ?? ''}'.trim();
        if (name.isNotEmpty) {
          return name;
        }
      }
    }
    final fromFallback = (fallback ?? '').trim();
    if (fromFallback.isNotEmpty) {
      return fromFallback;
    }
    return 'Phụ huynh';
  }
}

class _StaffInfoSection extends StatelessWidget {
  const _StaffInfoSection({required this.profile});

  final Map<String, dynamic> profile;

  @override
  Widget build(BuildContext context) {
    return _InfoSection(
      title: 'Hồ sơ cán bộ',
      icon: LucideIcons.badgeCheck,
      rows: [
        _InfoRowData('Chức vụ', '${profile['position'] ?? '-'}'),
        _InfoRowData('Số điện thoại', '${profile['phone'] ?? '-'}'),
        _InfoRowData(
          'Giới tính',
          UiLabels.gender('${profile['gender'] ?? '-'}'),
        ),
        _InfoRowData(
          'Trạng thái công tác',
          UiLabels.workStatus('${profile['work_status'] ?? '-'}'),
        ),
      ],
    );
  }
}

class _InfoSection extends StatelessWidget {
  const _InfoSection({
    required this.title,
    required this.icon,
    required this.rows,
  });

  final String title;
  final IconData icon;
  final List<_InfoRowData> rows;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          children: [
            Row(
              children: [
                Icon(icon, color: AppColors.primary),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            for (final row in rows) _InfoRow(row: row),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.row});

  final _InfoRowData row;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs / 2),
      child: Row(
        children: [
          Expanded(
            child: Text(
              row.label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textGray,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              row.value.isEmpty ? '-' : row.value,
              textAlign: TextAlign.right,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textDark,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRowData {
  const _InfoRowData(this.label, this.value);

  final String label;
  final String value;
}
