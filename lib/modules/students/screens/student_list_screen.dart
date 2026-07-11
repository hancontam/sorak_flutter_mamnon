import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/utils/ui_labels.dart';
import '../../../core/widgets/module_list_screen.dart';
import '../../auth/providers/auth_provider.dart';
import '../models/student.dart';
import '../providers/student_provider.dart';
import 'student_detail_screen.dart';
import 'student_form_screen.dart';

class StudentListScreen extends StatefulWidget {
  const StudentListScreen({super.key, this.showAppBar = true});

  final bool showAppBar;

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
    final isPrincipal =
        context.watch<AuthProvider>().currentUser?.role.toUpperCase() ==
        'PRINCIPAL';
    return Consumer<StudentProvider>(
      builder: (context, provider, _) {
        return ModuleListScreen<Student>(
          title: 'Học sinh',
          showAppBar: widget.showAppBar,
          items: provider.items,
          isLoading: provider.isLoading,
          errorMessage: provider.errorMessage,
          onRefresh: provider.loadItems,
          onAdd: () => _openForm(),
          itemTitle: (item) => item.fullName,
          itemSubtitle: (item) =>
              '${item.className} | ${UiLabels.status(item.studentStatus)}',
          itemStatus: (item) => item.studentStatus,
          onEdit: _openForm,
          onDelete: (item) => provider.archiveItem(item.id),
          showDelete: isPrincipal,
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
