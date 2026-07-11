import 'package:flutter/material.dart';

import 'sorak_status_badge.dart';

class StatusChip extends StatelessWidget {
  const StatusChip({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return SorakStatusBadge(label: label);
  }
}
