class Metrics {
  final double forceN, speedMs, accelMs2;
  const Metrics({required this.forceN, required this.speedMs, required this.accelMs2});
  factory Metrics.zero() => const Metrics(forceN: 0, speedMs: 0, accelMs2: 0);
}
