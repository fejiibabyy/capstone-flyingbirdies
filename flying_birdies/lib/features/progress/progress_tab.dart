import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Theme-aware progress / calendar tab
class ProgressTab extends StatefulWidget {
  const ProgressTab({super.key});
  @override
  State<ProgressTab> createState() => _ProgressTabState();
}

class _ProgressTabState extends State<ProgressTab> {
  late DateTime _today;
  late DateTime _month; // first day of shown month
  int? _selectedDay; // single selected day (1..31)

  final Set<int> _activeDays = {2, 5, 7, 9, 13, 18, 19, 23, 24, 30};

  @override
  void initState() {
    super.initState();
    _today = DateTime.now();
    _month = DateTime(_today.year, _today.month);
    _selectedDay = _today.day;
  }

  int get _sessions => _activeDays.length;
  int get _activeDaysCount => _activeDays.length;
  int get _totalHits => 1260;

  int get _currentStreak {
    final isThisMonth =
        _month.year == _today.year && _month.month == _today.month;
    int streak = 0;
    int d = isThisMonth ? _today.day : _daysInMonth(_month);
    while (d >= 1 && _activeDays.contains(d)) {
      streak++;
      d--;
    }
    return streak;
  }

  int get _bestStreak {
    int best = 0, run = 0;
    for (int d = 1; d <= _daysInMonth(_month); d++) {
      if (_activeDays.contains(d)) {
        run++;
        best = math.max(best, run);
      } else {
        run = 0;
      }
    }
    return best;
  }

  int get _thisWeekCount {
    final start = _today.subtract(Duration(days: _today.weekday % 7));
    final end = start.add(const Duration(days: 6));
    if (start.month != _month.month || start.year != _month.year) return 0;
    int c = 0;
    for (int d = start.day; d <= end.day; d++) {
      if (_activeDays.contains(d)) c++;
    }
    return c;
  }

  Map<String, String> _daySummary() {
    final d = _selectedDay ?? _today.day;
    final seed = d * 37;
    final speed = 160 + (seed % 60);
    final force = 40 + (seed % 70);
    final accel = 5 + (seed % 50);
    final power = (force * 0.9 + accel).round();
    final sweet = 45 + (seed % 55);
    return {
      'speed': '$speed km/h',
      'force': '$force N',
      'accel': '$accel m/s²',
      'power': '$power',
      'sweet': '$sweet%',
    };
  }

  int _daysInMonth(DateTime m) => DateTime(m.year, m.month + 1, 0).day;
  int _firstWeekdayOffset(DateTime m) =>
      DateTime(m.year, m.month, 1).weekday % 7;
  String _monthName(DateTime d) {
    const names = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return names[d.month - 1];
  }

  void _prevMonth() => setState(() {
        _month = DateTime(_month.year, _month.month - 1);
        _selectedDay = 1;
      });
  void _nextMonth() => setState(() {
        _month = DateTime(_month.year, _month.month + 1);
        _selectedDay = 1;
      });

