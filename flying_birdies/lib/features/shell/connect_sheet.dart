import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../../app/theme.dart';

class BleDevice {
  final String id;
  final String name;
  const BleDevice({required this.id, required this.name});
}

/// Open the connect sheet and get the connected device (or null if cancelled)
Future<BleDevice?> showConnectSheet(BuildContext context) {
  return showModalBottomSheet<BleDevice?>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withOpacity(.35),
    builder: (_) => const _ConnectSheet(),
  );
}

class _ConnectSheet extends StatefulWidget {
  const _ConnectSheet();

  @override
  State<_ConnectSheet> createState() => _ConnectSheetState();
}

class _ConnectSheetState extends State<_ConnectSheet> {
  bool _scanning = false;
  bool _connected = false;
  BleDevice? _selected;
  List<BleDevice> _devices = const [];

  Future<void> _startScan() async {
    if (_scanning) return;
    setState(() {
      _scanning = true;
      _devices = const [];
      _selected = null;
      _connected = false;
    });

    // TODO: replace with real BLE scan
    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      _scanning = false;
      _devices = const [
        BleDevice(id: 'strikepro-001', name: 'StrikePro Sensor'),
        BleDevice(id: 'strikepro-002', name: 'StrikePro Sensor (Coach)'),
      ];
    });
  }

  Future<void> _connect() async {
    if (_selected == null) {
      return _startScan();
    }
    setState(() => _scanning = true);
    await Future.delayed(const Duration(milliseconds: 900));
    setState(() {
      _scanning = false;
      _connected = true;
    });
  }

  Color get _bannerColor {
    if (_connected) return const Color(0xFF16A34A).withOpacity(.18);
    if (_scanning) return const Color(0xFF7C3AED).withOpacity(.18);
    if (_devices.isEmpty) return const Color(0xFFF0433A).withOpacity(.16);
    return Colors.white.withOpacity(.08);
  }

  IconData get _bannerIcon {
    if (_connected) return Icons.check_circle_rounded;
    if (_scanning) return Icons.wifi_tethering_rounded;
    if (_devices.isEmpty) return Icons.error_outline;
    return Icons.info_outline_rounded;
  }

  String get _bannerTitle {
    if (_connected) return 'Device Connected';
    if (_scanning) return 'Scanning for Devices…';
    if (_devices.isEmpty) return 'No Device Found';
    return 'Select a Device';
  }

  String get _bannerSubtitle {
    if (_connected) return 'You’re ready to train';
    if (_scanning) return 'Keep your sensor powered on';
    if (_devices.isEmpty) return 'Make sure your sensor is on';
    return 'Tap a device below to pair & connect';
  }

  String get _ctaText {
    if (_connected) return 'Done';
    if (_scanning) return 'Working...';
    if (_selected == null && _devices.isEmpty) return 'Scan for Devices';
    if (_selected == null && _devices.isNotEmpty) return 'Scan Again';
    return 'Pair & Connect';
  }

  VoidCallback? get _ctaAction {
    if (_connected) {
      return () => Navigator.of(context).pop(_selected);
    }
    if (_scanning) return null;
    if (_selected == null && _devices.isEmpty) return _startScan;
    if (_selected == null && _devices.isNotEmpty) return _startScan;
    return _connect;
  }

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(18);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        child: ClipRRect(
          borderRadius: radius,
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 16, sigmaY: 16),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF0E1220).withOpacity(.88),
                borderRadius: radius,
                border: Border.all(color: Colors.white.withOpacity(.06)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(.40),
                    blurRadius: 28,
                    offset: const Offset(0, 18),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Grab handle
                  Container(
                    width: 48,
                    height: 6,
                    margin: const EdgeInsets.only(top: 10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(.14),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),

                  // Content
                  Padding(
                    padding: const EdgeInsets.fromLTRB(18, 12, 18, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Pill
                        Container(
                          height: 36,
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(999),
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [Color(0xFF7C3AED), Color(0xFF6D28D9)],
                            ),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.bluetooth, color: Colors.white, size: 18),
                              SizedBox(width: 8),
                              Text('Bluetooth',
                                  style: TextStyle(
                                      color: Colors.white, fontWeight: FontWeight.w700)),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Title + subtitle
                        const Text(
                          'Smart Racket Sensor',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Connect your Bluetooth-enabled badminton racket',
                          style: TextStyle(
                            color: Colors.white.withOpacity(.75),
                            fontSize: 14,
                            height: 1.35,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Status banner
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 220),
                          curve: Curves.easeOut,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: _bannerColor,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: Colors.white.withOpacity(.08)),
                          ),
                          child: Row(
                            children: [
                              Icon(_bannerIcon,
                                  size: 20,
                                  color: _connected
                                      ? const Color(0xFF16A34A)
                                      : _scanning
                                          ? const Color(0xFF7C3AED)
                                          : (_devices.isEmpty
                                              ? const Color(0xFFF0433A)
                                              : Colors.white70)),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _bannerTitle,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      _bannerSubtitle,
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(.72),
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        if (_scanning) ...[
                          const SizedBox(height: 10),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(999),
                            child: LinearProgressIndicator(
                              minHeight: 6,
                              backgroundColor: Colors.white.withOpacity(.08),
                              valueColor: AlwaysStoppedAnimation<Color>(
                                const Color(0xFF7C3AED).withOpacity(.85),
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(height: 14),

                        // Device area
                        if (_devices.isEmpty && !_scanning && !_connected)
                          _EmptyState(onScan: _startScan)
                        else if (_devices.isNotEmpty)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Available Devices',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(.85),
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 10),
                              ..._devices.map(
                                (d) => Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: _DeviceRow(
                                    device: d,
                                    selected: _selected?.id == d.id,
                                    onTap: () => setState(() => _selected = d),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        if (_connected && _selected != null) ...[
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(999),
                                  color: const Color(0xFF16A34A),
                                ),
                                child: const Text(
                                  'CONNECTED',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: .2,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                _selected!.id,
                                style: TextStyle(
                                  color: Colors.white.withOpacity(.75),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],

                        const SizedBox(height: 16),

                        // CTA
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              elevation: 0,
                              padding: EdgeInsets.zero,
                              backgroundColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14)),
                            ),
                            onPressed: _ctaAction,
                            child: Ink(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(14),
                                gradient: const LinearGradient(colors: AppTheme.gCTA),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(.30),
                                    blurRadius: 16,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: Container(
                                alignment: Alignment.center,
                                height: 52,
                                child: Text(
                                  _ctaText,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Footer
                  Container(
                    height: 54,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(.06),
                      border:
                          Border(top: BorderSide(color: Colors.white.withOpacity(.06))),
                    ),
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(null),
                      child: const Text(
                        'Close',
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DeviceRow extends StatelessWidget {
  const _DeviceRow({
    required this.device,
    required this.selected,
    required this.onTap,
  });

  final BleDevice device;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: Colors.white.withOpacity(.04),
          border: Border.all(
            color: selected ? Colors.white.withOpacity(.28) : Colors.white.withOpacity(.08),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.18),
              blurRadius: 12,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: selected ? Colors.white : Colors.white70,
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    device.name,
                    style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    device.id,
                    style: TextStyle(
                      color: Colors.white.withOpacity(.65),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.bluetooth, color: Colors.white70, size: 18),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onScan});
  final VoidCallback onScan;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 16, 14, 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: Colors.white.withOpacity(.04),
        border: Border.all(color: Colors.white.withOpacity(.08)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFF0433A).withOpacity(.20),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.search_off, color: Color(0xFFF0433A), size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'No devices yet. Turn on your sensor and scan.',
              style: TextStyle(
                color: Colors.white.withOpacity(.78),
                fontSize: 13,
              ),
            ),
          ),
          TextButton(
            onPressed: onScan,
            child: const Text('Scan', style: TextStyle(fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
  }
}
