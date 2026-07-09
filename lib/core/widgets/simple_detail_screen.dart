import 'package:flutter/material.dart';

class DetailRow {
  const DetailRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;
}

class SimpleDetailScreen extends StatelessWidget {
  const SimpleDetailScreen({
    super.key,
    required this.title,
    required this.rows,
  });

  final String title;
  final List<DetailRow> rows;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: rows.length,
        separatorBuilder: (context, index) => const Divider(),
        itemBuilder: (context, index) {
          final row = rows[index];
          return ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(row.label),
            subtitle: Text(row.value.isEmpty ? '-' : row.value),
          );
        },
      ),
    );
  }
}
