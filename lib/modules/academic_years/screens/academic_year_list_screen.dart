import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../../core/utils/ui_labels.dart';
import '../../../core/widgets/module_list_screen.dart';
import '../models/academic_year.dart';
import '../providers/academic_year_provider.dart';
import 'academic_year_form_screen.dart';

class AcademicYearListScreen extends StatefulWidget {
  const AcademicYearListScreen({super.key, this.showAppBar = true});

  final bool showAppBar;

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
          showAppBar: widget.showAppBar,
          items: provider.items,
          isLoading: provider.isLoading,
          errorMessage: provider.errorMessage,
          onRefresh: provider.loadItems,
          onAdd: () => _openForm(),
          itemTitle: (item) => item.name,
          itemSubtitle: (item) =>
              '${_formatDateOnly(item.startDate)} - ${_formatDateOnly(item.endDate)}',
          itemStatus: (item) => UiLabels.status(item.status),
          itemFilterValue: (item) => UiLabels.status(item.status),
          filterLabel: 'Trạng thái',
          useFilterDropdown: true,
          onEdit: _openForm,
          onDelete: (item) => provider.archiveItem(item.id),
          // List only — no detail screen in this flow.
          onDetail: null,
          extraActions: (item) => [
            ModuleListAction(
              label: 'Kích hoạt',
              icon: LucideIcons.circleCheck,
              onSelected: () => provider.activateYear(item.id),
            ),
          ],
        );
      },
    );
  }
}

String _formatDateOnly(String raw) {
  final trimmed = raw.trim();
  if (trimmed.isEmpty) {
    return '—';
  }
  final datePart = trimmed.split(RegExp(r'[T\s]')).first;
  final parsed = DateTime.tryParse(datePart) ?? DateTime.tryParse(trimmed);
  if (parsed == null) {
    return datePart.length >= 10 ? datePart.substring(0, 10) : datePart;
  }
  final day = parsed.day.toString().padLeft(2, '0');
  final month = parsed.month.toString().padLeft(2, '0');
  return '$day/$month/${parsed.year}';
}
