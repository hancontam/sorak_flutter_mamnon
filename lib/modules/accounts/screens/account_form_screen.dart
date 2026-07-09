import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/widgets/simple_form_screen.dart';
import '../models/account.dart';
import '../providers/account_provider.dart';

class AccountFormScreen extends StatelessWidget {
  const AccountFormScreen({
    super.key,
    this.account,
  });

  final Account? account;

  @override
  Widget build(BuildContext context) {
    return SimpleFormScreen(
      title: account == null ? 'Create Account' : 'Update Account',
      fields: const [
        FormFieldConfig(name: 'full_name', label: 'Full name'),
        FormFieldConfig(name: 'email', label: 'Email', keyboardType: TextInputType.emailAddress),
        FormFieldConfig(name: 'role', label: 'Role (PRINCIPAL/TEACHER)'),
        FormFieldConfig(name: 'phone', label: 'Phone', keyboardType: TextInputType.phone),
        FormFieldConfig(name: 'gender', label: 'Gender'),
      ],
      initialValues: {
        'full_name': account?.fullName ?? '',
        'email': account?.email ?? '',
        'role': account?.role ?? 'TEACHER',
        'phone': account?.phone ?? '',
        'gender': account?.gender ?? '',
      },
      onSave: (data) {
        final provider = context.read<AccountProvider>();
        if (account == null) {
          data['password'] = '123456';
          return provider.createItem(data);
        }
        return provider.updateItem(account!.id, data);
      },
    );
  }
}
