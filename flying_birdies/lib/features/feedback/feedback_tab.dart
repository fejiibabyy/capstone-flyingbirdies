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

  // NEW: dropdown state
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
        // If you don’t have history yet, leave these null.
        _previous = widget.previous;
        _baseline = widget.baseline;
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // --- Mock fetch used when no backend is wired yet ---
  Future<SessionSummary?> _mockLatest() async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    final now = DateTime.now();
    return SessionSummary(
      id: 'latest',
      date: DateTime(now.year, now.month, now.day),
      title: 'Evening Drill',
      avgSpeedKmh: 245,
      maxSpeedKmh: 295,
      sweetSpotPct: .50,
      consistencyPct: .68,
      hits: 380,
    );
  }

  // Build a comparison target from the chosen mode.
  SessionSummary? _comparisonTarget() {
    final cur = _current;
    if (cur == null) return null;

    switch (_mode) {
      case BaselineMode.previous:
        return _previous;
      case BaselineMode.baseline:
        return _baseline;
      case BaselineMode.avg7d:
        // Mock “averages”; replace with real aggregation later.
        return SessionSummary(
          id: 'avg7',
          date: cur.date.subtract(const Duration(days: 7)),
          title: '7-day average',
          avgSpeedKmh: cur.avgSpeedKmh - 2,
          maxSpeedKmh: cur.maxSpeedKmh + 1,
          sweetSpotPct: (cur.sweetSpotPct * 100 - 1) / 100,
          consistencyPct: (cur.consistencyPct * 100 - 1) / 100,
          hits: cur.hits - 10,
        );
      case BaselineMode.avg30d:
        return SessionSummary(
          id: 'avg30',
          date: cur.date.subtract(const Duration(days: 30)),
          title: '30-day average',
          avgSpeedKmh: cur.avgSpeedKmh - 4,
          maxSpeedKmh: cur.maxSpeedKmh - 2,
          sweetSpotPct: (cur.sweetSpotPct * 100 - 3) / 100,
          consistencyPct: (cur.consistencyPct * 100 - 2) / 100,
          hits: cur.hits - 20,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final has = _current != null;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light, // white status-bar icons
      child: GradientBackground(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          // Make the gradient fill under status bar/AppBar
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            elevation: 0,
            backgroundColor: Colors.transparent,
            title: const Text('Feedback'),
            leading: Navigator.canPop(context) ? const BackButton() : null,
          ),
          body: ListView(
            padding: EdgeInsets.fromLTRB(
              16,
              // keep content below the notch
              MediaQuery.of(context).padding.top + 12,
              16,
              24,
            ),
            children: [
              if (_loading && !has) const _LoadingCard(),
              if (!has && !_loading) const _EmptyStateCard(),

              if (has) ...[
                _CoachSummaryCard(
                  title: 'Coach Summary',
                  lines: _coachLines(_current!, _comparisonTarget()),
                ),
                const SizedBox(height: 14),
                _MetricGrid(s: _current!),
                const SizedBox(height: 12),
                _HitsCard(hits: _current!.hits),
                const SizedBox(height: 18),

                // Header + Dropdown
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Comparison',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(.10),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white.withOpacity(.12)),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<BaselineMode>(
                          value: _mode,
                          dropdownColor: const Color(0xFF1E2040),
                          iconEnabledColor: Colors.white,
                          onChanged: (m) => setState(() => _mode = m!),
                          items: const [
                            DropdownMenuItem(
                              value: BaselineMode.previous,
                              child: Text('Previous', style: TextStyle(color: Colors.white)),
                            ),
                            DropdownMenuItem(
                              value: BaselineMode.avg7d,
                              child: Text('7-day avg', style: TextStyle(color: Colors.white)),
                            ),
                            DropdownMenuItem(
                              value: BaselineMode.avg30d,
                              child: Text('30-day avg', style: TextStyle(color: Colors.white)),
                            ),
                            DropdownMenuItem(
                              value: BaselineMode.baseline,
                              child: Text('Baseline', style: TextStyle(color: Colors.white)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                _CompareList(
                  header: null,
                  deltas: _deltas(_current!, _comparisonTarget()),
                ),
                const SizedBox(height: 16),

                _TipsCard(tips: _tipsFor(_current!)),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /* ---------- helpers ---------- */

  List<String> _coachLines(SessionSummary cur, SessionSummary? other) {
    String arrow(double d) =>
        d > 0 ? '↑ ${d.toStringAsFixed(0)}' : d < 0 ? '↓ ${d.abs().toStringAsFixed(0)}' : '→ 0';

    final dAvg = other == null ? 0.0 : cur.avgSpeedKmh - other.avgSpeedKmh;
    final dSweet = other == null ? 0.0 : (cur.sweetSpotPct - other.sweetSpotPct) * 100;

    return [
      dSweet >= 0
          ? 'Nice! Power and contact improved.'
          : 'Slight dip in contact — we’ll tune drills.',
      'Avg speed ${arrow(dAvg)} km/h • Sweet-spot ${arrow(dSweet)}%',
    ];
  }

  Map<String, double?> _deltas(SessionSummary cur, SessionSummary? other) {
    if (other == null) {
      return {'Avg Speed': null, 'Max Speed': null, 'Sweet-spot': null, 'Consistency': null};
    }
    return {
      'Avg Speed': cur.avgSpeedKmh - other.avgSpeedKmh,
      'Max Speed': cur.maxSpeedKmh - other.maxSpeedKmh,
      'Sweet-spot': (cur.sweetSpotPct - other.sweetSpotPct) * 100,
      'Consistency': (cur.consistencyPct - other.consistencyPct) * 100,
    };
  }

  List<String> _tipsFor(SessionSummary s) => const [
        'Great pace — keep rhythm with 5× 30-sec drive drills.',
        'Aim for cleaner contact: 10 net-control reps focusing on center face.',
      ];
}

/* ---------------- UI bits (unchanged styling) ---------------- */

class _LoadingCard extends StatelessWidget {
  const _LoadingCard();
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(.10)),
      ),
      child: Row(
        children: [
          const SizedBox(
            width: 20, height: 20,
            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Text('Loading latest session…',
              style: TextStyle(color: Colors.white.withOpacity(.95), fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _EmptyStateCard extends StatelessWidget {
  const _EmptyStateCard();
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(.10)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('No session selected',
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          Text(
            'Pick a recent session from History to see detailed tips and comparison.',
            style: TextStyle(color: Colors.white.withOpacity(.85)),
          ),
        ],
      ),
    );
  }
}

class _CoachSummaryCard extends StatelessWidget {
  const _CoachSummaryCard({required this.title, required this.lines});
  final String title;
  final List<String> lines;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(.10)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.workspace_premium_outlined, color: Colors.white, size: 22),
              SizedBox(width: 8),
              Text('Coach Summary',
                  style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900)),
            ],
          ),
          const SizedBox(height: 12),
          Text(lines.first,
              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          Text(lines.last, style: TextStyle(color: Colors.white.withOpacity(.85))),
        ],
      ),
    );
  }
}

class _MetricGrid extends StatelessWidget {
  const _MetricGrid({required this.s});
  final SessionSummary s;

  @override
  Widget build(BuildContext context) {
    return GridView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 1.25),
      children: [
        _MetricTile(title: 'Avg Speed', value: '${s.avgSpeedKmh.toStringAsFixed(0)} km/h'),
        _MetricTile(title: 'Max Speed', value: '${s.maxSpeedKmh.toStringAsFixed(0)} km/h'),
        _MetricTile(title: 'Sweet-spot', value: '${(s.sweetSpotPct * 100).toStringAsFixed(0)}%'),
        _MetricTile(title: 'Consistency', value: '${(s.consistencyPct * 100).toStringAsFixed(0)}%'),
      ],
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({required this.title, required this.value});
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(.10)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: TextStyle(color: Colors.white.withOpacity(.90), fontWeight: FontWeight.w800)),
          const Spacer(),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }
}

