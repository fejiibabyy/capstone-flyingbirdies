import 'package:intl/intl.dart';
import 'chart_data_point.dart';

/// Time range options for Stats tab
enum TimeRange { daily, weekly, monthly, yearly, all }

/// Chart data processor for Stats tab
///
/// Converts individual swing data into chart data points for visualization.
/// Each point represents one swing (not time-bucketed aggregates).
class StatsTabChartData {
  /// All swings in the selected time range
  final List<dynamic> swings;

  /// Metric key to display ('speed', 'force', 'accel', 'sforce')
  final String metricKey;

  /// Selected time range
  final TimeRange range;

  /// Total shots
  final int totalShots;

  const StatsTabChartData({
    required this.swings,
    required this.metricKey,
    required this.range,
    required this.totalShots,
  });

  /// Get data points for the selected metric
  ///
  /// Returns time-aggregated points based on the selected range:
  /// - Daily: Individual swings
  /// - Weekly: 7 days (one point per day)
  /// - Monthly: 30 days (one point per day)
  /// - Yearly: 12 months (one point per month)
  /// - All: Monthly buckets
  List<ChartDataPoint> getDataPoints(String metricKey) {
    if (swings.isEmpty) return [];

    return switch (range) {
      TimeRange.daily => _getDailyPoints(metricKey),
      TimeRange.weekly => _getWeeklyPoints(metricKey),
      TimeRange.monthly => _getMonthlyPoints(metricKey),
      TimeRange.yearly => _getYearlyPoints(metricKey),
      TimeRange.all => _getAllTimePoints(metricKey),
    };
  }

  /// Daily: Individual swings (unchanged)
  List<ChartDataPoint> _getDailyPoints(String metricKey) {
    return swings.asMap().entries.map((e) {
      final index = e.key;
      final swing = e.value;

      final value = _extractMetricValue(swing, metricKey);
      final label = 'Swing ${index + 1}';

      return ChartDataPoint(
        x: index.toDouble(),
        y: value,
        label: label,
        shotCount: 1,
        timestamp: swing.timestamp,
      );
    }).toList();
  }

  /// Weekly: Last 7 days (one point per day)
  List<ChartDataPoint> _getWeeklyPoints(String metricKey) {
    final now = DateTime.now();
    final startDate = DateTime(now.year, now.month, now.day)
        .subtract(const Duration(days: 6));

    // Group swings by day
    final dayBuckets = <int, List<dynamic>>{};
    for (final swing in swings) {
      final swingDate = swing.timestamp as DateTime;
      final daysSinceStart = DateTime(
        swingDate.year,
        swingDate.month,
        swingDate.day,
      ).difference(startDate).inDays;

      if (daysSinceStart >= 0 && daysSinceStart < 7) {
        dayBuckets.putIfAbsent(daysSinceStart, () => []).add(swing);
      }
    }

    // Create data points for each day
    final points = <ChartDataPoint>[];
    for (int i = 0; i < 7; i++) {
      final date = startDate.add(Duration(days: i));
      final daySwings = dayBuckets[i] ?? [];

      if (daySwings.isEmpty) {
        // No data for this day - show 0
        points.add(ChartDataPoint(
          x: i.toDouble(),
          y: 0,
          label: DateFormat('EEE M/d').format(date),
          shotCount: 0,
          timestamp: date,
        ));
      } else {
        // Calculate average for this day
        final values =
            daySwings.map((s) => _extractMetricValue(s, metricKey)).toList();
        final avg = values.reduce((a, b) => a + b) / values.length;

        points.add(ChartDataPoint(
          x: i.toDouble(),
          y: avg,
          label: DateFormat('EEE M/d').format(date),
          shotCount: daySwings.length,
          timestamp: date,
        ));
      }
    }

    return points;
  }

