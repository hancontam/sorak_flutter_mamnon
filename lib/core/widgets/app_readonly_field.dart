import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class AppReadonlyField extends StatelessWidget {
  const AppReadonlyField({super.key, required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: value,
      readOnly: true,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        suffixIcon: const Icon(LucideIcons.lock, size: 20),
      ),
    );
  }
}
