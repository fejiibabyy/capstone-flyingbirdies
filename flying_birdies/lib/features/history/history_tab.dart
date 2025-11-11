import 'package:flutter/material.dart';
import '../feedback/feedback_tab.dart';

class HistoryTab extends StatefulWidget {
  const HistoryTab({super.key});
  @override
  State<HistoryTab> createState() => _HistoryTabState();
}

class _HistoryTabState extends State<HistoryTab> {
  DateTime _focusedMonth = DateTime(DateTime.now().year, DateTime.now().month, 1);
  DateTime _selectedDay  = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final sessions = _mockSessionsForDay(_selectedDay);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: [
        const SizedBox(height: 8),
        const Text('History',
            style: TextStyle(color: Colors.white, fontSize: 34, fontWeight: FontWeight.w900)),
        const SizedBox(height: 16),

        _StatRow(items: const [
          _TopStat(label: 'Sessions', value: '16'),
          _TopStat(label: 'Active days', value: '16'),
          _TopStat(label: 'Total hits', value: '6800'),
        ]),
        const SizedBox(height: 18),

        _MonthCard(
          focusedMonth: _focusedMonth,
          selectedDay: _selectedDay,
          onPrev: () => setState(() {
            _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1, 1);
          }),
          onNext: () => setState(() {
            _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1, 1);
          }),
          onPickDay: (d) => setState(() => _selectedDay = d),
        ),
        const SizedBox(height: 18),

        const Text('Day Summary',
            style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900)),
        const SizedBox(height: 12),

        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: sessions.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, i) {
            final s = sessions[i];
            final previous = i > 0 ? sessions[i - 1] : null;
            final baseline = sessions.first;

            return InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => FeedbackTab(
                      current: s,
                      previous: previous,
                      baseline: baseline,
                      // remove the bad `historyLoader:` argument
                    ),
                  ),
                );
              },
              child: _SessionTile(session: s),
            );
          },
        ),
      ],
    );
  }
}

/* ───────────── UI bits ───────────── */

class _StatRow extends StatelessWidget {
  const _StatRow({required this.items});
  final List<_TopStat> items;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: items
          .map((e) => Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 6),
                  padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(.06),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withOpacity(.10)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(e.label,
                          style: TextStyle(
                              color: Colors.white.withOpacity(.85),
                              fontWeight: FontWeight.w700)),
                      const SizedBox(height: 8),
                      Text(e.value,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 26, fontWeight: FontWeight.w900)),
                    ],
                  ),
                ),
              ))
          .toList(),
    );
  }
}

class _TopStat {
  final String label;
  final String value;
  const _TopStat({required this.label, required this.value});
}

class _MonthCard extends StatelessWidget {
  const _MonthCard({
    required this.focusedMonth,
    required this.selectedDay,
    required this.onPrev,
    required this.onNext,
    required this.onPickDay,
  });

  final DateTime focusedMonth;
  final DateTime selectedDay;
  final VoidCallback onPrev;
  final VoidCallback onNext;
  final ValueChanged<DateTime> onPickDay;

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  @override
  Widget build(BuildContext context) {
    final first = DateTime(focusedMonth.year, focusedMonth.month, 1);
    final daysInMonth = DateTime(focusedMonth.year, focusedMonth.month + 1, 0).day;
    final startWeekday = first.weekday; // 1=Mon … 7=Sun
    final leading = (startWeekday % 7); // Sun-start grid

    final totalCells = leading + daysInMonth;

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.06),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(.10)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              _RoundIcon(onTap: onPrev, icon: Icons.chevron_left),
              const Spacer(),
              Text(
                '${_monthName(focusedMonth.month)} ${focusedMonth.year}',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18),
              ),
              const Spacer(),
              _RoundIcon(onTap: onNext, icon: Icons.chevron_right),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [_Wd('S'), _Wd('M'), _Wd('T'), _Wd('W'), _Wd('T'), _Wd('F'), _Wd('S')],
          ),
          const SizedBox(height: 8),

          GridView.builder(
            shrinkWrap: true,
            itemCount: totalCells,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7, mainAxisSpacing: 8, crossAxisSpacing: 8, childAspectRatio: 1.2),
            itemBuilder: (_, i) {
              if (i < leading) return const SizedBox.shrink();
              final day = i - leading + 1;
              final date = DateTime(focusedMonth.year, focusedMonth.month, day);
              final isSel = _isSameDay(selectedDay, date);

              return InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => onPickDay(date),
                child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isSel ? const Color(0xFF6B8BFF) : Colors.white.withOpacity(.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSel ? Colors.white.withOpacity(.30) : Colors.white.withOpacity(.10),
                    ),
                  ),
                  child: Text(
                    '$day',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: isSel ? FontWeight.w900 : FontWeight.w700,
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Selected: ${selectedDay.year}-${_pad(selectedDay.month)}-${_pad(selectedDay.day)}',
              style: TextStyle(color: Colors.white.withOpacity(.65)),
            ),
          ),
        ],
      ),
    );
  }

  String _monthName(int m) {
    const names = [
      'January','February','March','April','May','June',
      'July','August','September','October','November','December'
    ];
    return names[m - 1];
  }

  String _pad(int n) => n < 10 ? '0$n' : '$n';
}

class _Wd extends StatelessWidget {
  const _Wd(this.t);
  final String t;
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Center(
        child: Text(t,
            style: TextStyle(color: Colors.white.withOpacity(.7), fontWeight: FontWeight.w700)),
      ),
    );
  }
}

class _RoundIcon extends StatelessWidget {
  const _RoundIcon({required this.onTap, required this.icon});
  final VoidCallback onTap;
  final IconData icon;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      customBorder: const CircleBorder(),
      onTap: onTap,
      child: Container(
        width: 36, height: 36,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(.10),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: Colors.white),
      ),
    );
  }
}

class _SessionTile extends StatelessWidget {
  const _SessionTile({required this.session});
  final SessionSummary session;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white.withOpacity(.06),
        border: Border.all(color: Colors.white.withOpacity(.10)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(.10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.query_stats_rounded, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Session • ${session.title}',
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16)),
                const SizedBox(height: 6),
                Text(
                  'Max ${session.maxSpeedKmh.toStringAsFixed(0)} km/h • '
                  'Sweet Spot ${(session.sweetSpotPct * 100).toStringAsFixed(0)}%',
                  style: TextStyle(color: Colors.white.withOpacity(.80), fontSize: 13),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: Colors.white70),
        ],
      ),
    );
  }
}

/* ───────── Simple model + mock ───────── */

class SessionSummary {
  final String id;
  final DateTime date;
  final String title;
  final double avgSpeedKmh;
  final double maxSpeedKmh;
  final double sweetSpotPct;   // 0–1
  final double consistencyPct; // 0–1
  final int hits;

  SessionSummary({
    required this.id,
    required this.date,
    required this.title,
    required this.avgSpeedKmh,
    required this.maxSpeedKmh,
    required this.sweetSpotPct,
    required this.consistencyPct,
    required this.hits,
  });
}

List<SessionSummary> _mockSessionsForDay(DateTime day) {
  final d = DateTime(day.year, day.month, day.day);
  return [
    SessionSummary(
      id: 's1', date: d, title: 'Evening Drill',
      avgSpeedKmh: 245, maxSpeedKmh: 302,
      sweetSpotPct: .58, consistencyPct: .72, hits: 420,
    ),
    SessionSummary(
      id: 's2', date: d, title: 'Singles',
      avgSpeedKmh: 251, maxSpeedKmh: 310,
      sweetSpotPct: .61, consistencyPct: .75, hits: 465,
    ),
  ];
}
