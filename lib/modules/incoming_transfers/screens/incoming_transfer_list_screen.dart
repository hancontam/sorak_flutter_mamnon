import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/widgets/module_list_screen.dart';
import '../models/incoming_transfer.dart';
import '../providers/incoming_transfer_provider.dart';
import 'incoming_transfer_detail_screen.dart';
import 'incoming_transfer_form_screen.dart';

class IncomingTransferListScreen extends StatefulWidget {
  const IncomingTransferListScreen({super.key});

  @override
  State<IncomingTransferListScreen> createState() =>
      _IncomingTransferListScreenState();
}

class _IncomingTransferListScreenState
    extends State<IncomingTransferListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<IncomingTransferProvider>().loadItems();
    });
  }

  void _openForm([IncomingTransfer? item]) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => IncomingTransferFormScreen(incomingTransfer: item),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<IncomingTransferProvider>(
      builder: (context, provider, _) {
        return ModuleListScreen<IncomingTransfer>(
          title: 'Incoming Transfers',
          items: provider.items,
          isLoading: provider.isLoading,
          errorMessage: provider.errorMessage,
          onRefresh: provider.loadItems,
          onAdd: () => _openForm(),
          itemTitle: (item) => item.studentName,
          itemSubtitle: (item) => '${item.previousSchool} | ${item.status}',
          itemStatus: (item) => item.status,
          onEdit: _openForm,
          onDelete: (item) => provider.archiveItem(item.id),
          onDetail: (item) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    IncomingTransferDetailScreen(incomingTransfer: item),
              ),
            );
          },
          extraActions: (item) => [
            ModuleListAction(
              label: 'Cancel',
              icon: Icons.cancel_outlined,
              onSelected: () => provider.cancelTransfer(item.id),
              isDestructive: true,
            ),
          ],
        );
      },
    );
  }
}
