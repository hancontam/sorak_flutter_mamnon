import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/status_chip.dart';
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
    final user = authProvider.currentUser;
    final isChildSection = widget.section == ParentPortalSection.child;

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
          _PortalHeader(
            parentName: user?.fullName ?? 'Tài khoản phụ huynh',
            section: widget.section,
          ),
          const SizedBox(height: AppSpacing.md),
          if (isChildSection) ...[
            if (authProvider.isLoading && authProvider.profile.isEmpty)
              const Center(child: CircularProgressIndicator())
            else if (authProvider.errorMessage != null)
              _UnavailableDataCard(message: authProvider.errorMessage!)
            else
              _ChildProfileCard(profile: authProvider.profile),
            const SizedBox(height: AppSpacing.sm),
            const _ReadOnlyNote(
              message:
                  'Thông tin trẻ chỉ dùng để theo dõi. Nếu có sai lệch, phụ huynh vui lòng liên hệ nhà trường.',
            ),
          ] else ...[
            const _UnavailableDataCard(
              message:
                  'Nhà trường chưa cung cấp API sức khỏe và dinh dưỡng dành cho phụ huynh. Dữ liệu sẽ xuất hiện tại đây khi backend hỗ trợ.',
            ),
            const SizedBox(height: AppSpacing.sm),
            const _ReadOnlyNote(
              message:
                  'Màn hình này chỉ xem dữ liệu sức khỏe và nuôi dưỡng của trẻ. Giáo viên hoặc cán bộ nhà trường sẽ cập nhật khi có đánh giá mới.',
            ),
          ],
        ],
      ),
    );
  }
}

class _PortalHeader extends StatelessWidget {
  const _PortalHeader({required this.parentName, required this.section});

  final String parentName;
  final ParentPortalSection section;

  @override
  Widget build(BuildContext context) {
    final isChildSection = section == ParentPortalSection.child;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: AppColors.accent.withValues(alpha: 0.18),
              foregroundColor: AppColors.primary,
              child: Icon(
                isChildSection ? Icons.child_care : Icons.favorite_outline,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isChildSection ? 'Cổng phụ huynh' : 'Sức khỏe của trẻ',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    isChildSection ? 'Thông tin trẻ' : 'Theo dõi sức khỏe',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    parentName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: AppColors.textGray),
                  ),
                ],
              ),
            ),
            const StatusChip(label: 'Chỉ xem'),
          ],
        ),
      ),
    );
  }
}

class _ChildProfileCard extends StatelessWidget {
  const _ChildProfileCard({required this.profile});

  final Map<String, dynamic> profile;

  @override
  Widget build(BuildContext context) {
    final enrollments = profile['enrollments'];
    final enrollment = enrollments is List && enrollments.isNotEmpty
        ? enrollments.first
        : null;
    final schoolClass = enrollment is Map ? enrollment['class'] : null;
    final schoolYear = schoolClass is Map ? schoolClass['school_year'] : null;

    return _SectionCard(
      title: 'Hồ sơ trẻ',
      icon: Icons.child_care_outlined,
      child: Column(
        children: [
          _InfoRow(label: 'Trẻ', value: '${profile['full_name'] ?? '-'}'),
          _InfoRow(
            label: 'Mã trẻ',
            value: '${profile['student_id_card_number'] ?? '-'}',
          ),
          _InfoRow(
            label: 'Lớp',
            value: schoolClass is Map
                ? '${schoolClass['class_name'] ?? '-'}'
                : '-',
          ),
          _InfoRow(
            label: 'Năm học',
            value: schoolYear is Map ? '${schoolYear['name'] ?? '-'}' : '-',
          ),
          _InfoRow(
            label: 'Trạng thái',
            value: '${profile['student_status'] ?? '-'}',
          ),
        ],
      ),
    );
  }
}

class _UnavailableDataCard extends StatelessWidget {
  const _UnavailableDataCard({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Card(
      key: const ValueKey('parent_api_unavailable'),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          children: [
            const Icon(
              Icons.cloud_off_outlined,
              color: AppColors.textGray,
              size: 36,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Chưa có dữ liệu từ nhà trường',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppColors.textGray),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReadOnlyNote extends StatelessWidget {
  const _ReadOnlyNote({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.visibility_outlined, color: AppColors.primary),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                message,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: AppColors.textGray),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.icon,
    required this.child,
  });

  final String title;
  final IconData icon;
  final Widget child;

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
            child,
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
                color: AppColors.textGray,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              value.isEmpty ? '-' : value,
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
