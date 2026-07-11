import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

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
          icon: LucideIcons.badgeCheck,
        ),
        DetailRow(
          label: 'Lớp',
          value: assessment.className,
          icon: LucideIcons.school,
        ),
        DetailRow(
          label: 'Giai đoạn',
          value: assessment.period,
          icon: LucideIcons.calendarSync,
        ),
        DetailRow(
          label: 'Tình trạng dinh dưỡng',
          value: assessment.statusSummary,
          icon: LucideIcons.utensils,
        ),
        DetailRow(
          label: 'BMI gần nhất',
          value: assessment.latestBmi == 0
              ? '-'
              : assessment.latestBmi.toStringAsFixed(2),
          icon: LucideIcons.heartPulse,
        ),
        DetailRow(
          label: 'Tình trạng BMI gần nhất',
          value: assessment.latestBmiStatus,
          icon: LucideIcons.chartNoAxesCombined,
        ),
        DetailRow(
          label: 'Thấp còi',
          value: assessment.isStunting ? 'Có' : 'Không',
          icon: LucideIcons.ruler,
        ),
        DetailRow(
          label: 'Thấp còi nặng',
          value: assessment.isSevereStunting ? 'Có' : 'Không',
          icon: LucideIcons.triangleAlert,
        ),
        DetailRow(
          label: 'Béo phì',
          value: assessment.isObese ? 'Có' : 'Không',
          icon: LucideIcons.weight,
        ),
        DetailRow(
          label: 'Ghi chú',
          value: assessment.note,
          icon: LucideIcons.notebookText,
        ),
      ],
    );
  }
}
