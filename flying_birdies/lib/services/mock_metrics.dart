import 'dart:async';
import 'dart:math';
import '../models/metrics.dart';

class MockMetricsService {
  MockMetricsService._();
  static final instance = MockMetricsService._();
  final _rand = Random();
  final _controller = StreamController<Metrics>.broadcast();
  Timer? _timer;

  Stream<Metrics> get stream {
    _start();
    return _controller.stream;
  }

  void _start() {
    _timer ??= Timer.periodic(const Duration(milliseconds: 120), (_) {
      final t = DateTime.now().millisecond / 1000.0;
      final force = 10 + 6 * sin(t * 6) + _rand.nextDouble() * 2;
      final speed = 5 + 3 * sin(t * 4 + 1.2) + _rand.nextDouble();
      final accel = 2 + 1.5 * sin(t * 7 + 0.6) + _rand.nextDouble();
      _controller.add(Metrics(forceN: force, speedMs: speed, accelMs2: accel));
    });
  }

  void dispose() {
    _timer?.cancel();
    _controller.close();
  }
}
