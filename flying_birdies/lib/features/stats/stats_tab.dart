// lib/features/stats/stats_tab.dart
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class StatsTab extends StatefulWidget {
  const StatsTab({super.key});
  @override
  State<StatsTab> createState() => _StatsTabState();
}

enum TimeRange { daily, weekly, monthly, yearly, all }

class _StatsTabState extends State<StatsTab> {
  TimeRange _range = TimeRange.daily;
  String _stroke = 'Overhead Forehand';

  final _strokes = const <String>[
    'All Strokes',
    'Overhead Forehand',
    'Overhead Backhand',
    'Underarm Forehand',
    'Underarm Backhand',
  ];

  // ----------------- MOCK DATA (replace with real series) -----------------
  List<double> _seriesFor(TimeRange r, String stroke, int seed) {
    final rand = math.Random(seed + r.index + stroke.hashCode);
    final len = switch (r) {
      TimeRange.daily => 24,   // hourly
      TimeRange.weekly => 7,   // days
      TimeRange.monthly => 30, // days
      TimeRange.yearly => 12,  // months
      TimeRange.all => 36,     // months (3y)
    };
    double v = rand.nextDouble() * 0.6 + 0.2;
    return List.generate(len, (_) {
      v += (rand.nextDouble() - .5) * 0.16;
      v = v.clamp(.06, 1.0);
      return v;
    });
  }

  List<String> _labelsForRange(TimeRange r) {
    final now = DateTime.now();
    switch (r) {
      case TimeRange.daily:
        return List.generate(24, (h) => '${h.toString().padLeft(2, '0')}:00');
      case TimeRange.weekly:
        final start = now.subtract(const Duration(days: 6));
        final f = DateFormat('E d'); // Mon 03
        return List.generate(7, (i) => f.format(start.add(Duration(days: i))));
      case TimeRange.monthly:
        final start = now.subtract(const Duration(days: 29));
        final f = DateFormat('MMM d'); // Nov 02
        return List.generate(30, (i) => f.format(start.add(Duration(days: i))));
      case TimeRange.yearly:
        final f = DateFormat('MMM');
        return List.generate(12, (i) => f.format(DateTime(now.year, now.month - 11 + i)));
      case TimeRange.all:
        final f = DateFormat('MMM yy');
        return List.generate(36, (i) => f.format(DateTime(now.year, now.month - 35 + i)));
    }
  }

  Map<String, num> _stats(List<double> s, {required num base, required num span}) {
    final mx = s.reduce(math.max);
    final avg = s.reduce((a, b) => a + b) / s.length;
    return {'max': base + mx * span, 'avg': base + avg * span};
  }