  Future<void> _pickMonthYear() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(_month.year, _month.month, 15),
      firstDate: DateTime(_today.year - 5),
      lastDate: DateTime(_today.year + 5),
      helpText: 'Pick month & year',
      initialEntryMode: DatePickerEntryMode.calendarOnly,
    );
    if (picked != null) {
      setState(() {
        _month = DateTime(picked.year, picked.month);
        _selectedDay = 1;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor =
        isDark ? Colors.white : const Color(0xFF111827);
    final secondary =
        isDark ? Colors.white.withValues(alpha: .80) : const Color(0xFF4B5563);

    final day = _selectedDay;
    final summary = _daySummary();

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
      children: [
        Center(
          child: Text(
            'Progress & Records',
            style: TextStyle(
              color: titleColor,
              fontWeight: FontWeight.w800,
              fontSize: 26,
            ),
          ),
        ),
        const SizedBox(height: 12),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _RoundIcon(onTap: _prevMonth),
            const SizedBox(width: 10),
            InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: _pickMonthYear,
              child: _MonthChip(text: '${_monthName(_month)} ${_month.year}'),
            ),
            const SizedBox(width: 10),
            _RoundIcon(onTap: _nextMonth),
          ],
        ),

        const SizedBox(height: 18),
        Row(
          children: [
            Expanded(
              child: _MiniStatV(
                icon: Icons.timer_outlined,
                title: 'Sessions',
                value: '$_sessions',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _MiniStatV(
                icon: Icons.local_fire_department_outlined,
                title: 'Active days',
                value: '$_activeDaysCount',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _MiniStatV(
                icon: Icons.sports_tennis,
                title: 'Total hits',
                value: '$_totalHits',
              ),
            ),
          ],
        ),

        const SizedBox(height: 18),
        _GlassCard(
          child: Column(
            children: [
              const SizedBox(height: 6),
              const _WeekHeader(),
              const SizedBox(height: 10),
              _MonthGridSingleSelect(
                month: _month,
                today: _today,
                selectedDay: _selectedDay,
                activeDays: _activeDays,
                onSelect: (d) => setState(() => _selectedDay = d),
              ),
              const SizedBox(height: 6),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  day == null
                      ? 'No day selected'
                      : 'Selected: ${_monthName(_month)} $day, ${_month.year}',
                  style: TextStyle(
                    color: secondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 18),
        _GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Day Summary',
                style: TextStyle(
                  color: titleColor,
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 12),
              _DayRow(
                label: 'Swing Speed',
                value: summary['speed']!,
                icon: Icons.flash_on_rounded,
              ),
              const SizedBox(height: 10),
              _DayRow(
                label: 'Impact Force',
                value: summary['force']!,
                icon: Icons.adjust_rounded,
              ),
              const SizedBox(height: 10),
              _DayRow(
                label: 'Acceleration',
                value: summary['accel']!,
                icon: Icons.trending_up_rounded,
              ),
              const SizedBox(height: 12),
              _Meter(label: 'Power Index', percent: _clampPct(int.parse(summary['power']!) / 120.0)),
              const SizedBox(height: 10),
              _Meter(
                label: 'Sweet-Spot %',
                percent: _clampPct(
                  int.parse(summary['sweet']!.replaceAll('%', '')) / 100.0,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 18),
        _StatCard(
          title: 'Current Streak',
          value: '$_currentStreak',
          suffix: 'days',
          icon: Icons.local_fire_department_rounded,
          accent: const Color(0xFFF59E0B),
          caption:
              _currentStreak > 0 ? 'Keep it going!' : 'Start today to begin a streak',
        ),
        const SizedBox(height: 12),
        _StatCard(
          title: 'Best Streak',
          value: '$_bestStreak',
          suffix: 'days',
          icon: Icons.emoji_events_rounded,
          accent: const Color(0xFFFB7185),
          caption: 'Personal record',
        ),
        const SizedBox(height: 12),
        _StatCard(
          title: 'This Week',
          value: '$_thisWeekCount',
          suffix: ' / 7 days',
          icon: Icons.event_rounded,
          accent: const Color(0xFF60A5FA),
          caption: '$_sessions sessions',
        ),

        const SizedBox(height: 80),
      ],
    );
  }
}

/* ─────────── helpers & widgets ─────────── */

double _clampPct(double x) => x.clamp(0.0, 1.0);

class _MonthChip extends StatelessWidget {
  const _MonthChip({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark
        ? Colors.white.withValues(alpha: .08)
        : const Color(0xFFF3F4FF);
    final border = isDark
        ? Colors.white.withValues(alpha: .10)
        : const Color(0xFFE5E7EB);
    final textColor =
        isDark ? Colors.white : const Color(0xFF111827);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.calendar_today_rounded,
            size: 14,
            color: isDark ? Colors.white70 : const Color(0xFF6B7280),
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniStatV extends StatelessWidget {
  const _MiniStatV(
      {required this.icon, required this.title, required this.value});
  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg =
        isDark ? Colors.white.withValues(alpha: .05) : Colors.white;
    final border = isDark
        ? Colors.white.withValues(alpha: .10)
        : const Color(0x14000000);
    final iconBg =
        isDark ? Colors.white.withValues(alpha: .10) : const Color(0xFFF3F4FF);
    final iconColor =
        isDark ? Colors.white70 : const Color(0xFF4B5563);
    final titleColor =
        isDark ? Colors.white70 : const Color(0xFF6B7280);
    final valueColor =
        isDark ? Colors.white : const Color(0xFF111827);

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: bg,
        border: Border.all(color: border),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withValues(alpha: .04),
              blurRadius: 14,
              offset: const Offset(0, 10),
            ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: titleColor,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              color: valueColor,
              fontWeight: FontWeight.w800,
              fontSize: 22,
            ),
          ),
        ],
      ),
    );
  }
}

