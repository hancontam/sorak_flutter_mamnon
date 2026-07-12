import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/simple_form_screen.dart';
import '../models/academic_year.dart';
import '../providers/academic_year_provider.dart';

class AcademicYearFormScreen extends StatefulWidget {
  const AcademicYearFormScreen({super.key, this.academicYear});

  final AcademicYear? academicYear;

  @override
  State<AcademicYearFormScreen> createState() => _AcademicYearFormScreenState();
}

class _AcademicYearFormScreenState extends State<AcademicYearFormScreen> {
  bool _isPromoting = false;

  bool get _isEditing => widget.academicYear != null;

  bool get _canPromote =>
      _isEditing && widget.academicYear!.status.toLowerCase() == 'active';

  Future<void> _promoteStudents() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => const _PromotionConfirmDialog(),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _isPromoting = true);
    try {
      final result = await context.read<AcademicYearProvider>().promoteStudents(
        widget.academicYear!.id,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Đã lên lớp: ${_count(result, 'promoted')} · '
            'Tốt nghiệp: ${_count(result, 'graduated')} · '
            'Bỏ qua: ${_count(result, 'skipped')}',
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(apiErrorMessage(error))));
    } finally {
      if (mounted) setState(() => _isPromoting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final academicYear = widget.academicYear;
    return SimpleFormScreen(
      title: _isEditing ? 'Cập nhật năm học' : 'Tạo năm học',
      fields: [
        FormFieldConfig(
          name: 'name',
          label: 'Tên năm học *',
          type: _isEditing
              ? SimpleFormFieldType.readonly
              : SimpleFormFieldType.text,
        ),
        const FormFieldConfig(
          name: 'start_date',
          label: 'Ngày bắt đầu *',
          type: SimpleFormFieldType.date,
        ),
        const FormFieldConfig(
          name: 'end_date',
          label: 'Ngày kết thúc *',
          type: SimpleFormFieldType.date,
        ),
      ],
      initialValues: {
        'name': academicYear?.name ?? '',
        'start_date': _dateOnly(academicYear?.startDate),
        'end_date': _dateOnly(academicYear?.endDate),
      },
      extraContent: _canPromote
          ? OutlinedButton.icon(
              key: const ValueKey('promote_students_button'),
              onPressed: _isPromoting ? null : _promoteStudents,
              icon: _isPromoting
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(LucideIcons.graduationCap, size: 20),
              label: const Text('Lên lớp học sinh'),
            )
          : null,
      onSave: (data) {
        final provider = context.read<AcademicYearProvider>();
        if (academicYear == null) {
          return provider.createItem(data);
        }
        return provider.updateItem(academicYear.id, data);
      },
    );
  }

  int _count(Map<String, dynamic> result, String key) {
    return (result[key] as num?)?.toInt() ?? 0;
  }
}

class _PromotionConfirmDialog extends StatelessWidget {
  const _PromotionConfirmDialog();

  static const _steps = [
    ('Nhà trẻ', 'Mầm'),
    ('Mầm', 'Chồi'),
    ('Chồi', 'Lá'),
    ('Lá', 'Tốt nghiệp'),
  ];

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Lên lớp học sinh?'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'CHUYỂN CẤP',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: AppColors.mutedForeground,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.border),
                borderRadius: BorderRadius.circular(AppSpacing.radius),
              ),
              child: Column(
                children: [
                  for (var index = 0; index < _steps.length; index++) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.xs,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              _steps[index].$1,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const Icon(
                            LucideIcons.arrowRight,
                            size: 16,
                            color: AppColors.mutedForeground,
                          ),
                          Expanded(
                            child: Text(
                              _steps[index].$2,
                              textAlign: TextAlign.end,
                              style: TextStyle(
                                color: index == _steps.length - 1
                                    ? AppColors.warning
                                    : AppColors.foreground,
                                fontWeight: index == _steps.length - 1
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (index != _steps.length - 1)
                      const Divider(height: 1, color: AppColors.border),
                  ],
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            const _PromotionNote(
              text:
                  'Chỉ lên lớp học sinh có lớp và đã hoàn thành chương trình.',
            ),
            const _PromotionNote(text: 'Lớp Lá tốt nghiệp, không đem lên.'),
            const _PromotionNote(
              text: 'Học sinh đã lên lớp ở năm này sẽ được bỏ qua.',
            ),
            const _PromotionNote(
              text: 'Học sinh lên lớp chưa được xếp lớp, xếp thủ công sau.',
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Hủy'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Lên lớp'),
        ),
      ],
    );
  }
}

class _PromotionNote extends StatelessWidget {
  const _PromotionNote({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 7),
            child: Icon(
              LucideIcons.circle,
              size: 5,
              color: AppColors.mutedForeground,
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.mutedForeground,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

String _dateOnly(String? raw) {
  final trimmed = (raw ?? '').trim();
  if (trimmed.isEmpty) return '';

  final datePart = trimmed.split(RegExp(r'[T\s]')).first;
  if (datePart.length >= 10) return datePart.substring(0, 10);

  final parsed = DateTime.tryParse(trimmed);
  if (parsed == null) return datePart;
  final month = parsed.month.toString().padLeft(2, '0');
  final day = parsed.day.toString().padLeft(2, '0');
  return '${parsed.year}-$month-$day';
}
