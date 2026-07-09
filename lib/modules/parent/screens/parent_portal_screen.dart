import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/status_chip.dart';
import '../../auth/providers/auth_provider.dart';
import '../../health/models/health_assessment.dart';
import '../../health/models/nutrition_assessment.dart';
import '../../health/providers/growth_who_provider.dart';
import '../../health/providers/health_assessment_provider.dart';
import '../../health/providers/nutrition_assessment_provider.dart';

class ParentPortalScreen extends StatefulWidget {
  const ParentPortalScreen({super.key});

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
      context.read<GrowthWhoProvider>().load(role: 'PARENT');
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;
    final healthProvider = context.watch<HealthAssessmentProvider>();
    final nutritionProvider = context.watch<NutritionAssessmentProvider>();
    final growthProvider = context.watch<GrowthWhoProvider>();

    final latestHealth = _findHealth(healthProvider.items);
    final nutrition = _findNutrition(nutritionProvider.items);
    final history = growthProvider.history;

    return RefreshIndicator(
      onRefresh: () async {
        await Future.wait([
          context.read<HealthAssessmentProvider>().loadItems(),
          context.read<NutritionAssessmentProvider>().loadItems(),
          context.read<GrowthWhoProvider>().load(role: 'PARENT'),
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
          _PortalHeader(parentName: user?.fullName ?? 'Parent account'),
          const SizedBox(height: AppSpacing.md),
          _ChildProfileCard(health: latestHealth),
          const SizedBox(height: AppSpacing.sm),
          _HealthStatusCard(health: latestHealth),
          const SizedBox(height: AppSpacing.sm),
          _NutritionStatusCard(nutrition: nutrition),
          const SizedBox(height: AppSpacing.sm),
          _GrowthViewOnlyCard(history: history, latestHealth: latestHealth),
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
  const _PortalHeader({required this.parentName});

  final String parentName;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: AppColors.accent.withValues(alpha: 0.18),
              foregroundColor: AppColors.primary,
              child: const Icon(Icons.family_restroom),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Parent Portal',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Parent dashboard',
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
            const StatusChip(label: 'View only'),
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
      title: 'Child profile',
      icon: Icons.child_care_outlined,
      child: Column(
        children: [
          _InfoRow(
            label: 'Student',
            value: health?.studentName ?? 'Nguyen Minh An',
          ),
          _InfoRow(
            label: 'Student card',
            value: health?.studentCode ?? 'NBA2024.001',
          ),
          _InfoRow(label: 'Class', value: health?.className ?? 'Mam 1A'),
          _InfoRow(
            label: 'School year',
            value: health?.schoolYearName.isEmpty ?? true
                ? '2025-2026'
                : health!.schoolYearName,
          ),
          const _InfoRow(label: 'Status', value: 'Dang hoc'),
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
      title: 'Health status',
      icon: Icons.favorite_outline,
      trailing: StatusChip(label: health?.bmiStatus ?? 'No data'),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _MetricTile(
                  label: 'Height',
                  value: health == null ? '-' : '${health!.heightCm} cm',
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _MetricTile(
                  label: 'Weight',
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
            label: 'Last measured',
            value: health == null
                ? '-'
                : health!.assessmentDate.substring(0, 10),
          ),
          _InfoRow(label: 'Height status', value: health?.heightStatus ?? '-'),
          _InfoRow(label: 'Weight status', value: health?.weightStatus ?? '-'),
          _InfoRow(label: 'Note', value: health?.note ?? '-'),
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
      title: 'Nutrition status',
      icon: Icons.restaurant_outlined,
      trailing: StatusChip(label: nutrition?.statusSummary ?? 'No data'),
      child: Column(
        children: [
          _InfoRow(label: 'Period', value: nutrition?.period ?? 'dau_nam'),
          _InfoRow(
            label: 'Weight channel',
            value: nutrition?.weightChannel.isEmpty ?? true
                ? 'Binh thuong'
                : nutrition!.weightChannel,
          ),
          _InfoRow(
            label: 'Stunting',
            value: nutrition?.isStunting ?? false ? 'Yes' : 'No',
          ),
          _InfoRow(
            label: 'Severe stunting',
            value: nutrition?.isSevereStunting ?? false ? 'Yes' : 'No',
          ),
          _InfoRow(
            label: 'Obese',
            value: nutrition?.isObese ?? false ? 'Yes' : 'No',
          ),
          _InfoRow(label: 'Note', value: nutrition?.note ?? '-'),
        ],
      ),
    );
  }
}

class _GrowthViewOnlyCard extends StatelessWidget {
  const _GrowthViewOnlyCard({
    required this.history,
    required this.latestHealth,
  });

  final List<HealthAssessment> history;
  final HealthAssessment? latestHealth;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Growth WHO view-only',
      icon: Icons.trending_up,
      trailing: const StatusChip(label: 'WHO'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 180,
            width: double.infinity,
            child: CustomPaint(
              painter: _ParentGrowthChartPainter(history),
              child: history.isEmpty
                  ? Center(
                      child: Text(
                        'No growth history yet',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textGray,
                        ),
                      ),
                    )
                  : null,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          _InfoRow(label: 'BMI/age', value: latestHealth?.bmiStatus ?? '-'),
          _InfoRow(
            label: 'Height/age',
            value: latestHealth?.heightStatus ?? '-',
          ),
          _InfoRow(
            label: 'Weight/age',
            value: latestHealth?.weightStatus ?? '-',
          ),
          Text(
            'This portal is read-only. Please contact the school if any information looks incorrect.',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppColors.textGray),
          ),
        ],
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

class _ParentGrowthChartPainter extends CustomPainter {
  const _ParentGrowthChartPainter(this.history);

  final List<HealthAssessment> history;

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = AppColors.border
      ..strokeWidth = 1;
    final linePaint = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final pointPaint = Paint()
      ..color = AppColors.accent
      ..style = PaintingStyle.fill;

    const left = 28.0;
    const top = 12.0;
    const bottom = 26.0;
    const right = 12.0;
    final chart = Rect.fromLTRB(
      left,
      top,
      size.width - right,
      size.height - bottom,
    );

    for (var i = 0; i <= 4; i++) {
      final y = chart.top + chart.height * i / 4;
      canvas.drawLine(Offset(chart.left, y), Offset(chart.right, y), gridPaint);
    }

    if (history.isEmpty) {
      return;
    }

    final values = history.map((item) => item.bmi).where((value) => value > 0);
    final minValue = values.isEmpty ? 0.0 : values.reduce(math.min) - 1;
    final maxValue = values.isEmpty ? 1.0 : values.reduce(math.max) + 1;
    final range = (maxValue - minValue).abs() < 0.1 ? 1.0 : maxValue - minValue;
    final path = Path();

    for (var i = 0; i < history.length; i++) {
      final item = history[i];
      final x =
          chart.left +
          (history.length == 1
              ? chart.width / 2
              : chart.width * i / (history.length - 1));
      final y = chart.bottom - ((item.bmi - minValue) / range) * chart.height;
      final point = Offset(x, y);
      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
      canvas.drawCircle(point, 5, pointPaint);
    }

    canvas.drawPath(path, linePaint);
  }

  @override
  bool shouldRepaint(covariant _ParentGrowthChartPainter oldDelegate) {
    return oldDelegate.history != history;
  }
}