class _RoundIcon extends StatelessWidget {
  const _RoundIcon({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg =
        isDark ? Colors.white.withValues(alpha: .08) : Colors.white;
    final border = isDark
        ? Colors.white.withValues(alpha: .10)
        : const Color(0xFFE5E7EB);
    final iconColor =
        isDark ? Colors.white70 : const Color(0xFF4B5563);

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: border),
        ),
        child: Icon(
          Icons.chevron_left,
          color: iconColor,
          size: 20,
        ),
      ),
    );
  }
}

class _GlassCard extends StatelessWidget {
  const _GlassCard({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg =
        isDark ? Colors.white.withValues(alpha: .04) : Colors.white;
    final border = isDark
        ? Colors.white.withValues(alpha: .10)
        : const Color(0x14000000);

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: bg,
        border: Border.all(color: border),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withValues(alpha: .04),
              blurRadius: 16,
              offset: const Offset(0, 10),
            ),
        ],
      ),
      child: child,
    );
  }
}

class _WeekHeader extends StatelessWidget {
  const _WeekHeader();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color =
        isDark ? Colors.white.withValues(alpha: .75) : const Color(0xFF6B7280);
    const days = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: days
          .map(
            (d) => Expanded(
              child: Center(
                child: Text(
                  d,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

class _MonthGridSingleSelect extends StatelessWidget {
  const _MonthGridSingleSelect({
    required this.month,
    required this.today,
    required this.selectedDay,
    required this.activeDays,
    required this.onSelect,
  });

  final DateTime month;
  final DateTime today;
  final int? selectedDay;
  final Set<int> activeDays;
  final void Function(int day) onSelect;

  int _daysInMonth(DateTime m) => DateTime(m.year, m.month + 1, 0).day;
  int _firstWeekdayOffset(DateTime m) =>
      DateTime(m.year, m.month, 1).weekday % 7;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final days = _daysInMonth(month);
    final startOffset = _firstWeekdayOffset(month);
    final cells = startOffset + days;
    final rows = (cells / 7).ceil();
    final isThisMonth =
        month.year == today.year && month.month == today.month;

    final activeBg = isDark
        ? const Color(0xFF7C3AED).withValues(alpha: .18)
        : const Color(0xFFE0E7FF);
    final selectedGradient = const LinearGradient(
      colors: [Color(0xFF8B5CF6), Color(0xFF6366F1)],
    );

    return Column(
      children: List.generate(rows, (r) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: List.generate(7, (c) {
              final i = r * 7 + c;
              final dayNum = i - startOffset + 1;
              final inMonth = dayNum >= 1 && dayNum <= days;
              final isSelected = inMonth && (selectedDay == dayNum);
              final isActive = inMonth && activeDays.contains(dayNum);
              final isToday =
                  inMonth && isThisMonth && (dayNum == today.day);

              return Expanded(
                child: AspectRatio(
                  aspectRatio: 1.2,
                  child: Center(
                    child: inMonth
                        ? InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () => onSelect(dayNum),
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                gradient: isSelected ? selectedGradient : null,
                                color: isSelected
                                    ? null
                                    : (isActive ? activeBg : Colors.transparent),
                                border: Border.all(
                                  color: isSelected
                                      ? Colors.white.withValues(alpha: .40)
                                      : isToday
                                          ? Colors.white.withValues(alpha: .35)
                                          : Colors.white.withValues(alpha: .10),
                                ),
                                boxShadow: isSelected
                                    ? [
                                        BoxShadow(
                                          color: const Color(0xFF7C3AED)
                                              .withValues(alpha: .35),
                                          blurRadius: 10,
                                        )
                                      ]
                                    : null,
                              ),
                              child: Center(
                                child: Text(
                                  '$dayNum',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: isSelected
                                        ? FontWeight.w800
                                        : (isActive
                                            ? FontWeight.w700
                                            : FontWeight.w600),
                                  ),
                                ),
                              ),
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),
                ),
              );
            }),
          ),
        );
      }),
    );
  }
}

