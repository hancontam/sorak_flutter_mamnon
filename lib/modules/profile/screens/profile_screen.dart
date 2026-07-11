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
          return const LoadingView();
        }

        if (provider.errorMessage != null && profile.isEmpty) {
          return ErrorView(
            message: provider.errorMessage!,
            onRetry: provider.loadProfile,
          );
        }

        final role = (profile['role'] ?? user?.role ?? '').toString();
        final fullName =
            (profile['full_name'] ?? user?.fullName ?? 'Người dùng').toString();
        final email = (profile['email'] ?? user?.email ?? '').toString();
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
                              if (email.isNotEmpty)
                                Text(
                                  email,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(color: AppColors.textGray),
                                ),
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
                _InfoSection(
                  title: 'Tài khoản',
                  icon: LucideIcons.userCog,
                  rows: [
                    _InfoRowData(
                      'Mã tài khoản',
                      '${profile['account_id'] ?? user?.id ?? '-'}',
                    ),
                    _InfoRowData('Vai trò', _roleLabel(role)),
                    if (email.isNotEmpty) _InfoRowData('Email', email),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                if (role.toUpperCase() == 'PARENT')
                  _ParentInfoSection(profile: profile)
                else
                  _StaffInfoSection(profile: profile),
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
        _InfoRowData('Mã giáo viên', '${profile['teacher_id'] ?? '-'}'),
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

class _ParentInfoSection extends StatelessWidget {
  const _ParentInfoSection({required this.profile});

  final Map<String, dynamic> profile;

  @override
  Widget build(BuildContext context) {
    final enrollments = profile['enrollments'];
    final firstEnrollment = enrollments is List && enrollments.isNotEmpty
        ? enrollments.first
        : null;
    final schoolClass = firstEnrollment is Map
        ? firstEnrollment['class']
        : null;
    final schoolYear = schoolClass is Map ? schoolClass['school_year'] : null;

    return _InfoSection(
      title: 'Tài khoản học sinh',
      icon: LucideIcons.baby,
      rows: [
        _InfoRowData('Mã học sinh', '${profile['student_id'] ?? '-'}'),
        _InfoRowData(
          'Mã thẻ học sinh',
          '${profile['student_id_card_number'] ?? '-'}',
        ),
        _InfoRowData(
          'Lớp',
          schoolClass is Map ? '${schoolClass['class_name'] ?? '-'}' : '-',
        ),
        _InfoRowData(
          'Năm học',
          schoolYear is Map ? '${schoolYear['name'] ?? '-'}' : '-',
        ),
        _InfoRowData(
          'Trạng thái',
          UiLabels.status('${profile['student_status'] ?? '-'}'),
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
