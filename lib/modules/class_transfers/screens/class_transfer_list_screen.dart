import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_options.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/text_normalizer.dart';
import '../../../core/utils/ui_labels.dart';
import '../../../core/widgets/app_search_bar.dart';
import '../../../core/widgets/empty_view.dart';
import '../../../core/widgets/error_view.dart';
import '../../../core/widgets/loading_view.dart';
import '../../../core/widgets/sorak_avatar.dart';
import '../../../core/widgets/sorak_status_badge.dart';
import '../../auth/providers/auth_provider.dart';
import '../models/class_transfer.dart';
import '../providers/class_transfer_provider.dart';
import 'class_transfer_form_screen.dart';

/// Web status filter options (STATUS_LABELS without Recorded).
const _statusFilterOptions = <AppOption<String>>[
  AppOption(value: '', label: 'Tất cả trạng thái'),
  AppOption(value: 'Pending', label: 'Chờ duyệt'),
  AppOption(value: 'Approved', label: 'Đã duyệt'),
  AppOption(value: 'Rejected', label: 'Từ chối'),
  AppOption(value: 'Cancelled', label: 'Đã hủy'),
  AppOption(value: 'Expired', label: 'Quá hạn'),
];

class ClassTransferListScreen extends StatefulWidget {
  const ClassTransferListScreen({super.key});

  @override
  State<ClassTransferListScreen> createState() =>
      _ClassTransferListScreenState();
}

