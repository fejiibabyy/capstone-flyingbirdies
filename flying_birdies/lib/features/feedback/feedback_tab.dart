// lib/features/feedback/feedback_tab.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../widgets/glass_widgets.dart';
import '../history/history_tab.dart' show SessionSummary;

/// Comparison choices for the dropdown.
enum BaselineMode { previous, avg7d, avg30d, baseline }

class FeedbackTab extends StatefulWidget {
  const FeedbackTab({
    super.key,
    this.current,
    this.previous,
    this.baseline,
    this.loadLatest,
  });

  final SessionSummary? current;
  final SessionSummary? previous;
  final SessionSummary? baseline;

  /// Optional async loader for "latest session" when opened from bottom nav.
  final Future<SessionSummary?> Function()? loadLatest;

  @override
  State<FeedbackTab> createState() => _FeedbackTabState();
}

class _FeedbackTabState extends State<FeedbackTab> {
  SessionSummary? _current;
  SessionSummary? _previous;
  SessionSummary? _baseline;

  bool _loading = false;
  bool _triedAuto = false;

  BaselineMode _mode = BaselineMode.previous;

  @override
  void initState() {
    super.initState();
    _current = widget.current;
    _previous = widget.previous;
    _baseline = widget.baseline;
    if (_current == null) _autoLoad();
  }

