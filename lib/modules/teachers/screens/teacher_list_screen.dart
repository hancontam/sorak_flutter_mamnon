import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_options.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/text_normalizer.dart';
import '../../../core/utils/ui_labels.dart';
import '../../../core/widgets/app_dropdown_field.dart';
import '../../../core/widgets/academic_year_app_bar_selector.dart';
import '../../../core/widgets/app_search_bar.dart';
import '../../../core/widgets/confirm_archive_dialog.dart';
import '../../../core/widgets/empty_view.dart';
import '../../../core/widgets/error_view.dart';
import '../../../core/widgets/loading_view.dart';
import '../../../core/widgets/sorak_avatar.dart';
import '../../../core/widgets/sorak_status_badge.dart';
import '../../academic_years/providers/active_academic_year_provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../models/teacher.dart';
import '../providers/teacher_provider.dart';
import 'teacher_form_screen.dart';

class TeacherListScreen extends StatefulWidget {
  const TeacherListScreen({super.key, this.showAppBar = true});

  final bool showAppBar;

  @override
  State<TeacherListScreen> createState() => _TeacherListScreenState();
}

class _TeacherListScreenState extends State<TeacherListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _search = '';
  String? _selectedStatus;
  int? _lastAcademicYearId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadForSelectedYear());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadForSelectedYear() async {
    final yearId = context.read<ActiveAcademicYearProvider>().selectedYearId;
    if (yearId == null) {
      await context.read<TeacherProvider>().loadItems();
      return;
    }
    await context.read<TeacherProvider>().loadForAcademicYear(yearId);
  }

  void _openForm([Teacher? teacher]) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => TeacherFormScreen(teacher: teacher)),
    );
  }

  void _openTeacherDetail(Teacher teacher) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSpacing.radius),
        ),
      ),
      builder: (_) => _TeacherDetailSheet(teacher: teacher),
    );
  }

  List<Teacher> _filteredTeachers(List<Teacher> teachers) {
    final query = normalizeVietnamese(_search);
    return teachers.where((teacher) {
      if (_selectedStatus != null && teacher.workStatus != _selectedStatus) {
        return false;
      }
      if (query.isEmpty) {
        return true;
      }
      return normalizeVietnamese(
        [teacher.fullName, teacher.email, teacher.phone].join(' '),
      ).contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final yearId = context.watch<ActiveAcademicYearProvider>().selectedYearId;
    if (yearId != _lastAcademicYearId) {
      _lastAcademicYearId = yearId;
      _selectedStatus = null;
    }

    final provider = context.watch<TeacherProvider>();
    final isPrincipal =
        context.watch<AuthProvider>().currentUser?.role.toUpperCase() ==
        'PRINCIPAL';
    final teachers = _filteredTeachers(provider.items);

    return Scaffold(
      appBar: widget.showAppBar
          ? AppBar(
              title: const Text('Cán bộ'),
              actions: [
                const AcademicYearAppBarSelector(),
                IconButton(
                  tooltip: 'Làm mới',
                  onPressed: provider.isLoading ? null : _loadForSelectedYear,
                  icon: const Icon(LucideIcons.refreshCcw, size: 20),
                ),
              ],
            )
          : null,
      floatingActionButton: isPrincipal
          ? FloatingActionButton(
              key: const ValueKey('teacher_add_button'),
              tooltip: 'Thêm cán bộ',
              onPressed: () => _openForm(),
              child: const Icon(LucideIcons.plus),
            )
          : null,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.md,
              0,
            ),
            child: AppSearchBar(
              controller: _searchController,
              hintText: 'Tìm tên / email / SĐT',
              onChanged: (value) => setState(() => _search = value),
              onClear: () {
                _searchController.clear();
                setState(() => _search = '');
              },
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: AppDropdownField<String>(
              key: ValueKey('teacher_status_filter_${_selectedStatus ?? ''}'),
              label: 'Lọc theo trạng thái',
              showLabel: false,
              options: [
                const AppOption(value: '', label: 'Tất cả trạng thái'),
                ...TeacherWorkStatusOptions.all,
              ],
              value: _selectedStatus ?? '',
              hintText: 'Tất cả trạng thái',
              onChanged: (value) => setState(() {
                _selectedStatus = value == null || value.isEmpty ? null : value;
              }),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          if (provider.isLoading) const LinearProgressIndicator(minHeight: 2),
          Expanded(
            child: _buildContent(context, provider, teachers, isPrincipal),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    TeacherProvider provider,
    List<Teacher> teachers,
    bool isPrincipal,
  ) {
    if (provider.isLoading && provider.items.isEmpty) {
      return const LoadingView();
    }
    if (provider.errorMessage != null && provider.items.isEmpty) {
      return ErrorView(
        message: provider.errorMessage!,
        onRetry: _loadForSelectedYear,
      );
    }
    if (provider.items.isEmpty) {
      return EmptyView(
        title: 'Chưa có cán bộ',
        message: 'Chưa có dữ liệu trong năm học đang chọn.',
        actionLabel: isPrincipal ? 'Thêm cán bộ' : null,
        onAction: isPrincipal ? () => _openForm() : null,
      );
    }
    if (teachers.isEmpty) {
      return EmptyView(
        title: 'Không tìm thấy cán bộ',
        message: 'Thử tên, email, số điện thoại hoặc đổi trạng thái.',
        type: EmptyViewType.search,
      );
    }

    return RefreshIndicator(
      onRefresh: _loadForSelectedYear,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.xs,
          AppSpacing.md,
          96,
        ),
        itemCount: teachers.length,
        separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
        itemBuilder: (context, index) => _TeacherCard(
          index: index + 1,
          teacher: teachers[index],
          canManage: isPrincipal,
          onTap: () => _openTeacherDetail(teachers[index]),
          onEdit: () => _openForm(teachers[index]),
          onArchive: () => _archiveTeacher(teachers[index]),
        ),
      ),
    );
  }

  Future<void> _archiveTeacher(Teacher teacher) async {
    final confirmed = await showConfirmArchiveDialog(
      context: context,
      title: 'Xóa cán bộ?',
      message:
          'Hồ sơ cán bộ sẽ được ẩn khỏi danh sách đang hoạt động và không bị xóa vĩnh viễn.',
    );
    if (!confirmed || !mounted) {
      return;
    }
    await context.read<TeacherProvider>().archiveItem(teacher.id);
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Đã xóa cán bộ khỏi danh sách')),
    );
  }
}

class _TeacherCard extends StatelessWidget {
  const _TeacherCard({
    required this.index,
    required this.teacher,
    required this.canManage,
    required this.onTap,
    required this.onEdit,
    required this.onArchive,
  });

  final int index;
  final Teacher teacher;
  final bool canManage;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onArchive;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$index.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.mutedForeground,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  SorakAvatar(
                    seed: teacher.accountId == 0
                        ? teacher.id
                        : teacher.accountId,
                    fallbackLabel: teacher.fullName,
                    size: 48,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _valueOrMissing(teacher.fullName),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _valueOrMissing(teacher.position),
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: AppColors.secondaryForeground,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                      ],
                    ),
                  ),
                  if (canManage)
                    PopupMenuButton<_TeacherAction>(
                      tooltip: 'Thao tác với cán bộ',
                      icon: const Icon(LucideIcons.ellipsisVertical, size: 20),
                      onSelected: (action) {
                        if (action == _TeacherAction.edit) {
                          onEdit();
                        } else {
                          onArchive();
                        }
                      },
                      itemBuilder: (context) => const [
                        PopupMenuItem(
                          value: _TeacherAction.edit,
                          child: Text('Chỉnh sửa'),
                        ),
                        PopupMenuItem(
                          value: _TeacherAction.archive,
                          child: Text(
                            'Xóa',
                            style: TextStyle(color: AppColors.destructive),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              SorakStatusBadge(label: teacher.workStatus),
              const SizedBox(height: AppSpacing.sm),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: AppColors.muted,
                  border: Border.all(color: AppColors.border),
                  borderRadius: BorderRadius.circular(AppSpacing.radius),
                ),
                child: Column(
                  children: [
                    _TeacherInfoLine(label: 'Email', value: teacher.email),
                    _TeacherInfoLine(label: 'SĐT', value: teacher.phone),
                    _TeacherInfoLine(
                      label: 'Giới tính',
                      value: UiLabels.gender(teacher.gender),
                    ),
                    _TeacherInfoLine(
                      label: 'Ngày sinh',
                      value: _formatDateOnly(teacher.dateOfBirth),
                    ),
                    _TeacherInfoLine(
                      label: 'Trình độ',
                      value: teacher.qualification,
                    ),
                    _TeacherInfoLine(
                      label: 'Ngày vào làm',
                      value: _formatDateOnly(teacher.workStartDate),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TeacherDetailSheet extends StatelessWidget {
  const _TeacherDetailSheet({required this.teacher});

  final Teacher teacher;

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.82,
      minChildSize: 0.5,
      maxChildSize: 0.94,
      builder: (context, scrollController) {
        return Column(
          children: [
            const SizedBox(height: AppSpacing.xs),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.input,
                borderRadius: BorderRadius.circular(AppSpacing.radius),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.sm,
                AppSpacing.md,
                AppSpacing.sm,
              ),
              child: Row(
                children: [
                  SorakAvatar(
                    seed: teacher.accountId == 0
                        ? teacher.id
                        : teacher.accountId,
                    fallbackLabel: teacher.fullName,
                    size: 52,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _valueOrMissing(teacher.fullName),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _valueOrMissing(teacher.position),
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: AppColors.mutedForeground,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(),
            Expanded(
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  AppSpacing.md,
                  AppSpacing.md,
                  AppSpacing.lg,
                ),
                children: [
                  Text(
                    'Chi tiết cán bộ',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: SorakStatusBadge(label: teacher.workStatus),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _TeacherDetailSection(
                    title: 'Thông tin công việc',
                    icon: LucideIcons.briefcaseBusiness,
                    rows: [
                      _TeacherDetailRow('Chức vụ', teacher.position),
                      _TeacherDetailRow(
                        'Trạng thái công tác',
                        UiLabels.workStatus(teacher.workStatus),
                      ),
                      _TeacherDetailRow('Trình độ', teacher.qualification),
                      _TeacherDetailRow(
                        'Ngày vào làm',
                        _formatDateOnly(teacher.workStartDate),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _TeacherDetailSection(
                    title: 'Thông tin liên hệ',
                    icon: LucideIcons.contactRound,
                    rows: [
                      _TeacherDetailRow('Email', teacher.email),
                      _TeacherDetailRow('Số điện thoại', teacher.phone),
                      _TeacherDetailRow('Địa chỉ', teacher.address),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _TeacherDetailSection(
                    title: 'Thông tin cá nhân',
                    icon: LucideIcons.userRound,
                    rows: [
                      _TeacherDetailRow(
                        'Giới tính',
                        UiLabels.gender(teacher.gender),
                      ),
                      _TeacherDetailRow(
                        'Ngày sinh',
                        _formatDateOnly(teacher.dateOfBirth),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _TeacherDetailSection extends StatelessWidget {
  const _TeacherDetailSection({
    required this.title,
    required this.icon,
    required this.rows,
  });

  final String title;
  final IconData icon;
  final List<_TeacherDetailRow> rows;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 20, color: AppColors.primary),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            for (var index = 0; index < rows.length; index++) ...[
              _TeacherDetailValue(data: rows[index]),
              if (index < rows.length - 1) const Divider(height: AppSpacing.md),
            ],
          ],
        ),
      ),
    );
  }
}

class _TeacherDetailRow {
  const _TeacherDetailRow(this.label, this.value);

  final String label;
  final String? value;
}

class _TeacherDetailValue extends StatelessWidget {
  const _TeacherDetailValue({required this.data});

  final _TeacherDetailRow data;

  @override
  Widget build(BuildContext context) {
    final isMissing = _isMissingValue(data.value);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            data.label,
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
            _valueOrMissing(data.value),
            textAlign: TextAlign.right,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: isMissing ? AppColors.primary : AppColors.foreground,
              fontWeight: isMissing ? FontWeight.w600 : FontWeight.w700,
              fontStyle: isMissing ? FontStyle.italic : FontStyle.normal,
            ),
          ),
        ),
      ],
    );
  }
}

enum _TeacherAction { edit, archive }

class _TeacherInfoLine extends StatelessWidget {
  const _TeacherInfoLine({required this.label, required this.value});

  final String label;
  final String? value;

  @override
  Widget build(BuildContext context) {
    final isMissing = _isMissingValue(value);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
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
              _valueOrMissing(value),
              textAlign: TextAlign.right,
              softWrap: true,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: isMissing ? AppColors.primary : AppColors.foreground,
                fontWeight: isMissing ? FontWeight.w600 : FontWeight.w700,
                fontStyle: isMissing ? FontStyle.italic : FontStyle.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

String _valueOrMissing(String? value) {
  final trimmed = value?.trim() ?? '';
  return trimmed.isEmpty || trimmed == '-' ? 'Chưa có' : trimmed;
}

bool _isMissingValue(String? value) {
  final trimmed = value?.trim() ?? '';
  return trimmed.isEmpty || trimmed == '-';
}

String _formatDateOnly(String? value) {
  final raw = value?.trim() ?? '';
  if (raw.isEmpty) {
    return '';
  }

  final date = DateTime.tryParse(raw);
  if (date == null) {
    return raw.length >= 10 ? raw.substring(0, 10) : raw;
  }

  final day = date.day.toString().padLeft(2, '0');
  final month = date.month.toString().padLeft(2, '0');
  return '$day/$month/${date.year}';
}
