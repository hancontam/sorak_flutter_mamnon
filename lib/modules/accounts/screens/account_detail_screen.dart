import 'package:flutter/material.dart';

import '../../../core/widgets/simple_detail_screen.dart';
import '../models/account.dart';

class AccountDetailScreen extends StatelessWidget {
  const AccountDetailScreen({
    super.key,
    required this.account,
  });

  final Account account;

  @override
  Widget build(BuildContext context) {
    return SimpleDetailScreen(
      title: account.fullName,
      rows: [
        DetailRow(label: 'ID', value: '${account.id}'),
        DetailRow(label: 'Email', value: account.email),
        DetailRow(label: 'Role', value: account.role),
        DetailRow(label: 'Phone', value: account.phone),
        DetailRow(label: 'Gender', value: account.gender),
        DetailRow(label: 'Active', value: account.isActive ? 'Yes' : 'No'),
      ],
    );
  }
}
