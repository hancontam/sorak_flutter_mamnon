import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../utils/text_normalizer.dart';
import 'app_search_bar.dart';
import 'confirm_archive_dialog.dart';
import 'empty_view.dart';
import 'error_view.dart';
import 'filter_chip_row.dart';
import 'loading_view.dart';
import 'status_chip.dart';

class ModuleListAction {
  const ModuleListAction({
    required this.label,
    required this.icon,
    required this.onSelected,
    this.isDestructive = false,
  });

  final String label;
  final IconData icon;
  final VoidCallback onSelected;
  final bool isDestructive;
}

class ModuleListScreen<T> extends StatefulWidget {
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
    this.itemStatus,
    this.itemFilterValue,
    this.searchHint,
    this.showAdd = true,
    this.showEdit = true,
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
  final List<ModuleListAction> Function(T item)? extraActions;
  final String Function(T item)? itemStatus;
  final String Function(T item)? itemFilterValue;
  final String? searchHint;
  final bool showAdd;
  final bool showEdit;
  final bool showDelete;

  @override
  State<ModuleListScreen<T>> createState() => _ModuleListScreenState<T>();
}

class _ModuleListScreenState<T> extends State<ModuleListScreen<T>> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  String? _selectedFilter;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<T> get _filteredItems {
    final query = normalizeVietnamese(_query);
    final selectedFilter = _selectedFilter;

    return widget.items.where((item) {
      if (selectedFilter != null && _filterValue(item) != selectedFilter) {
        return false;
      }

      if (query.isEmpty) {
        return true;
      }

      final searchableText = [
        widget.itemTitle(item),
        widget.itemSubtitle(item),
        widget.itemStatus?.call(item) ?? '',
        _filterValue(item) ?? '',
      ].join(' ');

      return normalizeVietnamese(searchableText).contains(query);
    }).toList();
  }

  List<String> get _filterOptions {
    final values = widget.items
        .map(_filterValue)
        .whereType<String>()
        .map((value) => value.trim())
        .where((value) => value.isNotEmpty)
        .toSet()
        .toList();

    values.sort();
    return values;
  }

  String? _filterValue(T item) {
    final value =
        widget.itemFilterValue?.call(item) ?? widget.itemStatus?.call(item);
    final trimmed = value?.trim();
    return trimmed == null || trimmed.isEmpty ? null : trimmed;
  }

  @override
  Widget build(BuildContext context) {
    Widget body;

    if (widget.isLoading && widget.items.isEmpty) {
      body = const LoadingView();
    } else if (widget.errorMessage != null && widget.items.isEmpty) {
      body = ErrorView(
        message: widget.errorMessage!,
        onRetry: widget.onRefresh,
      );
    } else if (widget.items.isEmpty) {
      body = EmptyView(
        title: 'Chưa có dữ liệu',
        message: 'Không có dữ liệu phù hợp với năm học và quyền hiện tại.',
        actionLabel: widget.showAdd ? 'Tạo mới' : null,
        onAction: widget.showAdd ? widget.onAdd : null,
      );
    } else {
      final filteredItems = _filteredItems;
      final filterOptions = _filterOptions;

      body = Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.xs,
            ),
            child: AppSearchBar(
              controller: _searchController,
              hintText: widget.searchHint ?? 'Tìm kiếm ${widget.title}',
              onChanged: (value) {
                setState(() {
                  _query = value;
                });
              },
              onClear: () {
                _searchController.clear();
                setState(() {
                  _query = '';
                });
              },
            ),
          ),
          if (filterOptions.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.xs),
            FilterChipRow(
              options: filterOptions,
              selectedOption: _selectedFilter,
              onSelected: (value) {
                setState(() {
                  _selectedFilter = value;
                });
              },
            ),
            const SizedBox(height: AppSpacing.xs),
          ],
          if (widget.isLoading) const LinearProgressIndicator(minHeight: 2),
          Expanded(
            child: filteredItems.isEmpty
                ? EmptyView(
                    title: 'Không tìm thấy dữ liệu',
                    message:
                        'Thử từ khóa khác, đổi bộ lọc hoặc xóa nội dung tìm kiếm.',
                    icon: Icons.search_off,
                    type: EmptyViewType.search,
                    actionLabel: 'Xóa bộ lọc',
                    onAction: () {
                      _searchController.clear();
                      setState(() {
                        _query = '';
                        _selectedFilter = null;
                      });
                    },
                  )
                : RefreshIndicator(
                    onRefresh: widget.onRefresh,
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.md,
                        AppSpacing.sm,
                        AppSpacing.md,
                        88,
                      ),
                      itemCount: filteredItems.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: AppSpacing.sm),
                      itemBuilder: (context, index) {
                        final item = filteredItems[index];
                        return _ModuleListCard<T>(
                          title: widget.itemTitle(item),
                          subtitle: widget.itemSubtitle(item),
                          status: widget.itemStatus?.call(item),
                          extraActions: widget.extraActions?.call(item),
                          showEdit: widget.showEdit,
                          showDelete: widget.showDelete,
                          onTap: widget.onDetail == null
                              ? null
                              : () => widget.onDetail!(item),
                          onEdit: () => widget.onEdit(item),
                          onDelete: () => _confirmDelete(context, item),
                        );
                      },
                    ),
                  ),
          ),
        ],
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            tooltip: 'Làm mới',
            onPressed: widget.onRefresh,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: body,
      floatingActionButton: widget.showAdd
          ? FloatingActionButton(
              key: const ValueKey('module_add_button'),
              onPressed: widget.onAdd,
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  Future<void> _confirmDelete(BuildContext context, T item) async {
    final messenger = ScaffoldMessenger.of(context);
    final confirmed = await showConfirmArchiveDialog(context: context);

    if (confirmed) {
      try {
        await widget.onDelete(item);

        if (!mounted) {
          return;
        }

        messenger.showSnackBar(
          const SnackBar(content: Text('Đã xóa dữ liệu khỏi danh sách')),
        );
      } catch (_) {
        if (!mounted) {
          return;
        }

        messenger.showSnackBar(
          const SnackBar(content: Text('Chưa thể xóa dữ liệu')),
        );
      }
    }
  }
}