  @override
  Widget build(BuildContext context) {
    final pad = const EdgeInsets.fromLTRB(16, 16, 16, 24);

    final spd = _seriesFor(_range, _stroke, 1);
    final frc = _seriesFor(_range, _stroke, 2);
    final acc = _seriesFor(_range, _stroke, 3);
    final sfo = _seriesFor(_range, _stroke, 4);

    final labels = _labelsForRange(_range);

    // value ranges to scale 0..1 → real units
    const speedMin = 80.0, speedMax = 240.0;
    const forceMin = 20.0, forceMax = 120.0;
    const accelMin = 5.0, accelMax = 45.0;
    const sforceMin = 10.0, sforceMax = 80.0;

    final spdStats = _stats(spd, base: speedMin, span: speedMax - speedMin);
    final frcStats = _stats(frc, base: forceMin, span: forceMax - forceMin);
    final accStats = _stats(acc, base: accelMin, span: accelMax - accelMin);
    final sfoStats = _stats(sfo, base: sforceMin, span: sforceMax - sforceMin);

    return ListView(
      padding: pad,
      children: [
        const Text(
          'Performance Analysis',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 28),
        ),
        const SizedBox(height: 12),

        // Time range pills
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _pill('Daily', TimeRange.daily),
              _pill('Weekly', TimeRange.weekly),
              _pill('Monthly', TimeRange.monthly),
              _pill('Yearly', TimeRange.yearly),
              _pill('All', TimeRange.all),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Stroke dropdown
        Align(
          alignment: Alignment.centerLeft,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withOpacity(.10)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _stroke,
                dropdownColor: const Color(0xFF151A29),
                borderRadius: BorderRadius.circular(14),
                iconEnabledColor: Colors.white70,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                items: _strokes
                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                    .toList(),
                onChanged: (v) => setState(() => _stroke = v ?? _stroke),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),

        _MetricCard(
          heroTag: 'metric-speed',
          title: 'Swing Speed',
          unit: 'km/h',
          icon: Icons.flash_on_rounded,
          maxValue: spdStats['max']!.round(),
          avgValue: spdStats['avg']!.round(),
          series: spd,
          onOpen: () => _openChart(
            title: 'Swing Speed',
            unit: 'km/h',
            series: spd,
            color: const Color(0xFFFF7AE0),
            minValue: speedMin,
            maxValue: speedMax,
            labels: labels,
          ),
        ),
        const SizedBox(height: 12),
        _MetricCard(
          heroTag: 'metric-force',
          title: 'Impact Force',
          unit: 'N',
          icon: Icons.adjust_rounded,
          maxValue: frcStats['max']!.round(),
          avgValue: frcStats['avg']!.round(),
          series: frc,
          onOpen: () => _openChart(
            title: 'Impact Force',
            unit: 'N',
            series: frc,
            color: const Color(0xFFFFB86B),
            minValue: forceMin,
            maxValue: forceMax,
            labels: labels,
          ),
        ),
        const SizedBox(height: 12),
        _MetricCard(
          heroTag: 'metric-accel',
          title: 'Acceleration',
          unit: 'm/s²',
          icon: Icons.trending_up_rounded,
          maxValue: accStats['max']!.round(),
          avgValue: accStats['avg']!.round(),
          series: acc,
          onOpen: () => _openChart(
            title: 'Acceleration',
            unit: 'm/s²',
            series: acc,
            color: const Color(0xFF9AE6B4),
            minValue: accelMin,
            maxValue: accelMax,
            labels: labels,
          ),
        ),
        const SizedBox(height: 12),
        _MetricCard(
          heroTag: 'metric-swingforce',
          title: 'Swing Force',
          unit: 'au',
          icon: Icons.refresh_rounded,
          maxValue: sfoStats['max']!.round(),
          avgValue: sfoStats['avg']!.round(),
          series: sfo,
          onOpen: () => _openChart(
            title: 'Swing Force',
            unit: 'au',
            series: sfo,
            color: const Color(0xFFA5B4FC),
            minValue: sforceMin,
            maxValue: sforceMax,
            labels: labels,
          ),
        ),

        const SizedBox(height: 80),
      ],
    );
  }

  Widget _pill(String label, TimeRange r) {
    final selected = _range == r;
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => setState(() => _range = r),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: selected ? const Color(0xFF7C3AED) : Colors.white.withOpacity(.14),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: selected ? Colors.white.withOpacity(.25) : Colors.white.withOpacity(.16),
              ),
              boxShadow: selected
                  ? [BoxShadow(color: Colors.black.withOpacity(.22), blurRadius: 10, offset: const Offset(0, 6))]
                  : null,
            ),
            child: Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(.95),
                fontWeight: FontWeight.w800,
                fontSize: 14,
                letterSpacing: .1,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _openChart({
    required String title,
    required String unit,
    required List<double> series,
    required Color color,
    required double minValue,
    required double maxValue,
    required List<String> labels,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _EnlargedChartSheet(
        title: title,
        unit: unit,
        series: series,
        color: color,
        minValue: minValue,
        maxValue: maxValue,
        labels: labels,
      ),
    );
  }
}

