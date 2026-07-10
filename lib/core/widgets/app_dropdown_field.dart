import 'package:flutter/material.dart';

import '../constants/app_options.dart';

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
  });

  final String label;
  final List<AppOption<T>> options;
  final T? value;
  final ValueChanged<T?> onChanged;
  final String? hintText;
  final FormFieldValidator<T>? validator;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final values = options.map((option) => option.value).toSet();
    final effectiveValue = values.contains(value) ? value : null;

    return DropdownButtonFormField<T>(
      initialValue: effectiveValue,
      isExpanded: true,
      decoration: InputDecoration(labelText: label),
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
