import 'package:flutter/material.dart';

import 'confirm_dialog.dart';
import 'empty_view.dart';
import 'error_view.dart';
import 'loading_view.dart';

class ModuleListScreen<T> extends StatelessWidget {
  const ModuleListScreen({
    super.key,
    required this.title,
    required this.items,
    required this.isLoading,
    required this.errorMessage,
    required this.onRefresh,
    required this.onAdd,
    required this.itemTitle,
    required this.itemSubtitle,
    required this.onEdit,
    required this.onDelete,
    this.onDetail,
    this.extraActions,
    this.showDelete = true,
  });

  final String title;
  final List<T> items;
  final bool isLoading;
  final String? errorMessage;
  final Future<void> Function() onRefresh;
  final VoidCallback onAdd;
  final String Function(T item) itemTitle;
  final String Function(T item) itemSubtitle;
  final void Function(T item) onEdit;
  final Future<void> Function(T item) onDelete;
  final void Function(T item)? onDetail;
  final List<Widget> Function(T item)? extraActions;
  final bool showDelete;

  @override
  Widget build(BuildContext context) {
    Widget body;

    if (isLoading && items.isEmpty) {
      body = const LoadingView();
    } else if (errorMessage != null && items.isEmpty) {
      body = ErrorView(message: errorMessage!, onRetry: onRefresh);
    } else if (items.isEmpty) {
      body = const EmptyView(message: 'No records yet');
    } else {
      body = RefreshIndicator(
        onRefresh: onRefresh,
        child: ListView.separated(
          padding: const EdgeInsets.all(12),
          itemCount: items.length,
          separatorBuilder: (context, index) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final item = items[index];
            return Card(
              child: ListTile(
                title: Text(itemTitle(item)),
                subtitle: Text(itemSubtitle(item)),
                onTap: onDetail == null ? null : () => onDetail!(item),
                trailing: Wrap(
                  spacing: 4,
                  children: [
                    ...?extraActions?.call(item),
                    IconButton(
                      tooltip: 'Edit',
                      icon: const Icon(Icons.edit),
                      onPressed: () => onEdit(item),
                    ),
                    if (showDelete)
                      IconButton(
                        tooltip: 'Delete',
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () => _confirmDelete(context, item),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: onRefresh,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: body,
      floatingActionButton: FloatingActionButton(
        onPressed: onAdd,
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, T item) async {
    final confirmed = await showConfirmDialog(
      context: context,
      title: 'Delete record',
      message: 'This will archive the record. Continue?',
    );

    if (confirmed) {
      await onDelete(item);
    }
  }
}
