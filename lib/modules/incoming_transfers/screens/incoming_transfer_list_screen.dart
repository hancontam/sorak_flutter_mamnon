import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_options.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/text_normalizer.dart';
import '../../../core/widgets/app_search_bar.dart';
import '../../../core/widgets/confirm_archive_dialog.dart';
import '../../../core/widgets/empty_view.dart';
import '../../../core/widgets/error_view.dart';
import '../../../core/widgets/loading_view.dart';
import '../../auth/providers/auth_provider.dart';
import '../../transfers/widgets/school_transfer_card.dart';
import '../models/incoming_transfer.dart';
import '../providers/incoming_transfer_provider.dart';
import 'incoming_transfer_form_screen.dart';

const _statusFilterOptions = <AppOption<String>>[
  AppOption(value: '', label: 'Tất cả trạng thái'),
  AppOption(value: 'Recorded', label: 'Đã ghi nhận'),
  AppOption(value: 'Cancelled', label: 'Đã hủy'),
];

class IncomingTransferListScreen extends StatefulWidget {
  const IncomingTransferListScreen({super.key});

  @override
  State<IncomingTransferListScreen> createState() =>
      _IncomingTransferListScreenState();
}

class _IncomingTransferListScreenState
    extends State<IncomingTransferListScreen> {
  final _searchController = TextEditingController();
  String _search = '';
  String _statusFilter = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<IncomingTransferProvider>().loadItems();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openForm([IncomingTransfer? item]) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => IncomingTransferFormScreen(incomingTransfer: item),
      ),
    );
  }

  List<IncomingTransfer> _filtered(List<IncomingTransfer> source) {
    final query = normalizeVietnamese(_search);
    return source.where((item) {
      if (_statusFilter.isNotEmpty && item.status != _statusFilter) {
        return false;
      }
      if (query.isEmpty) {
        return true;
      }
      final haystack = normalizeVietnamese(
        [
          item.studentName,
          item.cardNumber,
          item.className,
          item.schoolYearName,
          item.previousSchool,
          item.status,
        ].join(' '),
      );
      return haystack.contains(query);
    }).toList();
  }

  Future<void> _cancel(IncomingTransfer item) async {
    final reasonController = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Hủy hồ sơ chuyển đến'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hồ sơ hủy vẫn được lưu để đối chiếu nhưng không tính vào báo cáo chính thức.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: AppSpacing.sm),
              TextField(
                controller: reasonController,
                decoration: const InputDecoration(
                  labelText: 'Lý do hủy (tuỳ chọn)',
                ),
                maxLines: 2,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Đóng'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Hủy hồ sơ'),
            ),
          ],
        );
      },
    );

    final reason = reasonController.text.trim();
    reasonController.dispose();
    if (confirmed != true || !mounted) {
      return;
    }

    await context.read<IncomingTransferProvider>().cancelTransfer(
      item.id,
      cancelReason: reason.isEmpty ? null : reason,
    );
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Đã hủy hồ sơ')));
  }

  Future<void> _delete(IncomingTransfer item) async {
    final ok = await showConfirmArchiveDialog(
      context: context,
      title: 'Xóa hồ sơ chuyển đến',
      message:
          'Hồ sơ sẽ được ẩn khỏi danh sách (archive/soft delete), không xóa vĩnh viễn.',
    );
    if (!ok || !mounted) {
      return;
    }
    await context.read<IncomingTransferProvider>().archiveItem(item.id);
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Đã xóa hồ sơ')));
  }

  @override
  Widget build(BuildContext context) {
    final isPrincipal =
        context.watch<AuthProvider>().currentUser?.role.toUpperCase() ==
        'PRINCIPAL';

    return Consumer<IncomingTransferProvider>(
      builder: (context, provider, _) {
        final items = _filtered(provider.items);

        return Scaffold(
          appBar: AppBar(
            title: const Text('Chuyển trường đến'),
            actions: [
              IconButton(
                tooltip: 'Làm mới',
                onPressed: provider.isLoading ? null : provider.loadItems,
                icon: const Icon(LucideIcons.refreshCcw, size: 20),
              ),
            ],
          ),
          floatingActionButton: isPrincipal
              ? FloatingActionButton(
                  onPressed: () => _openForm(),
                  tooltip: 'Ghi nhận',
                  child: const Icon(LucideIcons.plus),
                )
              : null,
          body: RefreshIndicator(
            onRefresh: provider.loadItems,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.sm,
                AppSpacing.md,
                88,
              ),
              children: [
                AppSearchBar(
                  controller: _searchController,
                  hintText: 'Tìm học sinh...',
                  onChanged: (value) => setState(() => _search = value),
                  onClear: () {
                    _searchController.clear();
                    setState(() => _search = '');
                  },
                ),
                const SizedBox(height: AppSpacing.sm),
                DropdownButtonFormField<String>(
                  key: ValueKey('incoming_status_$_statusFilter'),
                  initialValue: _statusFilter,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Trạng thái',
                    isDense: true,
                  ),
                  items: [
                    for (final option in _statusFilterOptions)
                      DropdownMenuItem(
                        value: option.value,
                        child: Text(option.label),
                      ),
                  ],
                  onChanged: (value) {
                    setState(() => _statusFilter = value ?? '');
                  },
                ),
                if (provider.errorMessage != null) ...[
                  const SizedBox(height: AppSpacing.md),
                  ErrorView(
                    message: provider.errorMessage!,
                    onRetry: provider.loadItems,
                  ),
                ] else if (provider.isLoading) ...[
                  const SizedBox(height: AppSpacing.lg),
                  const LoadingView(),
                ] else if (items.isEmpty) ...[
                  const SizedBox(height: AppSpacing.lg),
                  const EmptyView(
                    title: 'Chưa có hồ sơ chuyển đến',
                    message:
                        'Ghi nhận hồ sơ mới hoặc đổi bộ lọc để xem danh sách.',
                  ),
                ] else ...[
                  const SizedBox(height: AppSpacing.sm),
                  for (final item in items) ...[
                    SchoolTransferCard(
                      studentId: item.studentId,
                      studentName: item.studentName,
                      cardNumber: item.cardNumber,
                      className: item.className,
                      schoolYearName: item.schoolYearName,
                      schoolLabel: 'Trường chuyển từ',
                      schoolValue: item.previousSchool,
                      transferDate: item.transferDate,
                      status: item.status,
                      reason: item.reason,
                      note: item.note,
                      showEdit: isPrincipal && item.status == 'Recorded',
                      showCancel: isPrincipal && item.status == 'Recorded',
                      showDelete: isPrincipal,
                      onEdit: () => _openForm(item),
                      onCancel: () => _cancel(item),
                      onDelete: () => _delete(item),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                  ],
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
