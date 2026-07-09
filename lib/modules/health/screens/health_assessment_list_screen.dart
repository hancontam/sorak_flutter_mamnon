import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/widgets/module_list_screen.dart';
import '../models/health_assessment.dart';
import '../providers/health_assessment_provider.dart';
import 'health_assessment_detail_screen.dart';
import 'health_assessment_form_screen.dart';

class HealthAssessmentListScreen extends StatefulWidget {
  const HealthAssessmentListScreen({super.key});

  @override
  State<HealthAssessmentListScreen> createState() =>
      _HealthAssessmentListScreenState();
}

class _HealthAssessmentListScreenState
    extends State<HealthAssessmentListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HealthAssessmentProvider>().loadItems();
    });
  }

  void _openForm([HealthAssessment? item]) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => HealthAssessmentFormScreen(assessment: item),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HealthAssessmentProvider>(
      builder: (context, provider, _) {
        return ModuleListScreen<HealthAssessment>(
          title: 'Health Assessments',
          items: provider.items,
          isLoading: provider.isLoading,
          errorMessage: provider.errorMessage,
          onRefresh: provider.loadItems,
          onAdd: () => _openForm(),
          searchHint: 'Search student, class, or card number',
          itemTitle: (item) => item.studentName,
          itemSubtitle: (item) {
            final date = item.assessmentDate.substring(0, 10);
            return '${item.className} | $date | ${item.heightCm} cm, ${item.weightKg} kg';
          },
          itemStatus: (item) =>
              item.bmiStatus.isEmpty ? 'No status' : item.bmiStatus,
          itemFilterValue: (item) => item.className,
          onEdit: _openForm,
          onDelete: (item) => provider.archiveItem(item.id),
          onDetail: (item) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => HealthAssessmentDetailScreen(assessment: item),
              ),
            );
          },
        );
      },
    );
  }
}
