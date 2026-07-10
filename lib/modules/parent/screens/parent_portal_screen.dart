import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/status_chip.dart';
import '../../auth/providers/auth_provider.dart';
import '../../health/models/health_assessment.dart';
import '../../health/models/nutrition_assessment.dart';
import '../../health/providers/health_assessment_provider.dart';
import '../../health/providers/nutrition_assessment_provider.dart';

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
  static const int _childStudentId = 1;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HealthAssessmentProvider>().loadItems();
      context.read<NutritionAssessmentProvider>().loadItems();
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;
    final healthProvider = context.watch<HealthAssessmentProvider>();
    final nutritionProvider = context.watch<NutritionAssessmentProvider>();

    final latestHealth = _findHealth(healthProvider.items);
    final nutrition = _findNutrition(nutritionProvider.items);
    final isChildSection = widget.section == ParentPortalSection.child;

    return RefreshIndicator(
      onRefresh: () async {
        await Future.wait([
          context.read<HealthAssessmentProvider>().loadItems(),
          context.read<NutritionAssessmentProvider>().loadItems(),
        ]);
      },
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
            _ChildProfileCard(health: latestHealth),
            const SizedBox(height: AppSpacing.sm),
            const _ReadOnlyNote(
              message:
                  'Thông tin trẻ chỉ dùng để theo dõi. Nếu có sai lệch, phụ huynh vui lòng liên hệ nhà trường.',
            ),
          ] else ...[
            _HealthStatusCard(health: latestHealth),
            const SizedBox(height: AppSpacing.sm),
            _NutritionStatusCard(nutrition: nutrition),
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

  HealthAssessment? _findHealth(List<HealthAssessment> items) {
    for (final item in items) {
      if (item.studentId == _childStudentId) {
        return item;
      }
    }
    return null;
  }

  NutritionAssessment? _findNutrition(List<NutritionAssessment> items) {
    for (final item in items) {
      if (item.studentId == _childStudentId) {
        return item;
      }
    }
    return null;
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
  const _ChildProfileCard({required this.health});

  final HealthAssessment? health;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Hồ sơ trẻ',
      icon: Icons.child_care_outlined,
      child: Column(
        children: [
          _InfoRow(
            label: 'Trẻ',
            value: health?.studentName ?? 'Nguyen Minh An',
          ),
          _InfoRow(
            label: 'Mã trẻ',
            value: health?.studentCode ?? 'NBA2024.001',
          ),
          _InfoRow(label: 'Lớp', value: health?.className ?? 'Mam 1A'),
          _InfoRow(
            label: 'Năm học',
            value: health?.schoolYearName.isEmpty ?? true
                ? '2025-2026'
                : health!.schoolYearName,
          ),
          const _InfoRow(label: 'Trạng thái', value: 'Đang học'),
        ],
      ),
    );
  }
}

class _HealthStatusCard extends StatelessWidget {
  const _HealthStatusCard({required this.health});

  final HealthAssessment? health;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Tình trạng sức khỏe',
      icon: Icons.favorite_outline,
      trailing: StatusChip(label: health?.bmiStatus ?? 'Chưa có dữ liệu'),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _MetricTile(
                  label: 'Chiều cao',
                  value: health == null ? '-' : '${health!.heightCm} cm',
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _MetricTile(
                  label: 'Cân nặng',
                  value: health == null ? '-' : '${health!.weightKg} kg',
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _MetricTile(
                  label: 'BMI',
                  value: health == null ? '-' : health!.bmi.toStringAsFixed(2),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          _InfoRow(
            label: 'Lần đo gần nhất',
            value: health == null
                ? '-'
                : health!.assessmentDate.substring(0, 10),
          ),
          _InfoRow(label: 'Chiều cao', value: health?.heightStatus ?? '-'),
          _InfoRow(label: 'Cân nặng', value: health?.weightStatus ?? '-'),
          _InfoRow(label: 'Ghi chú', value: health?.note ?? '-'),
        ],
      ),
    );
  }
}

class _NutritionStatusCard extends StatelessWidget {
  const _NutritionStatusCard({required this.nutrition});

  final NutritionAssessment? nutrition;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Tình trạng nuôi dưỡng',
      icon: Icons.restaurant_outlined,
      trailing: StatusChip(
        label: nutrition?.statusSummary ?? 'Chưa có dữ liệu',
      ),
      child: Column(
        children: [
          _InfoRow(label: 'Giai đoạn', value: nutrition?.period ?? 'dau_nam'),
          _InfoRow(
            label: 'Kênh cân nặng',
            value: nutrition?.weightChannel.isEmpty ?? true
                ? 'Bình thường'
                : nutrition!.weightChannel,
          ),
          _InfoRow(
            label: 'SDD thấp còi',
            value: nutrition?.isStunting ?? false ? 'Có' : 'Không',
          ),
          _InfoRow(
            label: 'SDD còi cọc',
            value: nutrition?.isSevereStunting ?? false ? 'Có' : 'Không',
          ),
          _InfoRow(
            label: 'Béo phì',
            value: nutrition?.isObese ?? false ? 'Có' : 'Không',
          ),
          _InfoRow(label: 'Ghi chú', value: nutrition?.note ?? '-'),
        ],
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
    this.trailing,
  });

  final String title;
  final IconData icon;
  final Widget child;
  final Widget? trailing;

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
                ?trailing,
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

class _MetricTile extends StatelessWidget {
  const _MetricTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppColors.textGray),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}
