// lib/features/train/train_tab.dart
import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../../app/theme.dart';

class TrainTab extends StatefulWidget {
  const TrainTab({super.key, this.deviceName});
  final String? deviceName; // if null -> focus cards disabled

  @override
  State<TrainTab> createState() => _TrainTabState();
}

class _TrainTabState extends State<TrainTab> {
  // Exactly 4 strokes
  final _strokes = const [
    _StrokeMeta(
      key: 'oh-fh',
      title: 'Overhead Forehand',
      subtitle: 'Power overhead attack shot',
      speedRange: 'Speed: 180–220 km/h',
      forceRange: 'Force: 80–110 N',
      icon: Icons.arrow_circle_down_rounded,
    ),
    _StrokeMeta(
      key: 'oh-bh',
      title: 'Overhead Backhand',
      subtitle: 'High defensive clear/backcourt',
      speedRange: 'Speed: 140–170 km/h',
      forceRange: 'Force: 50–75 N',
      icon: Icons.arrow_circle_up_rounded,
    ),
    _StrokeMeta(
      key: 'ua-fh',
      title: 'Underarm Forehand',
      subtitle: 'Soft finesse to front court',
      speedRange: 'Speed: 80–105 km/h',
      forceRange: 'Force: 25–40 N',
      icon: Icons.sports_tennis,
    ),
    _StrokeMeta(
      key: 'ua-bh',
      title: 'Underarm Backhand',
      subtitle: 'Fast horizontal drive',
      speedRange: 'Speed: 120–145 km/h',
      forceRange: 'Force: 40–60 N',
      icon: Icons.bolt_rounded,
    ),
  ];

  String? _selectedKey; // null = no focus
  bool get _isConnected => widget.deviceName != null;

  // Live metrics (mock stream for now; swap with BLE updates later)
  Timer? _ticker;
  int _t = 0;
  double swingSpeed = 0;   // km/h
  double impactForce = 0;  // N
  double acceleration = 0; // m/s²
  double swingForce = 0;   // pseudo unit

