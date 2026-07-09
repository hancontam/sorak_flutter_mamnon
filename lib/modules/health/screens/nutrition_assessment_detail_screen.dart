import 'package:flutter/material.dart';

import '../../../core/widgets/simple_detail_screen.dart';
import '../models/nutrition_assessment.dart';

class NutritionAssessmentDetailScreen extends StatelessWidget {
  const NutritionAssessmentDetailScreen({super.key, required this.assessment});

  final NutritionAssessment assessment;

  @override
  Widget build(BuildContext context) {
    return SimpleDetailScreen(
      title: assessment.studentName,
      rows: [
        DetailRow(
          label: 'Student code',
          value: assessment.studentCode,
          icon: Icons.badge_outlined,
        ),
        DetailRow(
          label: 'Class',
          value: assessment.className,
          icon: Icons.class_outlined,
        ),
        DetailRow(
          label: 'Period',
          value: assessment.period,
          icon: Icons.event_repeat_outlined,
        ),
        DetailRow(
          label: 'Nutrition status',
          value: assessment.statusSummary,
          icon: Icons.restaurant_outlined,
        ),
        DetailRow(
          label: 'Latest BMI',
          value: assessment.latestBmi == 0
              ? '-'
              : assessment.latestBmi.toStringAsFixed(2),
          icon: Icons.favorite_outline,
        ),
        DetailRow(
          label: 'Latest BMI status',
          value: assessment.latestBmiStatus,
          icon: Icons.insights_outlined,
        ),
        DetailRow(
          label: 'Stunting',
          value: assessment.isStunting ? 'Yes' : 'No',
          icon: Icons.height,
        ),
        DetailRow(
          label: 'Severe stunting',
          value: assessment.isSevereStunting ? 'Yes' : 'No',
          icon: Icons.warning_amber_outlined,
        ),
        DetailRow(
          label: 'Obese',
          value: assessment.isObese ? 'Yes' : 'No',
          icon: Icons.monitor_weight_outlined,
        ),
        DetailRow(
          label: 'Note',
          value: assessment.note,
          icon: Icons.notes_outlined,
        ),
      ],
    );
  }
}
