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
          // Select Stroke Chip with better visibility
          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color.fromARGB(200, 109, 40, 217),
                  Color.fromARGB(200, 147, 51, 234),
                ],
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 1.5,
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(24),
                onTap: () {
                  // Add your select stroke logic here
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.sports_tennis,
                        color: Colors.white,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Select Stroke',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          
          // Status Chip with dynamic color
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: running
                    ? [
                        const Color.fromARGB(200, 16, 185, 129),
                        const Color.fromARGB(200, 52, 211, 153),
                      ]
                    : [
                        const Color.fromARGB(150, 100, 116, 139),
                        const Color.fromARGB(150, 148, 163, 184),
                      ],
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 1.5,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: running 
                          ? const Color.fromARGB(255, 0, 255, 127)
                          : Colors.white70,
                      shape: BoxShape.circle,
                      boxShadow: running
                          ? [
                              BoxShadow(
                                color: const Color.fromARGB(255, 0, 255, 127),
                                blurRadius: 8,
                                spreadRadius: 2,
                              ),
                            ]
                          : null,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    running ? 'Live' : 'Idle',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ]),
        const SizedBox(height: 16),
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
        const SizedBox(height: 16),
        
        // Enhanced Start/Stop Button
        Container(
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: running
                  ? [
                      const Color.fromARGB(255, 239, 68, 68),
                      const Color.fromARGB(255, 220, 38, 38),
                    ]
                  : [
                      const Color.fromARGB(255, 109, 40, 217),
                      const Color.fromARGB(255, 147, 51, 234),
                    ],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: running
                    ? const Color.fromARGB(100, 239, 68, 68)
                    : const Color.fromARGB(100, 109, 40, 217),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => setState(() => running = !running),
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      running ? Icons.stop_circle : Icons.play_circle,
                      color: Colors.white,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      running ? 'Stop Session' : 'Start Session',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ]),
    );
  }
}