// ───────────────── Metric Card ─────────────────

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.heroTag,
    required this.title,
    required this.unit,
    required this.icon,
    required this.maxValue,
    required this.avgValue,
    required this.series,
    required this.onOpen,
  });

  final String heroTag;
  final String title;
  final String unit;
  final IconData icon;
  final int maxValue;
  final num avgValue;
  final List<double> series;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onOpen,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: Colors.white.withOpacity(.05),
          border: Border.all(color: Colors.white.withOpacity(.10)),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(.20), blurRadius: 16, offset: const Offset(0, 12)),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(.10),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.show_chart, size: 18, color: Colors.white70),
                    ),
                    const SizedBox(width: 10),
                    Text(title,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 18)),
                  ]),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _Kpi(label: 'Max', value: '$maxValue $unit'),
                      const SizedBox(width: 18),
                      _Kpi(label: 'Avg', value: '${avgValue.toStringAsFixed(0)} $unit'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Hero(
              tag: heroTag,
              child: SizedBox(width: 118, height: 78, child: _Sparkline(series: series)),
            ),
          ],
        ),
      ),
    );
  }
}

class _Kpi extends StatelessWidget {
  const _Kpi({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.white.withOpacity(.75), fontWeight: FontWeight.w700)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 18)),
      ],
    );
  }
}

// ─────────── Enlarged Chart Sheet (scene-aware touch + snap) ───────────

class _EnlargedChartSheet extends StatefulWidget {
  const _EnlargedChartSheet({
    required this.title,
    required this.unit,
    required this.series,
    required this.color,
    required this.minValue,
    required this.maxValue,
    required this.labels,
  });

  final String title;
  final String unit;
  final List<double> series; // normalized 0..1
  final Color color;
  final double minValue;
  final double maxValue;
  final List<String> labels;

  @override
  State<_EnlargedChartSheet> createState() => _EnlargedChartSheetState();
}

class _EnlargedChartSheetState extends State<_EnlargedChartSheet> {
  // Pointer state in SCENE coordinates (not screen):
  Offset? _cursor; // snapped to data x, y at data value (for crosshair & tooltip)
  int? _idx;
  double? _value;

  static const double _canvasWidth = 1200;
  static const double _canvasHeight = 320;

  // NEW: transformation controller so we can convert touch → scene
  final TransformationController _tc = TransformationController();

