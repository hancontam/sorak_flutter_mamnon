import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/widgets/module_list_screen.dart';
import '../models/academic_year.dart';
import '../providers/academic_year_provider.dart';
import 'academic_year_detail_screen.dart';
import 'academic_year_form_screen.dart';

class AcademicYearListScreen extends StatefulWidget {
  const AcademicYearListScreen({super.key});

  @override
  State<AcademicYearListScreen> createState() => _AcademicYearListScreenState();
}

class _AcademicYearListScreenState extends State<AcademicYearListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AcademicYearProvider>().loadItems();
    });
  }

  void _openForm([AcademicYear? item]) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AcademicYearFormScreen(academicYear: item),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AcademicYearProvider>(
      builder: (context, provider, _) {
        return ModuleListScreen<AcademicYear>(
          title: 'Năm học',
          items: provider.items,
          isLoading: provider.isLoading,
          errorMessage: provider.errorMessage,
          onRefresh: provider.loadItems,
          onAdd: () => _openForm(),
          itemTitle: (item) => item.name,
          itemSubtitle: (item) =>
              '${item.startDate} - ${item.endDate} | ${item.status}',
          itemStatus: (item) => item.status,
          onEdit: _openForm,
          onDelete: (item) => provider.archiveItem(item.id),
          onDetail: (item) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => AcademicYearDetailScreen(academicYear: item),
              ),
            );
          },
          extraActions: (item) => [
            ModuleListAction(
              label: 'Activate',
              icon: Icons.check_circle_outline,
              onSelected: () => provider.activateYear(item.id),
            ),
          ],
        );
      },
    );
  }
}
