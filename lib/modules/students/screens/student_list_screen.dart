import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/widgets/module_list_screen.dart';
import '../models/student.dart';
import '../providers/student_provider.dart';
import 'student_detail_screen.dart';
import 'student_form_screen.dart';

class StudentListScreen extends StatefulWidget {
  const StudentListScreen({super.key});

  @override
  State<StudentListScreen> createState() => _StudentListScreenState();
}

class _StudentListScreenState extends State<StudentListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StudentProvider>().loadItems();
    });
  }

  void _openForm([Student? item]) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => StudentFormScreen(student: item)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<StudentProvider>(
      builder: (context, provider, _) {
        return ModuleListScreen<Student>(
          title: 'Students',
          items: provider.items,
          isLoading: provider.isLoading,
          errorMessage: provider.errorMessage,
          onRefresh: provider.loadItems,
          onAdd: () => _openForm(),
          itemTitle: (item) => item.fullName,
          itemSubtitle: (item) => '${item.className} | ${item.studentStatus}',
          itemStatus: (item) => item.studentStatus,
          onEdit: _openForm,
          onDelete: (item) => provider.archiveItem(item.id),
          onDetail: (item) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => StudentDetailScreen(student: item),
              ),
            );
          },
        );
      },
    );
  }
}
