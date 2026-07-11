import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

Future<bool> showConfirmArchiveDialog({
  required BuildContext context,
  String title = 'Xóa dữ liệu',
  String message =
      'Dữ liệu sẽ được ẩn khỏi danh sách đang hoạt động và không bị xóa vĩnh viễn.',
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        icon: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.destructive,
            borderRadius: BorderRadius.circular(AppSpacing.radius),
          ),
          child: const Icon(
            LucideIcons.trash2,
            color: AppColors.primaryForeground,
          ),
        ),
        title: Text(title),
        content: Text(message),
        actionsPadding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          0,
          AppSpacing.md,
          AppSpacing.md,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.destructive,
              foregroundColor: AppColors.primaryForeground,
            ),
            onPressed: () => Navigator.pop(context, true),
            icon: const Icon(LucideIcons.trash2, size: 18),
            label: const Text('Xóa'),
          ),
        ],
      );
    },
  );

  return result ?? false;
}
