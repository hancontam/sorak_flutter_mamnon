import 'package:flutter/material.dart';

import '../../../core/utils/ui_labels.dart';
import '../../../core/widgets/simple_detail_screen.dart';
import '../models/account.dart';

class AccountDetailScreen extends StatelessWidget {
  const AccountDetailScreen({super.key, required this.account});

  final Account account;

  @override
  Widget build(BuildContext context) {
    return SimpleDetailScreen(
      title: account.fullName,
      rows: [
        DetailRow(label: 'ID', value: '${account.id}'),
        DetailRow(label: 'Email', value: account.email),
        DetailRow(label: 'Vai trò', value: UiLabels.role(account.role)),
        DetailRow(label: 'Số điện thoại', value: account.phone),
        DetailRow(label: 'Giới tính', value: UiLabels.gender(account.gender)),
        DetailRow(
          label: 'Trạng thái',
          value: account.isActive ? 'Đang hoạt động' : 'Đã khóa',
        ),
      ],
    );
  }
}
