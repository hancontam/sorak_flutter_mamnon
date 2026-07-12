import 'package:flutter/material.dart';

import '../constants/app_options.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

class AppDropdownField<T> extends StatelessWidget {
  const AppDropdownField({
    super.key,
    required this.label,
    required this.options,
    required this.value,
    required this.onChanged,
    this.hintText,
    this.validator,
    this.enabled = true,
    this.showLabel = true,
  });

  final String label;
  final List<AppOption<T>> options;
  final T? value;
  final ValueChanged<T?> onChanged;
  final String? hintText;
  final FormFieldValidator<T>? validator;
  final bool enabled;

  /// When false, only the dropdown value/hint is shown (no floating label).
  final bool showLabel;

  @override
  Widget build(BuildContext context) {
    final values = options.map((option) => option.value).toSet();
    final effectiveValue = values.contains(value) ? value : null;

    return DropdownButtonFormField<T>(
      initialValue: effectiveValue,
      isExpanded: true,
      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
        color: enabled ? AppColors.foreground : AppColors.mutedForeground,
        fontWeight: enabled ? FontWeight.w500 : FontWeight.w600,
      ),
      iconDisabledColor: AppColors.mutedForeground,
      decoration: InputDecoration(
        labelText: showLabel && label.isNotEmpty ? label : null,
        filled: !enabled,
        fillColor: enabled ? AppColors.background : AppColors.muted,
        disabledBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(AppSpacing.radius)),
          borderSide: BorderSide(color: AppColors.border),
        ),
        labelStyle: TextStyle(
          color: enabled
              ? AppColors.secondaryForeground
              : AppColors.mutedForeground,
        ),
      ),
      hint: hintText == null ? null : Text(hintText!),
      validator: validator,
      onChanged: enabled ? onChanged : null,
      items: [
        for (final option in options)
          DropdownMenuItem<T>(
            value: option.value,
            child: Text(
              option.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
      ],
    );
  }
}
