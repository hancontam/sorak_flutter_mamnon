import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
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
          SegmentedButton<HealthSection>(
            segments: const [
              ButtonSegment<HealthSection>(
                value: HealthSection.health,
                icon: Icon(Icons.favorite_outline),
                label: Text('Sức khỏe'),
              ),
              ButtonSegment<HealthSection>(
                value: HealthSection.nutrition,
                icon: Icon(Icons.restaurant_outlined),
                label: Text('Nuôi dưỡng'),
              ),
              ButtonSegment<HealthSection>(
                value: HealthSection.growth,
                icon: Icon(Icons.trending_up),
                label: Text('Tăng trưởng'),
              ),
            ],
            selected: {_selectedSection},
            onSelectionChanged: (values) {
              setState(() {
                _selectedSection = values.first;
              });
            },
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
        title: 'Health assessment',
        subtitle: 'Quick entry for height, weight, BMI and health notes.',
        icon: Icons.favorite_outline,
      ),
      HealthSection.nutrition => _SectionContent(
        title: 'Nutrition',
        subtitle: 'Track meals and nutrition notes for assigned classes.',
        icon: Icons.restaurant_outlined,
      ),
      HealthSection.growth => _SectionContent(
        title: 'WHO growth',
        subtitle: 'View growth status and WHO chart summary for each child.',
        icon: Icons.trending_up,
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
