import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/widgets/module_list_screen.dart';
import '../models/school_class.dart';
import '../providers/class_provider.dart';
import 'class_detail_screen.dart';
import 'class_form_screen.dart';

class ClassListScreen extends StatefulWidget {
  const ClassListScreen({super.key});

  @override
  State<ClassListScreen> createState() => _ClassListScreenState();
}

class _ClassListScreenState extends State<ClassListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ClassProvider>().loadItems();
    });
  }

  void _openForm([SchoolClass? item]) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ClassFormScreen(schoolClass: item)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ClassProvider>(
      builder: (context, provider, _) {
        return ModuleListScreen<SchoolClass>(
          title: 'Classes',
          items: provider.items,
          isLoading: provider.isLoading,
          errorMessage: provider.errorMessage,
          onRefresh: provider.loadItems,
          onAdd: () => _openForm(),
          itemTitle: (item) => item.className,
          itemSubtitle: (item) => 'Room ${item.room} | ${item.ageGroup} | ${item.teacherName}',
          onEdit: _openForm,
          onDelete: (item) => provider.archiveItem(item.id),
          onDetail: (item) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => ClassDetailScreen(schoolClass: item)),
            );
          },
        );
      },
    );
  }
}