  @override
  void initState() {
    super.initState();
    _startMockLoop();
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  void _startMockLoop() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(milliseconds: 350), (_) {
      _t++;
      final rnd = math.Random();
      swingSpeed = (190 + 70 * math.sin(_t / 4) + rnd.nextDouble() * 14).clamp(0, 320);
      impactForce = (95 + 35 * math.cos(_t / 5) + rnd.nextDouble() * 10).clamp(20, 180);
      acceleration = (28 + 18 * math.sin(_t / 6) + rnd.nextDouble() * 5).clamp(5, 60);
      swingForce = (60 + 30 * math.cos(_t / 7) + rnd.nextDouble() * 8).clamp(10, 120);
      setState(() {});
    });
  }

  double get _powerIndex {
    final v = (swingSpeed / 320).clamp(0, 1);
    final f = (impactForce / 180).clamp(0, 1);
    return (100 * (0.65 * v + 0.35 * f)).clamp(0, 100);
  }

  double get _sweetSpotPct {
    final base = 76 + 9 * math.sin(_t / 8);
    return base.clamp(0, 100);
  }

  @override
  Widget build(BuildContext context) {
    final disabledMsg = !_isConnected ? 'Connect your sensor to select a practice focus' : null;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: [
        // ── Overflow-safe header (two lines + ellipsis) ───────────────────────
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.podcasts_rounded, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Practice Focus',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 20),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF59E0B).withOpacity(.20),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFF59E0B).withOpacity(.35)),
                  ),
                  child: const Text('Optional',
                      style: TextStyle(color: Color(0xFFF59E0B), fontWeight: FontWeight.w800)),
                ),
              ],
            ),
            const SizedBox(height: 6),
            if (_isConnected)
              Row(
                children: [
                  const Icon(Icons.bluetooth_connected, color: Color(0xFF16A34A), size: 16),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      widget.deviceName!,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          'Select a stroke to focus your practice session (optional)',
          style: TextStyle(color: Colors.white.withOpacity(.85), height: 1.35),
        ),
        const SizedBox(height: 12),

        // Focus cards
        ..._strokes.map((m) {
          final selected = _selectedKey == m.key;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _FocusCard(
              meta: m,
              selected: selected,
              disabled: !_isConnected,
              onTap: () => setState(() => _selectedKey = selected ? null : m.key),
            ),
          );
        }),

        if (disabledMsg != null) ...[
          const SizedBox(height: 6),
          _DisabledBanner(text: disabledMsg),
        ],

        const SizedBox(height: 18),
        const _SectionHeader('Live Sensor Readings'),

        _MetricCard(
          title: 'Swing Speed',
          unit: 'km/h',
          value: swingSpeed,
          badge: swingSpeed < 130
              ? _Badge('Beginner', const Color(0xFFFB7185))
              : swingSpeed < 180
                  ? _Badge('Intermediate', const Color(0xFFF59E0B))
                  : _Badge('Advanced', const Color(0xFF34D399)),
          trailingIcon: Icons.bolt_rounded,
        ),
        const SizedBox(height: 12),

        _MetricCard(
          title: 'Impact Force',
          unit: 'N',
          value: impactForce,
          badge: impactForce < 60
              ? _Badge('Gentle', const Color(0xFF34D399))
              : impactForce < 90
                  ? _Badge('Solid', const Color(0xFFF59E0B))
                  : _Badge('Heavy', const Color(0xFFFB7185)),
          trailingIcon: Icons.fiber_smart_record_rounded,
        ),
        const SizedBox(height: 12),

        _MetricCard(
          title: 'Acceleration',
          unit: 'm/s²',
          value: acceleration,
          trailingIcon: Icons.trending_up_rounded,
          showBar: true,
          barMax: 60,
        ),
        const SizedBox(height: 12),

        _MetricCard(
          title: 'Swing Force',
          unit: 'au',
          value: swingForce,
          trailingIcon: Icons.change_circle_rounded,
          showBar: true,
          barMax: 120,
        ),

        const SizedBox(height: 18),

        // ── Performance Analysis header + two metric-style glass cards ────────
        const _SectionHeader('Performance Analysis'),
        const SizedBox(height: 12),

        _MetricCard(
          title: 'Power Index',
          unit: '', // no unit
          value: _powerIndex,
          trailingIcon: Icons.insights,
          showBar: true,
          barMax: 100,
        ),
        const SizedBox(height: 12),

        _MetricCard(
          title: 'Sweet-Spot %',
          unit: '%',
          value: _sweetSpotPct,
          trailingIcon: Icons.center_focus_strong_rounded,
          showBar: true,
          barMax: 100,
        ),

        const SizedBox(height: 18),

        // ── Training Tips in its OWN glass card ───────────────────────────────
        _GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _SectionHeader('Training Tips'),
              const SizedBox(height: 8),
              ..._tipsForFocus(_selectedKey).map((t) => _TipRow(text: t)),
            ],
          ),
        ),

        const SizedBox(height: 80),
      ],
    );
  }

  List<String> _tipsForFocus(String? key) {
    switch (key) {
      case 'oh-fh':
        return const [
          'Keep elbow high; wrist snap at impact.',
          'Strike in front of shoulder for max leverage.',
          'Use core rotation, not just arm speed.',
        ];
      case 'oh-bh':
        return const [
          'Turn shoulder quickly; contact high and early.',
          'Grip relax → tighten at impact for control.',
        ];
      case 'ua-fh':
        return const [
          'Soft hands; brush the shuttle for tight net shots.',
          'Stay low; recover to center ready position.',
        ];
      case 'ua-bh':
        return const [
          'Short backswing; use forearm rotation.',
          'Keep racket up; prepare for fast exchanges.',
        ];
      default:
        return const [
          'Warm up your wrist & shoulder mobility.',
          'Focus on smooth acceleration into contact.',
        ];
    }
  }
}

// ───────────────────────── UI bits ─────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.text);
  final String text;
  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: Colors.white, fontWeight: FontWeight.w800, fontSize: 18),
    );
  }
}