  /// Monthly: Last 30 days (one point per day)
  List<ChartDataPoint> _getMonthlyPoints(String metricKey) {
    final now = DateTime.now();
    final startDate = DateTime(now.year, now.month, now.day)
        .subtract(const Duration(days: 29));

    // Group swings by day
    final dayBuckets = <int, List<dynamic>>{};
    for (final swing in swings) {
      final swingDate = swing.timestamp as DateTime;
      final daysSinceStart = DateTime(
        swingDate.year,
        swingDate.month,
        swingDate.day,
      ).difference(startDate).inDays;

      if (daysSinceStart >= 0 && daysSinceStart < 30) {
        dayBuckets.putIfAbsent(daysSinceStart, () => []).add(swing);
      }
    }

    // Create data points for each day
    final points = <ChartDataPoint>[];
    for (int i = 0; i < 30; i++) {
      final date = startDate.add(Duration(days: i));
      final daySwings = dayBuckets[i] ?? [];

      if (daySwings.isEmpty) {
        points.add(ChartDataPoint(
          x: i.toDouble(),
          y: 0,
          label: DateFormat('M/d').format(date),
          shotCount: 0,
          timestamp: date,
        ));
      } else {
        final values =
            daySwings.map((s) => _extractMetricValue(s, metricKey)).toList();
        final avg = values.reduce((a, b) => a + b) / values.length;

        points.add(ChartDataPoint(
          x: i.toDouble(),
          y: avg,
          label: DateFormat('M/d').format(date),
          shotCount: daySwings.length,
          timestamp: date,
        ));
      }
    }

    return points;
  }

  /// Yearly: Last 12 months (one point per month)
  /// Shows MAXIMUM value per month to highlight peak performance
  List<ChartDataPoint> _getYearlyPoints(String metricKey) {
    final now = DateTime.now();
    final startDate = DateTime(now.year - 1, now.month, 1);

    // Group swings by month
    final monthBuckets = <int, List<dynamic>>{};
    for (final swing in swings) {
      final swingDate = swing.timestamp as DateTime;
      final monthsSinceStart = (swingDate.year - startDate.year) * 12 +
          (swingDate.month - startDate.month);

      if (monthsSinceStart >= 0 && monthsSinceStart < 12) {
        monthBuckets.putIfAbsent(monthsSinceStart, () => []).add(swing);
      }
    }

    // Create data points for each month
    final points = <ChartDataPoint>[];
    for (int i = 0; i < 12; i++) {
      final monthDate = DateTime(
        startDate.year + (startDate.month + i - 1) ~/ 12,
        (startDate.month + i - 1) % 12 + 1,
      );
      final monthSwings = monthBuckets[i] ?? [];

      if (monthSwings.isEmpty) {
        points.add(ChartDataPoint(
          x: i.toDouble(),
          y: 0,
          label: DateFormat('MMM').format(monthDate),
          shotCount: 0,
          timestamp: monthDate,
        ));
      } else {
        // Use MAXIMUM value for yearly view to show peak performance
        final values =
            monthSwings.map((s) => _extractMetricValue(s, metricKey)).toList();
        final max = values.reduce((a, b) => a > b ? a : b);

        points.add(ChartDataPoint(
          x: i.toDouble(),
          y: max,
          label: DateFormat('MMM').format(monthDate),
          shotCount: monthSwings.length,
          timestamp: monthDate,
        ));
      }
    }

    return points;
  }

