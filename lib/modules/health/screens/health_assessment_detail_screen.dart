import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

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
          label: 'Ngày đánh giá',
          value: assessment.assessmentDate.substring(0, 10),
          icon: LucideIcons.calendarDays,
        ),
        DetailRow(
          label: 'Chiều cao',
          value: '${assessment.heightCm} cm',
          icon: LucideIcons.ruler,
        ),
        DetailRow(
          label: 'Cân nặng',
          value: '${assessment.weightKg} kg',
          icon: LucideIcons.weight,
        ),
        DetailRow(
          label: 'BMI',
          value: assessment.bmi == 0 ? '-' : assessment.bmi.toStringAsFixed(2),
          icon: LucideIcons.heartPulse,
        ),
        DetailRow(
          label: 'Tình trạng BMI',
          value: assessment.bmiStatus,
          icon: LucideIcons.chartNoAxesCombined,
        ),
        DetailRow(
          label: 'Tình trạng chiều cao',
          value: assessment.heightStatus,
          icon: LucideIcons.trendingUp,
        ),
        DetailRow(
          label: 'Tình trạng cân nặng',
          value: assessment.weightStatus,
          icon: LucideIcons.scale,
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
