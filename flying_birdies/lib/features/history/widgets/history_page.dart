import 'package:flutter/material.dart';
class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});
  @override
  Widget build(BuildContext context) {
    final sessions = List.generate(6, (i) => DateTime.now().subtract(Duration(days: i)));
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: sessions.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, i) => Card(
        child: ListTile(
          title: Text('Session #${i + 1}'),
          subtitle: Text('${sessions[i].toLocal()}'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {},
        ),
      ),
    );
  }
}
