import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import 'growth_who_screen.dart';
import 'health_assessment_list_screen.dart';
import 'nutrition_assessment_list_screen.dart';

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
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        if (widget.showTitle) ...[
          Text(
            'Health & Growth',
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
              label: Text('Health'),
            ),
            ButtonSegment<HealthSection>(
              value: HealthSection.nutrition,
              icon: Icon(Icons.restaurant_outlined),
              label: Text('Nutrition'),
            ),
            ButtonSegment<HealthSection>(
              value: HealthSection.growth,
              icon: Icon(Icons.trending_up),
              label: Text('Growth'),
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
          const SizedBox(height: 520, child: HealthAssessmentListScreen())
        else if (_selectedSection == HealthSection.nutrition)
          const SizedBox(height: 520, child: NutritionAssessmentListScreen())
        else if (_selectedSection == HealthSection.growth)
          const SizedBox(height: 720, child: GrowthWhoScreen())
        else
          _HealthSectionCard(section: _selectedSection),
      ],
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
