import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/ui_labels.dart';
import '../../../core/widgets/sorak_status_badge.dart';

/// Presentation-only cards for Parent profile data from `/auth/me`.
/// Mirrors web `ParentPage.jsx` field set without extra API calls.
class ParentProfileInfoCards extends StatelessWidget {
  const ParentProfileInfoCards({
    super.key,
    required this.profile,
    this.showStudentHeader = true,
    this.showStudentInfo = true,
    this.showParents = true,
  });

  final Map<String, dynamic> profile;
  final bool showStudentHeader;
  final bool showStudentInfo;
  final bool showParents;

  @override
  Widget build(BuildContext context) {
    final enrollment = _firstMap(profile['enrollments']);
    final schoolClass = enrollment == null
        ? null
        : _asMap(enrollment['class']);
    final schoolYear = schoolClass == null
        ? null
        : _asMap(schoolClass['school_year']);
    final parents = _parentList(profile['parents']);

    final childName = _text(profile['full_name']);
    final cardNumber = _text(profile['student_id_card_number']);
    final status = _text(profile['student_status']);

    final studentRows = <_RowData>[
      _RowData('Mã trẻ', cardNumber),
      _RowData(
        'Lớp',
        schoolClass == null ? '' : _text(schoolClass['class_name']),
      ),
      _RowData(
        'Năm học',
        schoolYear == null ? '' : _text(schoolYear['name']),
      ),
      _RowData('Trạng thái', UiLabels.status(status)),
      _RowData('Ngày sinh', _formatDate(_text(profile['date_of_birth']))),
      _RowData('Giới tính', UiLabels.gender(_text(profile['gender']))),
      _RowData('Khối', _text(profile['grade_level'])),
      _RowData('Dân tộc', _text(profile['ethnicity'])),
      _RowData('Quốc tịch', _text(profile['nationality'])),
      _RowData('Nhóm máu', _text(profile['blood_type'])),
      _RowData('Nơi sinh', _text(profile['birth_place'])),
      _RowData('Địa chỉ', _text(profile['current_address'])),
      _RowData('Số điện thoại liên hệ', _text(profile['contact_phone'])),
    ].where((row) => row.value.isNotEmpty && row.value != '-').toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (showStudentHeader) ...[
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          childName.isEmpty ? 'Trẻ' : childName,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w900),
                        ),
                        if (cardNumber.isNotEmpty) ...[
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            cardNumber,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: AppColors.mutedForeground,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (status.isNotEmpty)
                    SorakStatusBadge(label: status),
                ],
              ),
            ),
          ),
          if (showStudentInfo || (showParents && parents.isNotEmpty))
            const SizedBox(height: AppSpacing.sm),
        ],
        if (showStudentInfo)
          _SectionCard(
            title: 'Thông tin học sinh',
            child: studentRows.isEmpty
                ? Text(
                    'Chưa có thông tin học sinh để hiển thị.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.mutedForeground,
                    ),
                  )
                : Column(
                    children: [
                      for (final row in studentRows) _InfoRow(row: row),
                    ],
                  ),
          ),
        if (showParents && parents.isNotEmpty) ...[
          if (showStudentInfo) const SizedBox(height: AppSpacing.sm),
          _SectionCard(
            title: 'Phụ huynh',
            child: Column(
              children: [
                for (var i = 0; i < parents.length; i++) ...[
                  if (i > 0)
                    const Divider(height: AppSpacing.md * 2),
                  _ParentTile(parent: parents[i]),
                ],
              ],
            ),
          ),
        ] else if (showParents && !showStudentInfo && !showStudentHeader)
          _SectionCard(
            title: 'Phụ huynh',
            child: Text(
              'Chưa có thông tin phụ huynh để hiển thị.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.mutedForeground,
              ),
            ),
          ),
      ],
    );
  }
}

class _ParentTile extends StatelessWidget {
  const _ParentTile({required this.parent});

  final Map<String, dynamic> parent;

  @override
  Widget build(BuildContext context) {
    final name = _text(parent['full_name']);
    final relationship = _text(parent['relationship']);
    final phone = _text(parent['phone']);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                name.isEmpty ? 'Phụ huynh' : name,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.foreground,
                ),
              ),
            ),
            if (relationship.isNotEmpty)
              Text(
                relationship,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.mutedForeground,
                  fontWeight: FontWeight.w600,
                ),
              ),
          ],
        ),
        if (phone.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.xs / 2),
          Text(
            phone,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ],
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            decoration: const BoxDecoration(
              color: AppColors.muted,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(AppSpacing.radius),
              ),
            ),
            child: Text(
              title.toUpperCase(),
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: AppColors.mutedForeground,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.6,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.sm,
              AppSpacing.md,
              AppSpacing.md,
            ),
            child: child,
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.row});

  final _RowData row;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs / 2 + 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              row.label,
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
              row.value,
              textAlign: TextAlign.right,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
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

class _RowData {
  const _RowData(this.label, this.value);

  final String label;
  final String value;
}

String _text(Object? value) {
  if (value == null) {
    return '';
  }
  final text = '$value'.trim();
  if (text.isEmpty || text == 'null') {
    return '';
  }
  return text;
}

String _formatDate(String raw) {
  if (raw.isEmpty) {
    return '';
  }
  final parsed = DateTime.tryParse(raw);
  if (parsed == null) {
    return raw;
  }
  final day = parsed.day.toString().padLeft(2, '0');
  final month = parsed.month.toString().padLeft(2, '0');
  return '$day/$month/${parsed.year}';
}

Map<String, dynamic>? _firstMap(Object? value) {
  if (value is List && value.isNotEmpty) {
    return _asMap(value.first);
  }
  return null;
}

Map<String, dynamic>? _asMap(Object? value) {
  if (value is Map<String, dynamic>) {
    return value;
  }
  if (value is Map) {
    return value.map((key, item) => MapEntry('$key', item));
  }
  return null;
}

List<Map<String, dynamic>> _parentList(Object? value) {
  if (value is! List) {
    return const [];
  }
  return value.map(_asMap).whereType<Map<String, dynamic>>().toList();
}
