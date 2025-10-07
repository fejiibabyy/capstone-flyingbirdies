import 'package:flutter/material.dart';

class MetricCard extends StatelessWidget {
  final String label, value;
  final Widget? trailing;
  const MetricCard({super.key, required this.label, required this.value, this.trailing});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text(label, style: t.titleMedium),
          const SizedBox(height: 8),
          Text(value, style: t.headlineSmall),
          if (trailing != null) ...[const SizedBox(height: 8), trailing!],
        ]),
      ),
    );
  }
}
