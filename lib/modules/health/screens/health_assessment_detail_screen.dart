import 'package:flutter/material.dart';

import '../../../core/widgets/simple_detail_screen.dart';
import '../models/health_assessment.dart';

class HealthAssessmentDetailScreen extends StatelessWidget {
  const HealthAssessmentDetailScreen({super.key, required this.assessment});

  final HealthAssessment assessment;

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
          label: 'Assessment date',
          value: assessment.assessmentDate.substring(0, 10),
          icon: Icons.event_outlined,
        ),
        DetailRow(
          label: 'Height',
          value: '${assessment.heightCm} cm',
          icon: Icons.height,
        ),
        DetailRow(
          label: 'Weight',
          value: '${assessment.weightKg} kg',
          icon: Icons.monitor_weight_outlined,
        ),
        DetailRow(
          label: 'BMI',
          value: assessment.bmi == 0 ? '-' : assessment.bmi.toStringAsFixed(2),
          icon: Icons.favorite_outline,
        ),
        DetailRow(
          label: 'BMI status',
          value: assessment.bmiStatus,
          icon: Icons.insights_outlined,
        ),
        DetailRow(
          label: 'Height status',
          value: assessment.heightStatus,
          icon: Icons.trending_up,
        ),
        DetailRow(
          label: 'Weight status',
          value: assessment.weightStatus,
          icon: Icons.scale_outlined,
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
