import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

class AppReadonlyField extends StatelessWidget {
  const AppReadonlyField({super.key, required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: value,
      enabled: false,
      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
        color: AppColors.mutedForeground,
        fontWeight: FontWeight.w600,
      ),
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: AppColors.muted,
        disabledBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(AppSpacing.radius)),
          borderSide: BorderSide(color: AppColors.border),
        ),
        labelStyle: const TextStyle(color: AppColors.mutedForeground),
      ),
    );
  }
}
