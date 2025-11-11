// lib/features/feedback/feedback_home_tab.dart
import 'package:flutter/material.dart';

class FeedbackHomeTab extends StatelessWidget {
  const FeedbackHomeTab({super.key, this.onBrowseSessions});

  /// Optional: when user taps “Browse sessions”, we can jump to History.
  final VoidCallback? onBrowseSessions;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: [
        const Text(
          'Feedback',
          style: TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1B1E2A).withValues(alpha: .65),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFFFFFFF).withValues(alpha: .08)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'No session selected',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text(
                'Pick a recent session from History to see detailed tips and comparison.',
                style: TextStyle(color: Colors.white.withValues(alpha: .75)),
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: onBrowseSessions, // safe even if null
                  icon: const Icon(Icons.calendar_month_rounded, color: Colors.white),
                  label: const Text('Browse sessions', style: TextStyle(color: Colors.white)),
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.white.withValues(alpha: .10),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _MetricGridSkeleton(),
      ],
    );
  }
}

class _MetricGridSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Widget card(String t) => Container(
      height: 92,
      decoration: BoxDecoration(
        color: const Color(0xFF1B1E2A).withValues(alpha: .55),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFFFFFF).withValues(alpha: .06)),
      ),
      child: Center(
        child: Text(t, style: TextStyle(color: Colors.white.withValues(alpha: .6))),
      ),
    );

    return GridView.count(
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      shrinkWrap: true,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      children: [
        card('Avg Speed'),
        card('Max Speed'),
        card('Sweet-spot %'),
        card('Consistency'),
      ],
    );
  }
}
