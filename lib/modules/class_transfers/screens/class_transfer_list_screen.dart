import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/widgets/module_list_screen.dart';
import '../../auth/providers/auth_provider.dart';
import '../models/class_transfer.dart';
import '../providers/class_transfer_provider.dart';
import 'class_transfer_detail_screen.dart';
import 'class_transfer_form_screen.dart';

class ClassTransferListScreen extends StatefulWidget {
  const ClassTransferListScreen({super.key});

  @override
  State<ClassTransferListScreen> createState() =>
      _ClassTransferListScreenState();
}

class _ClassTransferListScreenState extends State<ClassTransferListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ClassTransferProvider>().loadItems();
    });
  }

  void _openForm([ClassTransfer? item]) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ClassTransferFormScreen(classTransfer: item),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isPrincipal =
        context.watch<AuthProvider>().currentUser?.role.toUpperCase() ==
        'PRINCIPAL';
    return Consumer<ClassTransferProvider>(
      builder: (context, provider, _) {
        return ModuleListScreen<ClassTransfer>(
          title: 'Chuyển lớp',
          items: provider.items,
          isLoading: provider.isLoading,
          errorMessage: provider.errorMessage,
          onRefresh: provider.loadItems,
          onAdd: () => _openForm(),
          itemTitle: (item) => item.studentName,
          itemSubtitle: (item) =>
              '${item.fromClassName} -> ${item.toClassName} | ${item.status}',
          itemStatus: (item) => item.status,
          onEdit: _openForm,
          showEdit: false,
          onDelete: (item) => provider.archiveItem(item.id),
          showDelete: false,
          onDetail: (item) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ClassTransferDetailScreen(classTransfer: item),
              ),
            );
          },
          extraActions: (item) => [
            if (isPrincipal && item.status == 'Pending') ...[
              ModuleListAction(
                label: 'Duyệt',
                icon: Icons.thumb_up_alt_outlined,
                onSelected: () => provider.updateStatus(item.id, 'approve'),
              ),
              ModuleListAction(
                label: 'Từ chối',
                icon: Icons.thumb_down_alt_outlined,
                onSelected: () => provider.updateStatus(item.id, 'reject'),
              ),
            ],
            if (item.status == 'Pending')
              ModuleListAction(
                label: 'Hủy yêu cầu',
                icon: Icons.cancel_outlined,
                onSelected: () => provider.updateStatus(item.id, 'cancel'),
                isDestructive: true,
              ),
          ],
        );
      },
    );
  }
}