class _HitsCard extends StatelessWidget {
  const _HitsCard({required this.hits});
  final int hits;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(.10)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Hits', style: TextStyle(color: Colors.white.withOpacity(.90), fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          Text('$hits', style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }
}

class _CompareList extends StatelessWidget {
  const _CompareList({required this.header, required this.deltas});
  final String? header; // not used when the dropdown header is shown
  final Map<String, double?> deltas;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (header != null)
          Text(header!, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900)),
        if (header != null) const SizedBox(height: 10),
        ...deltas.entries.map((e) => _DeltaRow(label: e.key, delta: e.value)),
      ],
    );
  }
}

class _DeltaRow extends StatelessWidget {
  const _DeltaRow({required this.label, required this.delta});
  final String label;
  final double? delta;

  @override
  Widget build(BuildContext context) {
    final txt = delta == null ? '—' : (delta! >= 0 ? '+${delta!.toStringAsFixed(1)}' : '-${delta!.abs().toStringAsFixed(1)}');
    final color = delta == null
        ? Colors.white.withOpacity(.85)
        : (delta! >= 0 ? const Color(0xFF6EE7A8) : const Color(0xFFFCA5A5));

    return Container(
      height: 48,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(.10)),
      ),
      child: Row(
        children: [
          const Icon(Icons.trending_up, color: Colors.white70, size: 18),
          const SizedBox(width: 10),
          Expanded(child: Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700))),
          Text(txt, style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 16)),
        ],
      ),
    );
  }
}

class _TipsCard extends StatelessWidget {
  const _TipsCard({required this.tips});
  final List<String> tips;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(.10)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.lightbulb_outline, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Text('Tips', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 20)),
            ],
          ),
          const SizedBox(height: 10),
          ...tips.map((t) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text('• $t', style: TextStyle(color: Colors.white.withOpacity(.90))),
              )),
        ],
      ),
    );
  }
}