class _DayRow extends StatelessWidget {
  const _DayRow(
      {required this.label, required this.value, required this.icon});
  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final labelColor =
        isDark ? Colors.white70 : const Color(0xFF4B5563);
    final valueColor =
        isDark ? Colors.white : const Color(0xFF111827);
    final iconBg =
        isDark ? Colors.white.withValues(alpha: .10) : const Color(0xFFE5E7EB);
    final iconColor =
        isDark ? Colors.white70 : const Color(0xFF4B5563);

    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: iconBg,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: iconColor, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: labelColor,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: valueColor,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _Meter extends StatelessWidget {
  const _Meter({required this.label, required this.percent});
  final String label;
  final double percent;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final labelColor =
        isDark ? Colors.white70 : const Color(0xFF4B5563);
    final trackColor =
        isDark ? Colors.white.withValues(alpha: .08) : const Color(0xFFE5E7EB);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: labelColor,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: SizedBox(
            height: 8,
            child: Stack(
              children: [
                Container(color: trackColor),
                FractionallySizedBox(
                  widthFactor: percent,
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFFFF6FD8), Color(0xFF7E4AED)],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.title,
    required this.value,
    required this.suffix,
    required this.icon,
    required this.accent,
    this.caption,
  });

  final String title, value, suffix;
  final IconData icon;
  final Color accent;
  final String? caption;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor =
        isDark ? Colors.white : const Color(0xFF111827);
    final captionColor =
        isDark ? Colors.white.withValues(alpha: .75) : const Color(0xFF4B5563);
    final bg =
        isDark ? Colors.white.withValues(alpha: .04) : Colors.white;
    final border = isDark
        ? Colors.white.withValues(alpha: .10)
        : const Color(0x14000000);

    return _GlassCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(
                title,
                style: TextStyle(
                  color: titleColor,
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    value,
                    style: TextStyle(
                      color: titleColor,
                      fontWeight: FontWeight.w800,
                      fontSize: 28,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      suffix,
                      style: TextStyle(
                        color: captionColor,
                      ),
                    ),
                  ),
                ],
              ),
              if (caption != null) ...[
                const SizedBox(height: 6),
                Text(
                  caption!,
                  style: TextStyle(color: captionColor),
                ),
              ],
            ]),
          ),
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: .20),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: accent.withValues(alpha: .45)),
            ),
            child: Icon(icon, color: Colors.white, size: 18),
          ),
        ],
      ),
    ).copyWithDecoration(bg, border);
  }
}

extension on _GlassCard {
  _GlassCard copyWithDecoration(Color bg, Color border) {
    return _GlassCard(child: child);
  }
}
