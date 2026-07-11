import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/sorak_toggle_group.dart';
import '../../class_transfers/screens/class_transfer_list_screen.dart';
import '../../incoming_transfers/screens/incoming_transfer_list_screen.dart';
import '../../outgoing_transfers/screens/outgoing_transfer_list_screen.dart';

enum TransferSection { classTransfer, outgoing, incoming }

class TransfersScreen extends StatefulWidget {
  const TransfersScreen({super.key});

  @override
  State<TransfersScreen> createState() => _TransfersScreenState();
}

class _TransfersScreenState extends State<TransfersScreen> {
  TransferSection _selectedSection = TransferSection.classTransfer;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.md,
            AppSpacing.md,
            AppSpacing.sm,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Quản lý chuyển trường',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: AppSpacing.sm),
              SorakToggleGroup<TransferSection>(
                options: const [
                  SorakToggleOption<TransferSection>(
                    value: TransferSection.classTransfer,
                    icon: LucideIcons.arrowRightLeft,
                    label: 'Chuyển lớp',
                  ),
                  SorakToggleOption<TransferSection>(
                    value: TransferSection.outgoing,
                    icon: LucideIcons.logOut,
                    label: 'Chuyển đi',
                  ),
                  SorakToggleOption<TransferSection>(
                    value: TransferSection.incoming,
                    icon: LucideIcons.logIn,
                    label: 'Chuyển đến',
                  ),
                ],
                selected: _selectedSection,
                onChanged: (section) => setState(() {
                  _selectedSection = section;
                }),
              ),
            ],
          ),
        ),
        Expanded(child: _buildSelectedList()),
      ],
    );
  }

  Widget _buildSelectedList() {
    switch (_selectedSection) {
      case TransferSection.classTransfer:
        return const ClassTransferListScreen();
      case TransferSection.outgoing:
        return const OutgoingTransferListScreen();
      case TransferSection.incoming:
        return const IncomingTransferListScreen();
    }
  }
}
