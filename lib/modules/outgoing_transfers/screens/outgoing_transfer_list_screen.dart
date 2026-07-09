import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/widgets/module_list_screen.dart';
import '../models/outgoing_transfer.dart';
import '../providers/outgoing_transfer_provider.dart';
import 'outgoing_transfer_detail_screen.dart';
import 'outgoing_transfer_form_screen.dart';

class OutgoingTransferListScreen extends StatefulWidget {
  const OutgoingTransferListScreen({super.key});

  @override
  State<OutgoingTransferListScreen> createState() =>
      _OutgoingTransferListScreenState();
}

class _OutgoingTransferListScreenState
    extends State<OutgoingTransferListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OutgoingTransferProvider>().loadItems();
    });
  }

  void _openForm([OutgoingTransfer? item]) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => OutgoingTransferFormScreen(outgoingTransfer: item),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<OutgoingTransferProvider>(
      builder: (context, provider, _) {
        return ModuleListScreen<OutgoingTransfer>(
          title: 'Outgoing Transfers',
          items: provider.items,
          isLoading: provider.isLoading,
          errorMessage: provider.errorMessage,
          onRefresh: provider.loadItems,
          onAdd: () => _openForm(),
          itemTitle: (item) => item.studentName,
          itemSubtitle: (item) => '${item.destinationSchool} | ${item.status}',
          itemStatus: (item) => item.status,
          onEdit: _openForm,
          onDelete: (item) => provider.archiveItem(item.id),
          onDetail: (item) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    OutgoingTransferDetailScreen(outgoingTransfer: item),
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