class _GlassCard extends StatelessWidget {
  const _GlassCard({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: Colors.white.withOpacity(.04),
        border: Border.all(color: Colors.white.withOpacity(.10)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.22),
            blurRadius: 18,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _FocusCard extends StatelessWidget {
  const _FocusCard({
    required this.meta,
    required this.selected,
    required this.disabled,
    required this.onTap,
  });

  final _StrokeMeta meta;
  final bool selected;
  final bool disabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final base = Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: Colors.white.withOpacity(.04),
        border: Border.all(
          color: (selected ? Colors.white.withOpacity(.28) : Colors.white.withOpacity(.10)),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.22),
            blurRadius: 18,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Opacity(
        opacity: disabled ? .55 : 1,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(meta.icon, color: Colors.white70, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(meta.title,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            )),
                      ),
                      const SizedBox(width: 8),
                      if (selected)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF7C3AED),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: const Text(
                            'Selected',
                            style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.w800, fontSize: 12),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    meta.subtitle,
                    style: TextStyle(color: Colors.white.withOpacity(.85)),
                  ),
                  const SizedBox(height: 10),
                  Text(meta.speedRange,
                      style: TextStyle(color: Colors.white.withOpacity(.70), fontSize: 13)),
                  Text(meta.forceRange,
                      style: TextStyle(color: Colors.white.withOpacity(.70), fontSize: 13)),
                ],
              ),
            ),
          ],
        ),
      ),
    );

    if (disabled) return base;
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: base,
    );
  }
}

class _DisabledBanner extends StatelessWidget {
  const _DisabledBanner({required this.text});
  final String text;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: const Color(0xFFF59E0B).withOpacity(.14),
        border: Border.all(color: const Color(0xFFF59E0B).withOpacity(.35)),
      ),
      child: Text(
        text,
        style: const TextStyle(color: Color(0xFFF59E0B), fontWeight: FontWeight.w800),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.title,
    required this.unit,
    required this.value,
    this.badge,
    this.trailingIcon,
    this.showBar = false,
    this.barMax = 100,
  });

  final String title;
  final String unit;
  final double value;
  final _Badge? badge;
  final IconData? trailingIcon;
  final bool showBar;
  final double barMax;

  @override
  Widget build(BuildContext context) {
    final vStr = value.isFinite ? value.toStringAsFixed(value < 10 ? 1 : 0) : '0';
    final double pct = (value / barMax).clamp(0.0, 1.0).toDouble();

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: Colors.white.withOpacity(.04),
        border: Border.all(color: Colors.white.withOpacity(.10)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.22),
            blurRadius: 18,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(title,
                  style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16)),
              const Spacer(),
              if (trailingIcon != null)
                Container(
                  width: 34, height: 34,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(.06),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Icon(trailingIcon, color: Colors.white70, size: 18),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                vStr,
                style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.w800, fontSize: 32),
              ),
              const SizedBox(width: 6),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(unit,
                    style: TextStyle(color: Colors.white.withOpacity(.85), fontSize: 14)),
              ),
              const Spacer(),
              if (badge != null) _BadgeChip(badge: badge!),
            ],
          ),
          if (showBar) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: Stack(
                children: [
                  Container(height: 10, color: Colors.white.withOpacity(.08)),
                  FractionallySizedBox(
                    widthFactor: pct,
                    child: Container(
                      height: 10,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(colors: AppTheme.gCTA),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _TipRow extends StatelessWidget {
  const _TipRow({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle, size: 16, color: Colors.white70),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(color: Colors.white.withOpacity(.92), height: 1.35),
            ),
          ),
        ],
      ),
    );
  }
}

class _Badge {
  final String text;
  final Color color;
  const _Badge(this.text, this.color);
}

class _BadgeChip extends StatelessWidget {
  const _BadgeChip({required this.badge});
  final _Badge badge;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: badge.color.withOpacity(.18),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: badge.color.withOpacity(.35)),
      ),
      child: Text(
        badge.text,
        style: TextStyle(color: badge.color, fontWeight: FontWeight.w800, fontSize: 12),
      ),
    );
  }
}

class _StrokeMeta {
  final String key;
  final String title;
  final String subtitle;
  final String speedRange;
  final String forceRange;
  final IconData icon;
  const _StrokeMeta({
    required this.key,
    required this.title,
    required this.subtitle,
    required this.speedRange,
    required this.forceRange,
    required this.icon,
  });
}