  Future<void> _autoLoad() async {
    if (_triedAuto) return;
    _triedAuto = true;
    setState(() => _loading = true);
    try {
      final loader = widget.loadLatest ?? _mockLatest;
      final latest = await loader();
      if (!mounted) return;
      setState(() {
        _current = latest;
        _previous = widget.previous;
        _baseline = widget.baseline;
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // Mock fetch if backend not wired yet
  Future<SessionSummary?> _mockLatest() async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    final now = DateTime.now();
    return SessionSummary(
      id: 'latest',
      date: DateTime(now.year, now.month, now.day),
      title: 'Evening Drill',
      avgSpeedKmh: 245,
      maxSpeedKmh: 295,
      sweetSpotPct: .60, // TEMP: reused as avg impact force
      consistencyPct: .70, // TEMP: reused as avg acceleration
      hits: 380,
    );
  }

  SessionSummary? _comparisonTarget() {
    final cur = _current;
    if (cur == null) return null;

    switch (_mode) {
      case BaselineMode.previous:
        return _previous;
      case BaselineMode.baseline:
        return _baseline;
      case BaselineMode.avg7d:
        // Mock 7-day avg – swap with real data later.
        return SessionSummary(
          id: 'avg7',
          date: cur.date.subtract(const Duration(days: 7)),
          title: 'Last 7 days',
          avgSpeedKmh: cur.avgSpeedKmh - 2,
          maxSpeedKmh: cur.maxSpeedKmh + 1,
          sweetSpotPct: (cur.sweetSpotPct * 100 - 5) / 100,
          consistencyPct: (cur.consistencyPct * 100 - 5) / 100,
          hits: cur.hits - 12,
        );
      case BaselineMode.avg30d:
        // Mock 30-day avg.
        return SessionSummary(
          id: 'avg30',
          date: cur.date.subtract(const Duration(days: 30)),
          title: 'Last 30 days',
          avgSpeedKmh: cur.avgSpeedKmh - 4,
          maxSpeedKmh: cur.maxSpeedKmh - 2,
          sweetSpotPct: (cur.sweetSpotPct * 100 - 8) / 100,
          consistencyPct: (cur.consistencyPct * 100 - 6) / 100,
          hits: cur.hits - 20,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final has = _current != null;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final primaryText = isDark ? Colors.white : const Color(0xFF111827);
    final secondaryText =
        isDark ? Colors.white.withOpacity(.80) : const Color(0xFF6B7280);

    final cardBg =
        isDark ? Colors.white.withOpacity(.06) : Colors.white.withOpacity(.96);
    final cardBorder =
        isDark ? Colors.white.withOpacity(.10) : const Color(0xFFE5E7EB);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      child: GradientBackground(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            elevation: 0,
            backgroundColor: Colors.transparent,
            systemOverlayStyle:
                isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
            leading: Navigator.canPop(context)
                ? IconButton(
                    icon: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 18,
                      color: primaryText,
                    ),
                    onPressed: () => Navigator.pop(context),
                  )
                : null,
            title: Text(
              'Feedback',
              style: TextStyle(
                color: primaryText,
                fontWeight: FontWeight.w800,
              ),
            ),
            centerTitle: false,
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              if (_loading && !has)
                _LoadingCard(
                  cardBg: cardBg,
                  border: cardBorder,
                  textColor: primaryText,
                  secondary: secondaryText,
                ),
              if (!has && !_loading)
                _EmptyStateCard(
                  cardBg: cardBg,
                  border: cardBorder,
                  textColor: primaryText,
                  secondary: secondaryText,
                ),

              if (has) ...[
                // Coach Summary
                _CoachSummaryCard(
                  cardBg: cardBg,
                  border: cardBorder,
                  primaryText: primaryText,
                  secondaryText: secondaryText,
                  lines: _coachLines(_current!, _comparisonTarget()),
                ),
                const SizedBox(height: 12),

                // Metrics grid – 4 metrics (no sweet-spot/consistency labels)
                _MetricGrid(
                  s: _current!,
                  cardBg: cardBg,
                  border: cardBorder,
                  primaryText: primaryText,
                  secondaryText: secondaryText,
                ),
                const SizedBox(height: 12),

                // Hits
                _HitsCard(
                  hits: _current!.hits,
                  cardBg: cardBg,
                  border: cardBorder,
                  primaryText: primaryText,
                  secondaryText: secondaryText,
                ),
                const SizedBox(height: 20),

                // Comparison + dropdown
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Comparison',
                        style: TextStyle(
                          color: primaryText,
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withOpacity(.08)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isDark
                              ? Colors.white.withOpacity(.16)
                              : const Color(0xFFE5E7EB),
                        ),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<BaselineMode>(
                          value: _mode,
                          dropdownColor:
                              isDark ? const Color(0xFF111827) : Colors.white,
                          iconEnabledColor: isDark
                              ? Colors.white
                              : const Color(0xFF4B5563),
                          style: TextStyle(
                            color: primaryText,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                          onChanged: (m) =>
                              setState(() => _mode = m ?? BaselineMode.previous),
                          items: const [
                            DropdownMenuItem(
                              value: BaselineMode.previous,
                              child: Text('Last session'),
                            ),
                            DropdownMenuItem(
                              value: BaselineMode.avg7d,
                              child: Text('Last 7 days'),
                            ),
                            DropdownMenuItem(
                              value: BaselineMode.avg30d,
                              child: Text('Last 30 days'),
                            ),
                            DropdownMenuItem(
                              value: BaselineMode.baseline,
                              child: Text('Season best'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                _CompareList(
                  deltas: _deltas(_current!, _comparisonTarget()),
                  cardBg: cardBg,
                  border: cardBorder,
                  primaryText: primaryText,
                  secondaryText: secondaryText,
                  isDark: isDark,
                ),
                const SizedBox(height: 16),

                _TipsCard(
                  tips: _tipsFor(_current!),
                  cardBg: cardBg,
                  border: cardBorder,
                  primaryText: primaryText,
                  secondaryText: secondaryText,
                  isDark: isDark,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /* ---------- logic helpers ---------- */

   List<String> _coachLines(SessionSummary cur, SessionSummary? other) {
  // Treat the extra fields as your two physical metrics.
  // (You’re already labelling them as Impact + Acceleration in the UI.)
  final double avg = cur.avgSpeedKmh;
  final double max = cur.maxSpeedKmh;
  final double impact = cur.sweetSpotPct * 100;      // map to N-ish scale
  final double accel = cur.consistencyPct * 100;     // map to m/s²-ish scale
  final int hits = cur.hits;

  final bool hasOther = other != null;

  // Deltas vs comparison target (if any)
  final double dAvg   = hasOther ? avg    - other!.avgSpeedKmh           : 0.0;
  final double dMax   = hasOther ? max    - other!.maxSpeedKmh           : 0.0;
  final double dImp   = hasOther ? impact - other!.sweetSpotPct * 100    : 0.0;
  final double dAccel = hasOther ? accel  - other!.consistencyPct * 100  : 0.0;
  final int    dHits  = hasOther ? hits   - other!.hits                  : 0;

  String headline;

  if (!hasOther) {
    // No comparison session: judge this one on its own.
    if (avg >= 240 && max >= 290 && impact >= 55 && accel >= 55) {
      headline = 'Strong all-round session — fast swings with solid impact.';
    } else if (impact < 45) {
      headline = 'Work on cleaner, stronger contact on the shuttle.';
    } else if (accel < 45) {
      headline = 'Good contact — now focus on quicker acceleration into the shot.';
    } else if (avg < 200 && max < 260) {
      headline =
          'Controlled pace today — next time, try adding a bit more racket speed.';
    } else {
      headline = 'Solid session — you’re building a stable baseline.';
    }
  } else {
    // We *do* have a comparison target.
    final bool speedUp   = dAvg > 3 && dMax > 5;
    final bool impactUp  = dImp > 3;
    final bool accelUp   = dAccel > 3;
    final bool volumeUp  = dHits > 20;

    if (speedUp && impactUp && accelUp) {
      headline =
          'Great work — speed, impact, and acceleration all improved.';
    } else if (speedUp && impactUp) {
      headline = 'Swings are faster with stronger impact — nice progress.';
    } else if (speedUp && !impactUp) {
      headline =
          'Speed is up — keep the same strong contact as you swing faster.';
    } else if (impactUp && !speedUp) {
      headline =
          'Impact is stronger even at similar speed — that’s efficient contact.';
    } else if (accelUp && !speedUp) {
      headline =
          'Acceleration improved — you’re getting into the shot more explosively.';
    } else if (volumeUp) {
      headline = 'Big jump in reps — you got a lot more hits this session.';
    } else {
      headline = 'Very similar to your last session — good consistency overall.';
    }
  }

  String fmt(num v, {int dp = 0}) => v.toStringAsFixed(dp);

  final detail =
      'Avg → ${fmt(avg)} km/h • Max → ${fmt(max)} km/h • '
      'Impact → ${fmt(impact)} N • Accel → ${fmt(accel)} m/s² • '
      'Hits → $hits';

  return [headline, detail];
}


  Map<String, double?> _deltas(SessionSummary cur, SessionSummary? other) {
    if (other == null) {
      return const {
        'Avg Speed': null,
        'Max Speed': null,
        'Impact force': null,
        'Acceleration': null,
      };
    }
    return {
      'Avg Speed': cur.avgSpeedKmh - other.avgSpeedKmh,
      'Max Speed': cur.maxSpeedKmh - other.maxSpeedKmh,
      // Again reusing sweetSpot/consistency as impact/accel for now:
      'Impact force': (cur.sweetSpotPct - other.sweetSpotPct) * 100,
      'Acceleration': (cur.consistencyPct - other.consistencyPct) * 100,
    };
  }

  List<String> _tipsFor(SessionSummary s) {
    final tips = <String>[];

    final avg = s.avgSpeedKmh;
    final impact = s.sweetSpotPct * 100; // TEMP mapping
    final accel = s.consistencyPct * 100; // TEMP mapping

    // Power
    if (avg < 200) {
      tips.add(
          'Build power: focus on using your legs and core, not just your arm, for 3×10 overhead drives.');
    } else if (avg > 260) {
      tips.add(
          'You have great pace — add 2–3 “control only” rallies where you keep the same power but aim deeper into the court.');
    }

    // Impact / contact quality
    if (impact < 50) {
      tips.add(
          'Contact is a bit light: try 10–15 shadow swings focusing on hitting slightly in front of your body.');
    } else if (impact > 75) {
      tips.add(
          'Impact is strong — mix in a few softer touch shots so you can change pace when you need to.');
    }

    // Acceleration / recovery
    if (accel < 50) {
      tips.add(
          'Work on quick recovery: after each hit, do a small hop back to base before the next swing.');
    } else if (accel > 75) {
      tips.add(
          'Acceleration looks good — keep it up with 2×30-sec multi-shuttle drills where you focus on fast first steps.');
    }

    if (tips.isEmpty) {
      tips.add(
          'Nice balanced session — repeat this pattern next time and add one short drill focused on footwork.');
    }

    return tips;
  }
}

/* ---------------- UI bits ---------------- */

class _LoadingCard extends StatelessWidget {
  const _LoadingCard({
    required this.cardBg,
    required this.border,
    required this.textColor,
    required this.secondary,
  });

  final Color cardBg;
  final Color border;
  final Color textColor;
  final Color secondary;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: border),
      ),
      child: Row(
        children: [
          const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          const SizedBox(width: 12),
          Text(
            'Loading latest session…',
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyStateCard extends StatelessWidget {
  const _EmptyStateCard({
    required this.cardBg,
    required this.border,
    required this.textColor,
    required this.secondary,
  });

  final Color cardBg;
  final Color border;
  final Color textColor;
  final Color secondary;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'No session selected',
            style: TextStyle(
              color: textColor,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Pick a recent session from History to see detailed tips and comparison.',
            style: TextStyle(color: secondary),
          ),
        ],
      ),
    );
  }
}

class _CoachSummaryCard extends StatelessWidget {
  const _CoachSummaryCard({
    required this.cardBg,
    required this.border,
    required this.primaryText,
    required this.secondaryText,
    required this.lines,
  });

  final Color cardBg;
  final Color border;
  final Color primaryText;
  final Color secondaryText;
  final List<String> lines;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.workspace_premium_outlined,
                  size: 22, color: primaryText),
              const SizedBox(width: 8),
              Text(
                'Coach Summary',
                style: TextStyle(
                  color: primaryText,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            lines.first,
            style: TextStyle(
              color: primaryText,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            lines.last,
            style: TextStyle(
              color: secondaryText,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricGrid extends StatelessWidget {
  const _MetricGrid({
    required this.s,
    required this.cardBg,
    required this.border,
    required this.primaryText,
    required this.secondaryText,
  });

  final SessionSummary s;
  final Color cardBg;
  final Color border;
  final Color primaryText;
  final Color secondaryText;

  @override
  Widget build(BuildContext context) {
    return GridView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.18,
      ),
      children: [
        _MetricTile(
          title: 'Avg Speed',
          value: s.avgSpeedKmh.toStringAsFixed(0),
          unit: 'km/h',
          cardBg: cardBg,
          border: border,
          primaryText: primaryText,
          secondaryText: secondaryText,
        ),
        _MetricTile(
          title: 'Max Speed',
          value: s.maxSpeedKmh.toStringAsFixed(0),
          unit: 'km/h',
          cardBg: cardBg,
          border: border,
          primaryText: primaryText,
          secondaryText: secondaryText,
        ),
        _MetricTile(
          title: 'Impact force',
          value: (s.sweetSpotPct * 100).toStringAsFixed(0),
          unit: 'N',
          cardBg: cardBg,
          border: border,
          primaryText: primaryText,
          secondaryText: secondaryText,
        ),
        _MetricTile(
          title: 'Acceleration',
          value: (s.consistencyPct * 100).toStringAsFixed(0),
          unit: 'm/s²',
          cardBg: cardBg,
          border: border,
          primaryText: primaryText,
          secondaryText: secondaryText,
        ),
      ],
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({
    required this.title,
    required this.value,
    required this.unit,
    required this.cardBg,
    required this.border,
    required this.primaryText,
    required this.secondaryText,
  });

  final String title;
  final String value;
  final String unit;
  final Color cardBg;
  final Color border;
  final Color primaryText;
  final Color secondaryText;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: secondaryText,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
          const Spacer(),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: TextStyle(
                  color: primaryText,
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                ),
              ),
              if (unit.isNotEmpty) ...[
                const SizedBox(width: 4),
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    unit,
                    style: TextStyle(
                      color: secondaryText,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _HitsCard extends StatelessWidget {
  const _HitsCard({
    required this.hits,
    required this.cardBg,
    required this.border,
    required this.primaryText,
    required this.secondaryText,
  });

  final int hits;
  final Color cardBg;
  final Color border;
  final Color primaryText;
  final Color secondaryText;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hits',
            style: TextStyle(
              color: secondaryText,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$hits',
            style: TextStyle(
              color: primaryText,
              fontSize: 28,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _CompareList extends StatelessWidget {
  const _CompareList({
    required this.deltas,
    required this.cardBg,
    required this.border,
    required this.primaryText,
    required this.secondaryText,
    required this.isDark,
  });

  final Map<String, double?> deltas;
  final Color cardBg;
  final Color border;
  final Color primaryText;
  final Color secondaryText;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: deltas.entries
          .map(
            (e) => _DeltaRow(
              label: e.key,
              delta: e.value,
              cardBg: cardBg,
              border: border,
              primaryText: primaryText,
              secondaryText: secondaryText,
              isDark: isDark,
            ),
          )
          .toList(),
    );
  }
}

class _DeltaRow extends StatelessWidget {
  const _DeltaRow({
    required this.label,
    required this.delta,
    required this.cardBg,
    required this.border,
    required this.primaryText,
    required this.secondaryText,
    required this.isDark,
  });

  final String label;
  final double? delta;
  final Color cardBg;
  final Color border;
  final Color primaryText;
  final Color secondaryText;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final txt = delta == null
        ? '—'
        : (delta! >= 0
            ? '+${delta!.toStringAsFixed(1)}'
            : '-${delta!.abs().toStringAsFixed(1)}');
    final color = delta == null
        ? secondaryText
        : (delta! >= 0
            ? const Color(0xFF16A34A) // green
            : const Color(0xFFDC2626)); // red

    return Container(
      height: 48,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: border),
      ),
      child: Row(
        children: [
          Icon(
            Icons.trending_up,
            size: 18,
            color: secondaryText,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: primaryText,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Text(
            txt,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w900,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}

class _TipsCard extends StatelessWidget {
  const _TipsCard({
    required this.tips,
    required this.cardBg,
    required this.border,
    required this.primaryText,
    required this.secondaryText,
    required this.isDark,
  });

  final List<String> tips;
  final Color cardBg;
  final Color border;
  final Color primaryText;
  final Color secondaryText;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.lightbulb_outline,
                size: 20,
                color: isDark
                    ? const Color(0xFFFBBF24)
                    : const Color(0xFFF59E0B),
              ),
              const SizedBox(width: 8),
              Text(
                'Tips',
                style: TextStyle(
                  color: primaryText,
                  fontWeight: FontWeight.w900,
                  fontSize: 20,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...tips.map(
            (t) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text(
                '• $t',
                style: TextStyle(
                  color: secondaryText,
                  height: 1.35,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
