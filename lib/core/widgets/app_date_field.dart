import 'package:flutter/material.dart';

class AppDateField extends StatelessWidget {
  const AppDateField({
    super.key,
    required this.controller,
    required this.label,
    this.validator,
    this.firstDate,
    this.lastDate,
    this.enabled = true,
  });

  final TextEditingController controller;
  final String label;
  final FormFieldValidator<String>? validator;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      readOnly: true,
      enabled: enabled,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        suffixIcon: const Icon(Icons.calendar_month_outlined),
      ),
      onTap: enabled ? () => _pickDate(context) : null,
    );
  }

  Future<void> _pickDate(BuildContext context) async {
    final initialDate = _parseDate(controller.text) ?? DateTime.now();
    final start = firstDate ?? DateTime(2000);
    final end = lastDate ?? DateTime(DateTime.now().year + 10, 12, 31);

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate.isBefore(start) || initialDate.isAfter(end)
          ? DateTime.now()
          : initialDate,
      firstDate: start,
      lastDate: end,
      helpText: 'Chọn ngày',
      cancelText: 'Hủy',
      confirmText: 'Chọn',
    );

    if (picked == null) {
      return;
    }

    controller.text = _formatDate(picked);
  }

  DateTime? _parseDate(String value) {
    if (value.trim().isEmpty) {
      return null;
    }
    return DateTime.tryParse(value.trim());
  }

  String _formatDate(DateTime value) {
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    return '${value.year}-$month-$day';
  }
}
