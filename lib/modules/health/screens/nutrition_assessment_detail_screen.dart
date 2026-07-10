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
          label: 'Mã trẻ',
          value: assessment.studentCode,
          icon: Icons.badge_outlined,
        ),
        DetailRow(
          label: 'Lớp',
          value: assessment.className,
          icon: Icons.class_outlined,
        ),
        DetailRow(
          label: 'Giai đoạn',
          value: assessment.period,
          icon: Icons.event_repeat_outlined,
        ),
        DetailRow(
          label: 'Tình trạng dinh dưỡng',
          value: assessment.statusSummary,
          icon: Icons.restaurant_outlined,
        ),
        DetailRow(
          label: 'BMI gần nhất',
          value: assessment.latestBmi == 0
              ? '-'
              : assessment.latestBmi.toStringAsFixed(2),
          icon: Icons.favorite_outline,
        ),
        DetailRow(
          label: 'Tình trạng BMI gần nhất',
          value: assessment.latestBmiStatus,
          icon: Icons.insights_outlined,
        ),
        DetailRow(
          label: 'Thấp còi',
          value: assessment.isStunting ? 'Có' : 'Không',
          icon: Icons.height,
        ),
        DetailRow(
          label: 'Thấp còi nặng',
          value: assessment.isSevereStunting ? 'Có' : 'Không',
          icon: Icons.warning_amber_outlined,
        ),
        DetailRow(
          label: 'Béo phì',
          value: assessment.isObese ? 'Có' : 'Không',
          icon: Icons.monitor_weight_outlined,
        ),
        DetailRow(
          label: 'Ghi chú',
          value: assessment.note,
          icon: Icons.notes_outlined,
        ),
      ],
    );
  }
}
