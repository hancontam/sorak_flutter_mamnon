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
          label: 'Ngày đánh giá',
          value: assessment.assessmentDate.substring(0, 10),
          icon: Icons.event_outlined,
        ),
        DetailRow(
          label: 'Chiều cao',
          value: '${assessment.heightCm} cm',
          icon: Icons.height,
        ),
        DetailRow(
          label: 'Cân nặng',
          value: '${assessment.weightKg} kg',
          icon: Icons.monitor_weight_outlined,
        ),
        DetailRow(
          label: 'BMI',
          value: assessment.bmi == 0 ? '-' : assessment.bmi.toStringAsFixed(2),
          icon: Icons.favorite_outline,
        ),
        DetailRow(
          label: 'Tình trạng BMI',
          value: assessment.bmiStatus,
          icon: Icons.insights_outlined,
        ),
        DetailRow(
          label: 'Tình trạng chiều cao',
          value: assessment.heightStatus,
          icon: Icons.trending_up,
        ),
        DetailRow(
          label: 'Tình trạng cân nặng',
          value: assessment.weightStatus,
          icon: Icons.scale_outlined,
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
