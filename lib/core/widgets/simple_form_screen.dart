import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import 'app_text_field.dart';

class FormFieldConfig {
  const FormFieldConfig({
    required this.name,
    required this.label,
    this.keyboardType,
    this.maxLines = 1,
    this.isRequired = true,
  });

  final String name;
  final String label;
  final TextInputType? keyboardType;
  final int maxLines;
  final bool isRequired;
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
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
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
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) {
      return;
    }

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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Saved successfully')));
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not save. Please check again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Form(
        key: _formKey,
        child: ListView.separated(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.md,
            AppSpacing.md,
            96,
          ),
          itemCount: widget.fields.length,
          separatorBuilder: (context, index) =>
              const SizedBox(height: AppSpacing.sm),
          itemBuilder: (context, index) {
            final field = widget.fields[index];
            return AppTextField(
              controller: _controllers[field.name]!,
              label: field.label,
              keyboardType: field.keyboardType,
              maxLines: field.maxLines,
              validator: field.isRequired
                  ? (value) {
                      if (value == null || value.trim().isEmpty) {
                        return '${field.label} is required';
                      }
                      return null;
                    }
                  : null,
            );
          },
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: const BoxDecoration(
            color: AppColors.background,
            border: Border(top: BorderSide(color: AppColors.border)),
          ),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _isSaving ? null : () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: FilledButton.icon(
                  onPressed: _isSaving ? null : _save,
                  icon: _isSaving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.save_outlined),
                  label: const Text('Save'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