  // Map a local (widget) point into the chart scene, snap to nearest index
  void _updatePointer(Offset local) {
    final n = widget.series.length;
    if (n <= 1) return;

    // Convert to scene (accounts for pan/zoom)
    final scene = _tc.toScene(local);

    final dx = _canvasWidth / (n - 1);
    final x = scene.dx.clamp(0.0, _canvasWidth);
    final i = (x / dx).round().clamp(0, n - 1);

    // snap x to index center
    final snappedX = i * dx;

    // compute y from the data value so the dot sits exactly on the line
    final norm = widget.series[i].clamp(0.0, 1.0);
    final yOnLine = _canvasHeight * (1 - norm);

    // scale to real units for tooltip
    final val = widget.minValue + norm * (widget.maxValue - widget.minValue);

    setState(() {
      _cursor = Offset(snappedX, yOnLine); // SCENE coordinates
      _idx = i;
      _value = val;
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget _tooltip() {
      if (_cursor == null || _idx == null || _value == null) return const SizedBox.shrink();
      // Position tooltip near the dot in SCENE space
      final left = (_cursor!.dx - 80).clamp(8.0, _canvasWidth - 160.0);
      final top  = (_cursor!.dy - 60).clamp(8.0, _canvasHeight - 54.0);
      final label = (_idx! >= 0 && _idx! < widget.labels.length)
          ? widget.labels[_idx!]
          : 'Point ${_idx! + 1}';
      return Positioned(
        left: left,
        top: top,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF0F1525).withOpacity(.92),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.white.withOpacity(.12)),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(.35), blurRadius: 12)],
          ),
          child: DefaultTextStyle(
            style: const TextStyle(color: Colors.white, fontSize: 13),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text('${_value!.toStringAsFixed(1)} ${widget.unit}',
                    style: const TextStyle(fontWeight: FontWeight.w800)),
              ],
            ),
          ),
        ),
      );
    }

    // GestureDetector wraps the whole viewer; we convert its local to scene via _tc
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF151A29).withOpacity(.97),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
        border: Border.all(color: Colors.white.withOpacity(.08)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            Container(
              height: 5, width: 50,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(.25),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                children: [
                  Expanded(
                    child: Text(widget.title,
                        style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded, color: Colors.white),
                  )
                ],
              ),
            ),
            SizedBox(
              height: _canvasHeight,
              child: GestureDetector(
                onTapDown: (d) => _updatePointer(d.localPosition),
                onPanStart: (d) => _updatePointer(d.localPosition),
                onPanUpdate: (d) => _updatePointer(d.localPosition),
                onPanEnd: (_) => setState(() { _cursor = null; _idx = null; _value = null; }),
                onTapUp:  (_) => setState(() { _cursor = null; _idx = null; _value = null; }),
                child: InteractiveViewer(
                 transformationController: _tc,            // ← important
                  minScale: 1,
                  maxScale: 6,
                  child: Stack(
                    children: [
                      SizedBox(
                        width: _canvasWidth,
                        height: _canvasHeight,
                        child: CustomPaint(
                          painter: _BigSparklinePainter(
                            series: widget.series,
                            color: widget.color,
                            cursor: _cursor, // SCENE coords
                          ),
                        ),
                      ),
                      _tooltip(), // also in SCENE coords since it’s inside the transformed Stack
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

// Small sparkline used on metric cards
class _Sparkline extends StatelessWidget {
  const _Sparkline({required this.series});
  final List<double> series;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _SparklinePainter(series: series));
  }
}

class _SparklinePainter extends CustomPainter {
  _SparklinePainter({required this.series});
  final List<double> series;

  @override
  void paint(Canvas canvas, Size size) {
    if (series.isEmpty) return;
    final n = series.length;
    final dx = size.width / (n - 1);
    double yAt(int i) => size.height * (1 - series[i]);

    final path = Path()..moveTo(0, yAt(0));
    for (int i = 1; i < n; i++) path.lineTo(dx * i, yAt(i));

    final line = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..shader = const LinearGradient(
        colors: [Color(0xFFFF6FD8), Color(0xFF7E4AED)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawPath(path, line);
  }

  @override
  bool shouldRepaint(covariant _SparklinePainter oldDelegate) => oldDelegate.series != series;
}

// Big sparkline in the modal
class _BigSparklinePainter extends CustomPainter {
  _BigSparklinePainter({
    required this.series,
    required this.color,
    required this.cursor,
  });

  final List<double> series; // 0..1
  final Color color;
  final Offset? cursor; // SCENE coords (snapped to index)

  @override
  void paint(Canvas canvas, Size size) {
    if (series.isEmpty) return;
    final n = series.length;
    final dx = size.width / (n - 1);
    double yAt(int i) => size.height * (1 - series[i]);

    // grid lines
    final grid = Paint()..color = Colors.white.withOpacity(.08)..strokeWidth = 1;
    for (int i = 1; i < 5; i++) {
      final y = size.height * i / 5;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }

    // line + soft area fill
    final path = Path()..moveTo(0, yAt(0));
    for (int i = 1; i < n; i++) path.lineTo(dx * i, yAt(i));

    final fill = Paint()
      ..style = PaintingStyle.fill
      ..shader = const LinearGradient(
        colors: [Color(0x22FF6FD8), Color(0x227E4AED)],
      ).createShader(Offset.zero & size);
    final fillPath = Path.from(path)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(fillPath, fill);

    final line = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..color = color.withOpacity(.9);
    canvas.drawPath(path, line);

    // crosshair + dot (x,y already snapped in scene space)
    if (cursor != null) {
      final x = cursor!.dx.clamp(0.0, size.width);
      final idx = (x / dx).round().clamp(0, n - 1);
      final y = yAt(idx);
      final cross = Paint()..color = Colors.white54..strokeWidth = 1;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), cross);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), cross);
      final dot = Paint()..color = color;
      canvas.drawCircle(Offset(dx * idx, y), 5, dot);
    }
  }

  @override
  bool shouldRepaint(covariant _BigSparklinePainter oldDelegate) =>
      oldDelegate.series != series || oldDelegate.cursor != cursor;
}
