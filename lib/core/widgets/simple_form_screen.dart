import 'package:flutter/material.dart';

import '../constants/app_options.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import 'app_date_field.dart';
import 'app_dropdown_field.dart';
import 'app_readonly_field.dart';
import 'app_text_field.dart';

enum SimpleFormFieldType { text, dropdown, date, readonly }

class FormFieldConfig {
  const FormFieldConfig({
    required this.name,
    required this.label,
    this.keyboardType,
    this.maxLines = 1,
    this.isRequired = true,
    this.type = SimpleFormFieldType.text,
    this.options = const [],
    this.hintText,
  });

  final String name;
  final String label;
  final TextInputType? keyboardType;
  final int maxLines;
  final bool isRequired;
  final SimpleFormFieldType type;
  final List<AppOption<String>> options;
  final String? hintText;
}

class SimpleFormScreen extends StatefulWidget {
  const SimpleFormScreen({
    super.key,
    required this.title,
    required this.fields,
    required this.onSave,
    this.initialValues = const {},
    this.extraContent,
  });

  final String title;
  final List<FormFieldConfig> fields;
  final Map<String, String> initialValues;
  final Future<bool> Function(Map<String, dynamic> data) onSave;
  final Widget? extraContent;

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
    for (final field in widget.fields) {
      if (field.type == SimpleFormFieldType.readonly) {
        continue;
      }
      data[field.name] = _controllers[field.name]?.text.trim() ?? '';
    }

    final success = await widget.onSave(data);

    if (!mounted) {
      return;
    }

    setState(() => _isSaving = false);

    if (success) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Đã lưu thành công')));
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Chưa thể lưu. Vui lòng kiểm tra lại.')),
      );
    }
  }

  FormFieldValidator<String>? _validatorFor(FormFieldConfig field) {
    if (!field.isRequired || field.type == SimpleFormFieldType.readonly) {
      return null;
    }

    return (value) {
      if (value == null || value.trim().isEmpty) {
        final fieldName = field.label.replaceAll('*', '').trim().toLowerCase();
        return 'Vui lòng nhập $fieldName';
      }
      return null;
    };
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
          itemCount:
              widget.fields.length + (widget.extraContent == null ? 0 : 1),
          separatorBuilder: (context, index) =>
              const SizedBox(height: AppSpacing.sm),
          itemBuilder: (context, index) {
            if (index == widget.fields.length) {
              return widget.extraContent!;
            }
            final field = widget.fields[index];
            return _FieldBuilder(
              field: field,
              controller: _controllers[field.name]!,
              validator: _validatorFor(field),
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
                  child: const Text('Hủy'),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: FilledButton(
                  onPressed: _isSaving ? null : _save,
                  child: _isSaving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Lưu'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FieldBuilder extends StatelessWidget {
  const _FieldBuilder({
    required this.field,
    required this.controller,
    required this.validator,
  });

  final FormFieldConfig field;
  final TextEditingController controller;
  final FormFieldValidator<String>? validator;

  @override
  Widget build(BuildContext context) {
    return switch (field.type) {
      SimpleFormFieldType.dropdown => AppDropdownField<String>(
        label: field.label,
        hintText: field.hintText,
        options: field.options,
        value: controller.text.trim().isEmpty ? null : controller.text.trim(),
        validator: validator,
        onChanged: (value) {
          controller.text = value ?? '';
        },
      ),
      SimpleFormFieldType.date => AppDateField(
        controller: controller,
        label: field.label,
        validator: validator,
      ),
      SimpleFormFieldType.readonly => AppReadonlyField(
        label: field.label,
        value: controller.text,
      ),
      SimpleFormFieldType.text => AppTextField(
        controller: controller,
        label: field.label,
        keyboardType: field.keyboardType,
        maxLines: field.maxLines,
        validator: validator,
      ),
    };
  }
}
