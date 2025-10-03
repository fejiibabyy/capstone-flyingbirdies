import 'dart:async';
import 'package:flutter/material.dart';

import 'package:flying_birdies/models/metrics.dart';
import 'package:flying_birdies/services/mock_metrics.dart';
import 'package:flying_birdies/widgets/metric_card.dart';


class LivePage extends StatefulWidget {
  const LivePage({super.key});
  @override State<LivePage> createState() => _LivePageState();
}

class _LivePageState extends State<LivePage> {
  bool running = false;
  Metrics latest = Metrics.zero();
  late final StreamSubscription sub;

  @override
  void initState() {
    super.initState();
    sub = MockMetricsService.instance.stream.listen((m) {
      if (!running) return;
      setState(() => latest = m);
    });
  }

  @override
  void dispose() {
    sub.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(children: [
        Row(children: [
          const Chip(label: Text('Select Stroke')),
          const SizedBox(width: 8),
          Chip(
            avatar: Icon(running ? Icons.circle : Icons.circle_outlined,
                size: 16, color: running ? Colors.greenAccent : Colors.white70),
            label: Text(running ? 'Live' : 'Idle'),
          ),
        ]),
        const SizedBox(height: 12),
        Expanded(
          child: GridView.count(
            crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12,
            children: [
              MetricCard(label: 'Impact Force', value: '${latest.forceN.toStringAsFixed(1)} N'),
              MetricCard(label: 'Racket Speed', value: '${latest.speedMs.toStringAsFixed(2)} m/s'),
              MetricCard(label: 'Acceleration', value: '${latest.accelMs2.toStringAsFixed(1)} m/s²'),
              MetricCard(label: 'Session', value: running ? 'Live' : 'Idle'),
            ],
          ),
        ),
        const SizedBox(height: 12),
        FilledButton.tonalIcon(
          onPressed: () => setState(() => running = !running),
          icon: Icon(running ? Icons.stop : Icons.play_arrow),
          label: Text(running ? 'Stop Session' : 'Start Session'),
        ),
      ]),
    );
  }
}
