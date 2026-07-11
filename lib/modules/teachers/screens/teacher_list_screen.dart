import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/utils/ui_labels.dart';
import '../../../core/widgets/module_list_screen.dart';
import '../models/teacher.dart';
import '../providers/teacher_provider.dart';
import 'teacher_detail_screen.dart';
import 'teacher_form_screen.dart';

class TeacherListScreen extends StatefulWidget {
  const TeacherListScreen({super.key, this.showAppBar = true});

  final bool showAppBar;

  @override
  State<TeacherListScreen> createState() => _TeacherListScreenState();
}

class _TeacherListScreenState extends State<TeacherListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TeacherProvider>().loadItems();
    });
  }

  void _openForm([Teacher? item]) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => TeacherFormScreen(teacher: item)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TeacherProvider>(
      builder: (context, provider, _) {
        return ModuleListScreen<Teacher>(
          title: 'Cán bộ',
          showAppBar: widget.showAppBar,
          items: provider.items,
          isLoading: provider.isLoading,
          errorMessage: provider.errorMessage,
          onRefresh: provider.loadItems,
          onAdd: () => _openForm(),
          itemTitle: (item) => item.fullName,
          itemSubtitle: (item) => '${item.position} | ${item.email}',
          itemStatus: (item) => item.workStatus,
          itemFilterValue: (item) => UiLabels.workStatus(item.workStatus),
          onEdit: _openForm,
          onDelete: (item) => provider.archiveItem(item.id),
          onDetail: (item) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => TeacherDetailScreen(teacher: item),
              ),
            );
          },
        );
      },
    );
  }
}
