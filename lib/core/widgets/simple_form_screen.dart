import 'package:flutter/material.dart';

import 'app_text_field.dart';

class FormFieldConfig {
  const FormFieldConfig({
    required this.name,
    required this.label,
    this.keyboardType,
    this.maxLines = 1,
  });

  final String name;
  final String label;
  final TextInputType? keyboardType;
  final int maxLines;
}

class SimpleFormScreen extends StatefulWidget {
  const SimpleFormScreen({
    super.key,
    required this.title,
    required this.fields,
    required this.onSave,
    this.initialValues = const {},
  });

  final String title;
  final List<FormFieldConfig> fields;
  final Map<String, String> initialValues;
  final Future<bool> Function(Map<String, dynamic> data) onSave;

  @override
  State<SimpleFormScreen> createState() => _SimpleFormScreenState();
}

class _SimpleFormScreenState extends State<SimpleFormScreen> {
  final Map<String, TextEditingController> _controllers = {};
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    for (final field in widget.fields) {
      _controllers[field.name] = TextEditingController(
        text: widget.initialValues[field.name] ?? '',
      );
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _isSaving = true);

    final data = <String, dynamic>{};
    for (final entry in _controllers.entries) {
      data[entry.key] = entry.value.text.trim();
    }

    final success = await widget.onSave(data);

    if (!mounted) {
      return;
    }

    setState(() => _isSaving = false);

    if (success) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: widget.fields.length + 1,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          if (index == widget.fields.length) {
            return FilledButton.icon(
              onPressed: _isSaving ? null : _save,
              icon: _isSaving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save),
              label: const Text('Save'),
            );
          }

          final field = widget.fields[index];
          return AppTextField(
            controller: _controllers[field.name]!,
            label: field.label,
            keyboardType: field.keyboardType,
            maxLines: field.maxLines,
          );
        },
      ),
    );
  }
}
