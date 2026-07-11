import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

Future<bool> showConfirmDialog({
  required BuildContext context,
  required String title,
  required String message,
  String confirmText = 'Xác nhận',
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.destructive,
              foregroundColor: AppColors.primaryForeground,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: Text(confirmText),
          ),
        ],
      );
    },
  );

  return result ?? false;
}