  /// All time: Monthly buckets
  List<ChartDataPoint> _getAllTimePoints(String metricKey) {
    if (swings.isEmpty) return [];

    // Find date range
    final timestamps = swings.map((s) => s.timestamp as DateTime).toList();
    final earliest = timestamps.reduce((a, b) => a.isBefore(b) ? a : b);
    final latest = timestamps.reduce((a, b) => a.isAfter(b) ? a : b);

    final startDate = DateTime(earliest.year, earliest.month, 1);
    final endDate = DateTime(latest.year, latest.month, 1);

    final totalMonths = (endDate.year - startDate.year) * 12 +
        (endDate.month - startDate.month) +
        1;

    // Limit to reasonable number of months (max 60 = 5 years)
    final limitedMonths = totalMonths > 60 ? 60 : totalMonths;

    // Group swings by month
    final monthBuckets = <int, List<dynamic>>{};
    for (final swing in swings) {
      final swingDate = swing.timestamp as DateTime;
      final monthsSinceStart = (swingDate.year - startDate.year) * 12 +
          (swingDate.month - startDate.month);

      if (monthsSinceStart >= 0 && monthsSinceStart < limitedMonths) {
        monthBuckets.putIfAbsent(monthsSinceStart, () => []).add(swing);
      }
    }

    // Create data points for each month (only include months with data)
    final points = <ChartDataPoint>[];
    for (int i = 0; i < limitedMonths; i++) {
      final monthSwings = monthBuckets[i];

      // Skip months with no data to avoid cluttering the chart
      if (monthSwings == null || monthSwings.isEmpty) {
        continue;
      }

      final monthDate = DateTime(
        startDate.year + (startDate.month + i - 1) ~/ 12,
        (startDate.month + i - 1) % 12 + 1,
      );

      final values =
          monthSwings.map((s) => _extractMetricValue(s, metricKey)).toList();
      final avg = values.reduce((a, b) => a + b) / values.length;

      points.add(ChartDataPoint(
        x: i.toDouble(),
        y: avg,
        label: DateFormat('MMM yy').format(monthDate),
        shotCount: monthSwings.length,
        timestamp: monthDate,
      ));
    }

    return points;
  }

  /// Extract metric value from swing
  double _extractMetricValue(dynamic swing, String metricKey) {
    return switch (metricKey) {
      'speed' => swing.maxVtip * 3.6, // m/s to km/h
      'force' => swing.estForceN,
      'accel' => swing.impactAmax,
      'sforce' => swing.impactSeverity,
      _ => 0.0,
    };
  }

  /// Get unit string for the metric
  String get unit {
    return switch (metricKey) {
      'speed' => 'km/h',
      'force' => 'N',
      'accel' => 'm/s²',
      'sforce' => 'N',
      _ => '',
    };
  }

  /// Get display name for the metric
  String get metricName {
    return switch (metricKey) {
      'speed' => 'Swing Speed',
      'force' => 'Impact Force',
      'accel' => 'Acceleration',
      'sforce' => 'Swing Force',
      _ => metricKey,
    };
  }

  /// Check if we have data
  bool get hasData => swings.isNotEmpty;

  /// Get time range description
  String get rangeDescription {
    return switch (range) {
      TimeRange.daily => 'Last 24 hours',
      TimeRange.weekly => 'Last 7 days',
      TimeRange.monthly => 'Last 30 days',
      TimeRange.yearly => 'Last 12 months',
      TimeRange.all => 'All time',
    };
  }

  /// Calculate value range for the metric (with padding)
  (double min, double max) get valueRange {
    final points = getDataPoints(metricKey);
    if (points.isEmpty) return (0, 100);

    final values = points.map((p) => p.y).toList();
    final minValue = values.reduce((a, b) => a < b ? a : b);
    final maxValue = values.reduce((a, b) => a > b ? a : b);

    // If all values are the same, create a range around that value
    if (minValue == maxValue) {
      final value = minValue;
      if (value == 0) {
        return (0, 10);
      }
      return (value * 0.9, value * 1.1);
    }

    // Add 10% padding on each side
    return (minValue * 0.9, maxValue * 1.1);
  }

  /// Get average value for the metric
  double get average {
    final points = getDataPoints(metricKey);
    if (points.isEmpty) return 0;

    final sum = points.map((p) => p.y).reduce((a, b) => a + b);
    return sum / points.length;
  }

  /// Get maximum value for the metric
  double get maximum {
    final points = getDataPoints(metricKey);
    if (points.isEmpty) return 0;

    return points.map((p) => p.y).reduce((a, b) => a > b ? a : b);
  }
}
