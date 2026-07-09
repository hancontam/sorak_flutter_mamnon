import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/widgets/module_list_screen.dart';
import '../models/account.dart';
import '../providers/account_provider.dart';
import 'account_detail_screen.dart';
import 'account_form_screen.dart';

class AccountListScreen extends StatefulWidget {
  const AccountListScreen({super.key});

  @override
  State<AccountListScreen> createState() => _AccountListScreenState();
}

class _AccountListScreenState extends State<AccountListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AccountProvider>().loadItems();
    });
  }

  void _openForm([Account? item]) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AccountFormScreen(account: item)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AccountProvider>(
      builder: (context, provider, _) {
        return ModuleListScreen<Account>(
          title: 'Accounts',
          items: provider.items,
          isLoading: provider.isLoading,
          errorMessage: provider.errorMessage,
          onRefresh: provider.loadItems,
          onAdd: () => _openForm(),
          itemTitle: (item) => item.fullName,
          itemSubtitle: (item) => '${item.role} | ${item.email}',
          itemFilterValue: (item) => item.role,
          onEdit: _openForm,
          onDelete: (item) => provider.archiveItem(item.id),
          onDetail: (item) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => AccountDetailScreen(account: item),
              ),
            );
          },
        );
      },
    );
  }
}