class _ModuleListCard<T> extends StatelessWidget {
  const _ModuleListCard({
    required this.title,
    required this.subtitle,
    required this.showEdit,
    required this.showDelete,
    required this.onEdit,
    required this.onDelete,
    this.status,
    this.extraActions,
    this.onTap,
  });

  final String title;
  final String subtitle;
  final String? status;
  final bool showEdit;
  final bool showDelete;
  final List<ModuleListAction>? extraActions;
  final VoidCallback? onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        title: Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: AppSpacing.xs),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                subtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: AppColors.textGray),
              ),
              if (status != null && status!.trim().isNotEmpty) ...[
                const SizedBox(height: AppSpacing.xs),
                StatusChip(label: status!),
              ],
            ],
          ),
        ),
        onTap: onTap,
        trailing: _ModuleListActionMenu(
          extraActions: extraActions ?? const [],
          showEdit: showEdit,
          showDelete: showDelete,
          onEdit: onEdit,
          onDelete: onDelete,
        ),
      ),
    );
  }
}

class _ModuleListActionMenu extends StatelessWidget {
  const _ModuleListActionMenu({
    required this.extraActions,
    required this.showEdit,
    required this.showDelete,
    required this.onEdit,
    required this.onDelete,
  });

  final List<ModuleListAction> extraActions;
  final bool showEdit;
  final bool showDelete;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final actions = [
      ...extraActions,
      if (showEdit)
        ModuleListAction(
          label: 'Chỉnh sửa',
          icon: Icons.edit_outlined,
          onSelected: onEdit,
        ),
      if (showDelete)
        ModuleListAction(
          label: 'Xóa',
          icon: Icons.delete_outline,
          onSelected: onDelete,
          isDestructive: true,
        ),
    ];

    if (actions.isEmpty) {
      return const Icon(Icons.chevron_right, color: AppColors.textGray);
    }

    return PopupMenuButton<int>(
      tooltip: 'Thao tác khác',
      icon: const Icon(Icons.more_vert),
      onSelected: (index) => actions[index].onSelected(),
      itemBuilder: (context) {
        return [
          for (var index = 0; index < actions.length; index++)
            PopupMenuItem<int>(
              value: index,
              child: _ModuleListActionMenuItem(action: actions[index]),
            ),
        ];
      },
    );
  }
}

class _ModuleListActionMenuItem extends StatelessWidget {
  const _ModuleListActionMenuItem({required this.action});

  final ModuleListAction action;

  @override
  Widget build(BuildContext context) {
    final color = action.isDestructive ? AppColors.error : AppColors.textDark;

    return Row(
      children: [
        Icon(action.icon, color: color),
        const SizedBox(width: AppSpacing.sm),
        Text(
          action.label,
          style: TextStyle(color: color, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}
