// lib/features/live/widgets/live_page.dart
import 'package:flutter/material.dart';
import 'package:flying_birdies/widgets/glass_widgets.dart';

class LivePage extends StatelessWidget {
  const LivePage({super.key});

  final TextStyle _tileText =
      const TextStyle(fontSize: 13, color: Colors.white70);
  final TextStyle _tileValue = const TextStyle(
      fontSize: 22, fontWeight: FontWeight.w700, color: Colors.white);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          // Smart Racket Sensor card
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: GlassCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: const [
                    Icon(Icons.bluetooth, size: 24, color: Colors.white),
                    SizedBox(width: 10),
                    Text(
                      'Smart Racket Sensor',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ]),
                  const SizedBox(height: 10),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      StatusDot(color: Color(0xFFFF6B6B)),
                      SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          'No Device Found · Make sure your sensor is on',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          softWrap: true,
                          style: TextStyle(color: Colors.white70),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const AppBadge(
                          text: 'DISCONNECTED', color: Color(0xFF422A66)),
                      const Spacer(),
                      Flexible(
                        child: FilledButton.tonal(
                          style: ButtonStyle(
                            padding: WidgetStateProperty.all(
                              const EdgeInsets.symmetric(
                                  vertical: 14, horizontal: 18),
                            ),
                            backgroundColor: WidgetStateProperty.all(
                                const Color(0xFF7E4AED)),
                            foregroundColor:
                                WidgetStateProperty.all(Colors.white),
                            shape: WidgetStateProperty.all(
                              RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(24)),
                            ),
                          ),
                          onPressed: () {},
                          child: const Text('Connect'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Beginner-friendly metrics
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.2,
            children: [
              MetricTile(
                  title: 'Session Time',
                  value: '00:00',
                  valueStyle: _tileValue,
                  titleStyle: _tileText),
              MetricTile(
                  title: 'Stroke Count',
                  value: '0',
                  valueStyle: _tileValue,
                  titleStyle: _tileText),
              MetricTile(
                  title: 'Solid Contact %',
                  value: '0%',
                  valueStyle: _tileValue,
                  titleStyle: _tileText),
              MetricTile(
                  title: 'Consistency',
                  value: '—',
                  valueStyle: _tileValue,
                  titleStyle: _tileText),
            ],
          ),

          const SizedBox(height: 16),

          // Practice Focus
          GlassCard(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    Icon(Icons.track_changes_outlined, color: Colors.white),
                    SizedBox(width: 8),
                    Text('Practice Focus',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.white)),
                    SizedBox(width: 8),
                    AppBadge(text: 'Optional', color: Color(0xFF2B2D4A)),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Select a stroke to focus your practice session (optional)',
                  style: TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 8),
                buildFocusTile('Smash', 'Powerful overhead attack shot'),
                buildFocusTile('Drop Shot', 'Soft shot just over the net'),
                buildFocusTile('Clear', 'Deep defensive shot to baseline'),
              ],
            ),
          ),

          const SizedBox(height: 18),

          // Start session
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              style: ButtonStyle(
                padding: WidgetStateProperty.all(
                    const EdgeInsets.symmetric(vertical: 16)),
                backgroundColor:
                    WidgetStateProperty.all(const Color(0xFF7E4AED)),
                foregroundColor: WidgetStateProperty.all(Colors.white),
                shape: WidgetStateProperty.all(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
              onPressed: () {},
              child: const Text('Start Session',
                  style:
                      TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────────

class MetricTile extends StatelessWidget {
  const MetricTile({
    super.key,
    required this.title,
    required this.value,
    required this.valueStyle,
    required this.titleStyle,
  });

  final String title;
  final String value;
  final TextStyle valueStyle;
  final TextStyle titleStyle;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: titleStyle),
          const Spacer(),
          Text(value, style: valueStyle),
        ],
      ),
    );
  }
}

Widget buildFocusTile(String title, String subtitle) {
  return Padding(
    padding: const EdgeInsets.only(top: 8),
    child: GlassCard(
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        leading: const Icon(Icons.sports_tennis, color: Colors.white),
        title: Text(title,
            style:
                const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle,
            style: const TextStyle(color: Colors.white70)),
        trailing: const Icon(Icons.chevron_right, color: Colors.white),
      ),
    ),
  );
}
