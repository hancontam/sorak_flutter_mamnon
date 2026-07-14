import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/empty_view.dart';
import '../../../core/widgets/error_view.dart';
import '../../../core/widgets/loading_view.dart';
import '../../../core/widgets/sorak_avatar.dart';
import '../../../core/widgets/sorak_status_badge.dart';
import '../../auth/providers/auth_provider.dart';
import '../../health/models/health_assessment.dart';
import '../providers/parent_health_history_provider.dart';
import '../widgets/parent_profile_info_cards.dart';

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
      _refresh();
    });
  }

  Future<void> _refresh() async {
    await Future.wait([
      context.read<AuthProvider>().loadProfile(),
      context.read<ParentHealthHistoryProvider>().load(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final profile = context.select<AuthProvider, Map<String, dynamic>>(
      (provider) => provider.profile,
    );
    final isLoading = context.select<AuthProvider, bool>(
      (provider) => provider.isLoading,
    );
    final errorMessage = context.select<AuthProvider, String?>(
      (provider) => provider.errorMessage,
    );
    final accountId = context.select<AuthProvider, int>(
      (provider) => provider.currentUser?.id ?? 0,
    );
    final parentName = context.select<AuthProvider, String>(
      (provider) => provider.currentUser?.fullName ?? 'Phụ huynh',
    );

    return RefreshIndicator(
      onRefresh: _refresh,
      child: ListView(
        // Always scrollable so back transition keeps a stable scroll view.
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.md,
          AppSpacing.md,
          96,
        ),
        children: [
          _ReportHeader(accountId: accountId, parentName: parentName),
          const SizedBox(height: AppSpacing.md),
          if (isLoading && profile.isEmpty)
            const LoadingView(message: 'Đang tải báo cáo của trẻ...')
          else if (errorMessage != null && profile.isEmpty)
            ErrorView(
              message: errorMessage,
              onRetry: context.read<AuthProvider>().loadProfile,
            )
          else if (profile.isEmpty)
            const EmptyView(
              title: 'Chưa có hồ sơ trẻ',
              message: 'Nhà trường chưa liên kết tài khoản này với hồ sơ trẻ.',
              type: EmptyViewType.permission,
            )
          else ...[
            // Child report only — parent/guardian block lives in Profile drawer.
            ParentProfileInfoCards(
              profile: profile,
              showStudentHeader: true,
              showParents: false,
            ),
            const SizedBox(height: AppSpacing.sm),
            const _ParentHealthHistorySection(),
            const SizedBox(height: AppSpacing.sm),
            const _ReadOnlyNote(),
          ],
        ],
      ),
    );
  }
}

class _ParentHealthHistorySection extends StatelessWidget {
  const _ParentHealthHistorySection();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ParentHealthHistoryProvider>();
    final records = provider.history?.records ?? const <HealthAssessment>[];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  LucideIcons.heartPulse,
                  size: 20,
                  color: AppColors.primary,
                ),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: Text(
                    'Lịch sử khám sức khỏe',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SorakStatusBadge(
                  label: 'Chỉ xem',
                  tone: SorakStatusTone.neutral,
                  translate: false,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            if (provider.isLoading && records.isEmpty)
              const LoadingView(message: 'Đang tải lịch sử sức khỏe...')
            else if (provider.errorMessage != null && records.isEmpty)
              ErrorView(message: provider.errorMessage!, onRetry: provider.load)
            else if (records.isEmpty)
              const EmptyView(
                title: 'Chưa có lịch sử khám',
                message: 'Trẻ chưa có lần đánh giá sức khỏe nào.',
                type: EmptyViewType.data,
              )
            else
              for (var index = 0; index < records.length; index++) ...[
                _ParentHealthRecordCard(record: records[index]),
                if (index < records.length - 1)
                  const SizedBox(height: AppSpacing.sm),
              ],
          ],
        ),
      ),
    );
  }
}

class _ParentHealthRecordCard extends StatelessWidget {
  const _ParentHealthRecordCard({required this.record});

  final HealthAssessment record;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.muted,
        borderRadius: BorderRadius.circular(AppSpacing.radius),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          _HealthLine(
            label: 'Ngày đánh giá',
            value: _formatHealthDate(record.assessmentDate),
          ),
          _HealthLine(label: 'Chiều cao', value: '${record.heightCm} cm'),
          _HealthLine(label: 'Cân nặng', value: '${record.weightKg} kg'),
          _HealthLine(label: 'BMI', value: record.bmi.toStringAsFixed(2)),
          _HealthLine(label: 'BMI/tuổi', value: record.bmiStatus),
          _HealthLine(label: 'Cao/tuổi', value: record.heightStatus),
          _HealthLine(label: 'Nặng/tuổi', value: record.weightStatus),
          _HealthLine(label: 'Ghi chú', value: record.note),
        ],
      ),
    );
  }
}

class _HealthLine extends StatelessWidget {
  const _HealthLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final missing = value.trim().isEmpty;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
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
              missing ? 'Chưa có' : value,
              textAlign: TextAlign.right,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: missing ? AppColors.primary : AppColors.foreground,
                fontWeight: missing ? FontWeight.w600 : FontWeight.w700,
                fontStyle: missing ? FontStyle.italic : FontStyle.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

String _formatHealthDate(String raw) {
  final parsed = DateTime.tryParse(raw);
  if (parsed == null) return raw;
  final day = parsed.day.toString().padLeft(2, '0');
  final month = parsed.month.toString().padLeft(2, '0');
  return '$day/$month/${parsed.year}';
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
              child: Text(
                parentName,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
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