class _ClassTransferListScreenState extends State<ClassTransferListScreen> {
  final _searchController = TextEditingController();
  String _search = '';
  String _statusFilter = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ClassTransferProvider>().loadItems();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openForm([ClassTransfer? item]) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ClassTransferFormScreen(classTransfer: item),
      ),
    );
  }

  List<ClassTransfer> _filteredItems(List<ClassTransfer> source) {
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
          item.fromClassName,
          item.toClassName,
          item.requesterName,
          item.reason,
          item.status,
        ].join(' '),
      );
      return haystack.contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isPrincipal =
        context.watch<AuthProvider>().currentUser?.role.toUpperCase() ==
        'PRINCIPAL';

    return Consumer<ClassTransferProvider>(
      builder: (context, provider, _) {
        final items = _filteredItems(provider.items);

        return Scaffold(
          appBar: AppBar(
            title: const Text('Chuyển lớp'),
            actions: [
              IconButton(
                tooltip: 'Làm mới',
                onPressed: provider.isLoading ? null : provider.loadItems,
                icon: const Icon(LucideIcons.refreshCcw, size: 20),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => _openForm(),
            tooltip: 'Tạo yêu cầu',
            child: const Icon(LucideIcons.plus),
          ),
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
                  key: ValueKey('class_transfer_status_$_statusFilter'),
                  initialValue: _statusFilter,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Trạng thái',
                    isDense: true,
                  ),
                  selectedItemBuilder: (context) {
                    return [
                      for (final option in _statusFilterOptions)
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            option.label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                    ];
                  },
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
                    title: 'Chưa có yêu cầu chuyển lớp',
                    message:
                        'Tạo yêu cầu mới hoặc đổi bộ lọc trạng thái để xem danh sách.',
                  ),
                ] else ...[
                  const SizedBox(height: AppSpacing.sm),
                  for (final item in items) ...[
                    _ClassTransferCard(
                      item: item,
                      isPrincipal: isPrincipal,
                      onApprove: () =>
                          provider.updateStatus(item.id, 'approve'),
                      onReject: () => provider.updateStatus(item.id, 'reject'),
                      onCancel: () => provider.updateStatus(item.id, 'cancel'),
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

class _ClassTransferCard extends StatelessWidget {
  const _ClassTransferCard({
    required this.item,
    required this.isPrincipal,
    required this.onApprove,
    required this.onReject,
    required this.onCancel,
  });

  final ClassTransfer item;
  final bool isPrincipal;
  final VoidCallback onApprove;
  final VoidCallback onReject;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final statusLabel = _transferStatusLabel(item.status);
    final statusTone = _transferStatusTone(item.status);
    final isPending = item.status == 'Pending';
    final showActions = isPending;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SorakAvatar(
                  seed: item.studentId,
                  fallbackLabel: item.studentName,
                  size: 44,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.studentName.isEmpty
                            ? 'Học sinh'
                            : item.studentName,
                        softWrap: true,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              fontWeight: FontWeight.w800,
                              height: 1.25,
                            ),
                      ),
                      const SizedBox(height: AppSpacing.xs / 2),
                      Text(
                        '${item.fromClassName.isEmpty ? '—' : item.fromClassName}'
                        ' → '
                        '${item.toClassName.isEmpty ? '—' : item.toClassName}',
                        softWrap: true,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.mutedForeground,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      _CompactStatusBadge(
                        label: statusLabel,
                        tone: statusTone,
                      ),
                    ],
                  ),
                ),
                if (showActions)
                  _TransferActionMenu(
                    isPrincipal: isPrincipal,
                    onApprove: onApprove,
                    onReject: onReject,
                    onCancel: onCancel,
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.muted,
                borderRadius: BorderRadius.circular(AppSpacing.radius),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  _InfoLine(
                    label: 'Học sinh',
                    value: item.studentName.isEmpty ? '—' : item.studentName,
                  ),
                  _InfoLine(
                    label: 'Lớp hiện tại',
                    value: item.fromClassName.isEmpty
                        ? '—'
                        : item.fromClassName,
                  ),
                  _InfoLine(
                    label: 'Lớp chuyển đến',
                    value: item.toClassName.isEmpty ? '—' : item.toClassName,
                  ),
                  _InfoLine(
                    label: 'Ngày hiệu lực',
                    value: _formatDate(item.effectiveDate),
                  ),
                  _InfoLine(
                    label: 'Người tạo',
                    value: item.requesterName.isEmpty
                        ? '—'
                        : item.requesterName,
                  ),
                  if (item.reason.isNotEmpty)
                    _InfoLine(label: 'Lý do', value: item.reason),
                  _InfoLine(label: 'Trạng thái', value: statusLabel),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TransferActionMenu extends StatelessWidget {
  const _TransferActionMenu({
    required this.isPrincipal,
    required this.onApprove,
    required this.onReject,
    required this.onCancel,
  });

  final bool isPrincipal;
  final VoidCallback onApprove;
  final VoidCallback onReject;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      tooltip: 'Thao tác',
      icon: const Icon(LucideIcons.ellipsisVertical, size: 20),
      onSelected: (value) {
        switch (value) {
          case 'approve':
            onApprove();
          case 'reject':
            onReject();
          case 'cancel':
            onCancel();
        }
      },
      itemBuilder: (context) {
        return [
          if (isPrincipal) ...[
            const PopupMenuItem(value: 'approve', child: Text('Duyệt')),
            const PopupMenuItem(value: 'reject', child: Text('Từ chối')),
          ],
          const PopupMenuItem(value: 'cancel', child: Text('Hủy yêu cầu')),
        ];
      },
    );
  }
}

class _CompactStatusBadge extends StatelessWidget {
  const _CompactStatusBadge({required this.label, required this.tone});

  final String label;
  final SorakStatusTone tone;

  @override
  Widget build(BuildContext context) {
    final scheme = switch (tone) {
      SorakStatusTone.success => (
        text: AppColors.statusSuccessText,
        background: AppColors.statusSuccessBackground,
        border: AppColors.statusSuccessBorder,
      ),
      SorakStatusTone.pending => (
        text: AppColors.statusWarningText,
        background: AppColors.statusWarningBackground,
        border: AppColors.statusWarningBorder,
      ),
      SorakStatusTone.error => (
        text: AppColors.statusErrorText,
        background: AppColors.statusErrorBackground,
        border: AppColors.statusErrorBorder,
      ),
      SorakStatusTone.neutral => (
        text: AppColors.statusNeutralText,
        background: AppColors.statusNeutralBackground,
        border: AppColors.statusNeutralBorder,
      ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: scheme.background,
        borderRadius: BorderRadius.circular(AppSpacing.radius),
        border: Border.all(color: scheme.border),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: scheme.text,
          fontWeight: FontWeight.w700,
          fontSize: 11,
          height: 1.15,
          letterSpacing: 0,
        ),
      ),
    );
  }
}

class _InfoLine extends StatelessWidget {
  const _InfoLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.mutedForeground,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            flex: 2,
            child: Text(
              value,
              textAlign: TextAlign.right,
              softWrap: true,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.foreground,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

String _transferStatusLabel(String status) {
  switch (status) {
    case 'Pending':
      return 'Chờ duyệt';
    case 'Approved':
      return 'Đã duyệt';
    case 'Rejected':
      return 'Từ chối';
    case 'Cancelled':
    case 'Canceled':
      return 'Đã hủy';
    case 'Expired':
      return 'Quá hạn';
    case 'Recorded':
      return 'Đã ghi nhận';
    default:
      return UiLabels.status(status);
  }
}

SorakStatusTone _transferStatusTone(String status) {
  switch (status) {
    case 'Pending':
      return SorakStatusTone.pending;
    case 'Approved':
    case 'Recorded':
      return SorakStatusTone.success;
    case 'Rejected':
      return SorakStatusTone.error;
    case 'Cancelled':
    case 'Canceled':
    case 'Expired':
      return SorakStatusTone.neutral;
    default:
      return SorakStatusTone.neutral;
  }
}

String _formatDate(String raw) {
  final trimmed = raw.trim();
  if (trimmed.isEmpty) {
    return '—';
  }
  final parsed = DateTime.tryParse(trimmed);
  if (parsed == null) {
    return trimmed;
  }
  final day = parsed.day.toString().padLeft(2, '0');
  final month = parsed.month.toString().padLeft(2, '0');
  return '$day/$month/${parsed.year}';
}
