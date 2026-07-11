import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/ui_labels.dart';
import '../../../core/widgets/empty_view.dart';
import '../../../core/widgets/error_view.dart';
import '../../../core/widgets/loading_view.dart';
import '../../../core/widgets/sorak_avatar.dart';
import '../../../core/widgets/sorak_status_badge.dart';
import '../../auth/providers/auth_provider.dart';

enum ParentPortalSection { child, health }

class ParentPortalScreen extends StatefulWidget {
  const ParentPortalScreen({
    super.key,
    this.section = ParentPortalSection.child,
  });

  final ParentPortalSection section;

  @override
  State<ParentPortalScreen> createState() => _ParentPortalScreenState();
}

class _ParentPortalScreenState extends State<ParentPortalScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthProvider>().loadProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final profile = authProvider.profile;

    return RefreshIndicator(
      onRefresh: context.read<AuthProvider>().loadProfile,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.md,
          AppSpacing.md,
          96,
        ),
        children: [
          _ReportHeader(
            accountId: authProvider.currentUser?.id ?? 0,
            parentName: authProvider.currentUser?.fullName ?? 'Phụ huynh',
          ),
          const SizedBox(height: AppSpacing.md),
          if (authProvider.isLoading && profile.isEmpty)
            const LoadingView(message: 'Đang tải báo cáo của trẻ...')
          else if (authProvider.errorMessage != null)
            ErrorView(
              message: authProvider.errorMessage!,
              onRetry: context.read<AuthProvider>().loadProfile,
            )
          else if (profile.isEmpty)
            const EmptyView(
              title: 'Chưa có hồ sơ trẻ',
              message: 'Nhà trường chưa liên kết tài khoản này với hồ sơ trẻ.',
              type: EmptyViewType.permission,
            )
          else ...[
            _ChildSummaryCard(profile: profile),
            const SizedBox(height: AppSpacing.sm),
            const _ReadOnlyNote(),
          ],
        ],
      ),
    );
  }
}

class _ReportHeader extends StatelessWidget {
  const _ReportHeader({required this.accountId, required this.parentName});

  final int accountId;
  final String parentName;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            SorakAvatar(
              seed: accountId == 0 ? 'parent' : accountId,
              fallbackLabel: parentName,
              size: 56,
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Báo cáo của trẻ',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    parentName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.mutedForeground,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SorakStatusBadge(
              label: 'Chỉ xem',
              tone: SorakStatusTone.neutral,
              translate: false,
            ),
          ],
        ),
      ),
    );
  }
}

class _ChildSummaryCard extends StatelessWidget {
  const _ChildSummaryCard({required this.profile});

  final Map<String, dynamic> profile;

  @override
  Widget build(BuildContext context) {
    final enrollment = _firstMap(profile['enrollments']);
    final schoolClass = enrollment == null ? null : _asMap(enrollment['class']);
    final schoolYear = schoolClass == null
        ? null
        : _asMap(schoolClass['school_year']);

    final childName = '${profile['full_name'] ?? '-'}';
    final cardNumber = '${profile['student_id_card_number'] ?? '-'}';
    final className = schoolClass == null
        ? '-'
        : '${schoolClass['class_name'] ?? '-'}';
    final yearName = schoolYear == null ? '-' : '${schoolYear['name'] ?? '-'}';
    final status = '${profile['student_status'] ?? '-'}';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.secondary,
                    borderRadius: BorderRadius.circular(AppSpacing.radius),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: const Icon(
                    LucideIcons.userRound,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    childName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                SorakStatusBadge(label: status),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            _InfoRow(label: 'Mã trẻ', value: cardNumber),
            _InfoRow(label: 'Lớp', value: className),
            _InfoRow(label: 'Năm học', value: yearName),
            _InfoRow(label: 'Trạng thái', value: UiLabels.status(status)),
          ],
        ),
      ),
    );
  }

  Map<String, dynamic>? _firstMap(Object? value) {
    if (value is List && value.isNotEmpty) {
      return _asMap(value.first);
    }
    return null;
  }

  Map<String, dynamic>? _asMap(Object? value) {
    if (value is Map<String, dynamic>) {
      return value;
    }
    if (value is Map) {
      return value.map((key, value) => MapEntry('$key', value));
    }
    return null;
  }
}

class _ReadOnlyNote extends StatelessWidget {
  const _ReadOnlyNote();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(LucideIcons.info, color: AppColors.primary),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                'Thông tin chỉ dùng để theo dõi. Nếu có sai lệch, phụ huynh vui lòng liên hệ nhà trường để được hỗ trợ.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.mutedForeground,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs / 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.mutedForeground,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            flex: 2,
            child: Text(
              value.isEmpty ? '-' : value,
              textAlign: TextAlign.right,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.foreground,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
