import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/sorak_toggle_group.dart';
import 'growth_who_screen.dart';
import 'health_roster_dashboard.dart';

enum HealthSection { health, nutrition, growth }

class HealthScreen extends StatefulWidget {
  const HealthScreen({
    super.key,
    this.initialSection = HealthSection.health,
    this.showTitle = true,
  });

  final HealthSection initialSection;
  final bool showTitle;

  @override
  State<HealthScreen> createState() => _HealthScreenState();
}

class _HealthScreenState extends State<HealthScreen> {
  late HealthSection _selectedSection = widget.initialSection;

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    // Bottom clearance for system inset + NavigationBar so last items scroll up.
    final bottomPadding =
        AppSpacing.md +
        media.padding.bottom +
        kBottomNavigationBarHeight +
        AppSpacing.sm;

    return SafeArea(
      top: false,
      bottom: false,
      child: ListView(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.md,
          AppSpacing.md,
          bottomPadding,
        ),
        children: [
          if (widget.showTitle) ...[
            Text(
              'Sức khỏe & Tăng trưởng',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
          SorakToggleGroup<HealthSection>(
            options: const [
              SorakToggleOption<HealthSection>(
                value: HealthSection.health,
                icon: LucideIcons.heartPulse,
                label: 'Sức khỏe',
              ),
              SorakToggleOption<HealthSection>(
                value: HealthSection.nutrition,
                icon: LucideIcons.utensils,
                label: 'Nuôi dưỡng',
              ),
              SorakToggleOption<HealthSection>(
                value: HealthSection.growth,
                icon: LucideIcons.trendingUp,
                label: 'Tăng trưởng',
              ),
            ],
            selected: _selectedSection,
            onChanged: (section) => setState(() {
              _selectedSection = section;
            }),
          ),
          const SizedBox(height: AppSpacing.md),
          if (_selectedSection == HealthSection.health)
            const HealthRosterDashboard(mode: HealthRosterMode.health)
          else if (_selectedSection == HealthSection.nutrition)
            const HealthRosterDashboard(mode: HealthRosterMode.nutrition)
          else if (_selectedSection == HealthSection.growth)
            // No fixed height — Growth content participates in parent ListView
            // via shrink-wrapped internal layout when embedded.
            const GrowthWhoScreen(embedded: true)
          else
            _HealthSectionCard(section: _selectedSection),
        ],
      ),
    );
  }
}

class _HealthSectionCard extends StatelessWidget {
  const _HealthSectionCard({required this.section});

  final HealthSection section;

  @override
  Widget build(BuildContext context) {
    final content = switch (section) {
      HealthSection.health => _SectionContent(
        title: 'Đánh giá sức khỏe',
        subtitle: 'Nhập nhanh chiều cao, cân nặng, BMI và ghi chú sức khỏe.',
        icon: LucideIcons.heartPulse,
      ),
      HealthSection.nutrition => _SectionContent(
        title: 'Nuôi dưỡng',
        subtitle: 'Theo dõi dinh dưỡng và ghi chú theo lớp được phân công.',
        icon: LucideIcons.utensils,
      ),
      HealthSection.growth => _SectionContent(
        title: 'Tăng trưởng WHO',
        subtitle: 'Xem tình trạng và biểu đồ tăng trưởng WHO của từng trẻ.',
        icon: LucideIcons.trendingUp,
      ),
    };

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(content.icon, color: AppColors.primary),
            const SizedBox(height: AppSpacing.sm),
            Text(
              content.title,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              content.subtitle,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.textGray),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionContent {
  const _SectionContent({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final IconData icon;
}
