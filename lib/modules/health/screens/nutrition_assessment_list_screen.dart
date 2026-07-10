import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/widgets/module_list_screen.dart';
import '../models/nutrition_assessment.dart';
import '../providers/nutrition_assessment_provider.dart';
import 'nutrition_assessment_detail_screen.dart';
import 'nutrition_assessment_form_screen.dart';

class NutritionAssessmentListScreen extends StatefulWidget {
  const NutritionAssessmentListScreen({super.key});

  @override
  State<NutritionAssessmentListScreen> createState() =>
      _NutritionAssessmentListScreenState();
}

class _NutritionAssessmentListScreenState
    extends State<NutritionAssessmentListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NutritionAssessmentProvider>().loadItems();
    });
  }

  void _openForm([NutritionAssessment? item]) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => NutritionAssessmentFormScreen(assessment: item),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<NutritionAssessmentProvider>(
      builder: (context, provider, _) {
        return ModuleListScreen<NutritionAssessment>(
          title: 'Đánh giá nuôi dưỡng',
          items: provider.items,
          isLoading: provider.isLoading,
          errorMessage: provider.errorMessage,
          onRefresh: provider.loadItems,
          onAdd: () => _openForm(),
          searchHint: 'Tìm trẻ, lớp hoặc mã thẻ',
          itemTitle: (item) => item.studentName,
          itemSubtitle: (item) {
            final bmi = item.latestBmi == 0
                ? 'Chưa có BMI'
                : 'BMI ${item.latestBmi.toStringAsFixed(1)}';
            return '${item.className} | ${item.period} | $bmi';
          },
          itemStatus: (item) => item.statusSummary,
          itemFilterValue: (item) => item.className,
          onEdit: _openForm,
          // Backend has no nutrition DELETE/archive route — hide Delete UI.
          showDelete: false,
          onDelete: (_) async {},
          onDetail: (item) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    NutritionAssessmentDetailScreen(assessment: item),
              ),
            );
          },
        );
      },
    );
  }
}
