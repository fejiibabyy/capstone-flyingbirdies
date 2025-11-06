import 'dart:ui' as ui;
import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../widgets/glass_widgets.dart';
import 'connect_sheet.dart'; // exports BleDevice + showConnectSheet
import '../Train/Train_tab.dart';
import '../progress/progress_tab.dart';
import '../stats/stats_tab.dart';
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});
  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0; // 0: Home, 1: Train, 2: Progress, 3: Stats, 4: Awards

  bool _isConnected = false;
  BleDevice? _device;

  // Opens the connect popup and captures the result
  Future<void> _openConnectSheet() async {
    final result = await showConnectSheet(context);
    if (result != null) {
      setState(() {
        _isConnected = true;
        _device = result;
      });
    }
  }

  // Primary CTA on the hero card:
  // if connected → go to Train tab; else → open Connect sheet
  void _handlePrimaryCta() {
    if (_isConnected) {
      setState(() => _index = 1); // Train tab
    } else {
      _openConnectSheet();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,

        body: SafeArea(
          bottom: false,
          child: IndexedStack(
            index: _index,
        children: [
          _HomeTab(
            isConnected: _isConnected,
            deviceName: _device?.name,
            onOpenConnect: _openConnectSheet,
            onPrimaryCta: _handlePrimaryCta,
          ),
          TrainTab(deviceName: _device?.name), // ← NEW
          const ProgressTab(),
          StatsTab(),
          const _PlaceholderTab(label: 'Stats / Goals'),
          const _PlaceholderTab(label: 'Awards'),
        ],
          ),
        ),

        // GLASS BOTTOM NAV
        bottomNavigationBar: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(18),
            topRight: Radius.circular(18),
          ),
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 14, sigmaY: 14),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.18),
                border: Border(
                  top: BorderSide(color: Colors.white.withValues(alpha: .10)),
                ),
              ),
              child: Theme(
                data: Theme.of(context).copyWith(
                  navigationBarTheme: NavigationBarThemeData(
                    height: 56,
                    backgroundColor: Colors.transparent,
                    indicatorColor: Colors.white.withOpacity(.16),
                    labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
                    iconTheme: WidgetStateProperty.resolveWith((s) {
                      final sel = s.contains(WidgetState.selected);
                      return IconThemeData(
                        color: sel ? Colors.white : Colors.white.withValues(alpha: .70),
                        size: 22,
                      );
                    }),
                    labelTextStyle: WidgetStateProperty.resolveWith((s) {
                      final sel = s.contains(WidgetState.selected);
                      return TextStyle(
                        color: sel ? Colors.white : Colors.white.withValues(alpha: .70),
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      );
                    }),
                  ),
                ),
                child: NavigationBar(
                  selectedIndex: _index,
                  onDestinationSelected: (i) => setState(() => _index = i),
                  destinations: const [
                    NavigationDestination(
                      icon: Icon(Icons.home_outlined),
                      selectedIcon: Icon(Icons.home_rounded),
                      label: 'Home',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.podcasts_outlined),
                      selectedIcon: Icon(Icons.podcasts_rounded),
                      label: 'Train',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.trending_up_outlined),
                      selectedIcon: Icon(Icons.trending_up_rounded),
                      label: 'Progress',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.bar_chart_outlined),
                      selectedIcon: Icon(Icons.bar_chart_rounded),
                      label: 'Stats',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.emoji_events_outlined),
                      selectedIcon: Icon(Icons.emoji_events_rounded),
                      label: 'Awards',
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// HOME tab – dynamic header & CTA
class _HomeTab extends StatelessWidget {
  const _HomeTab({
    required this.onOpenConnect,
    required this.onPrimaryCta,
    required this.isConnected,
    this.deviceName,
  });

  final VoidCallback onOpenConnect; // Bluetooth chip action
  final VoidCallback onPrimaryCta;  // Hero CTA action
  final bool isConnected;
  final String? deviceName;

  @override
  Widget build(BuildContext context) {
    final subtitle = isConnected
        ? 'Connected to ${deviceName ?? 'your sensor'}'
        : 'Connect your sensor to start training';

    final ctaText = isConnected ? 'Start Training' : 'Connect Sensor';

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: [
        // Header row
        Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFFF6FD8), Color(0xFF7E4AED)],
                ),
              ),
              child: const Icon(Icons.show_chart, size: 16, color: Colors.white),
            ),
            const SizedBox(width: 10),
            ShaderMask(
              shaderCallback: (r) =>
                  const LinearGradient(colors: AppTheme.titleGradient).createShader(r),
              child: const Text(
                'StrikePro',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white),
              ),
            ),
            const Spacer(),
            _IconChip(icon: Icons.bluetooth, onTap: onOpenConnect),
            const SizedBox(width: 8),
            const _IconChip(icon: Icons.person_outline),
          ],
        ),
        const SizedBox(height: 12),

        const Text(
          'Welcome back! 👋',
          style: TextStyle(
            color: Colors.white,
            fontSize: 26,
            fontWeight: FontWeight.w800,
            height: 1.15,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: TextStyle(
            color: Colors.white.withValues(alpha: .70),
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 14),

        // Hero card
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0x332F1A77), Color(0x333560A8)],
            ),
            border: Border.all(color: Colors.white.withValues(alpha: .10)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: .25),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 84,
                  height: 84,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFFCF67FF), Color(0xFF78C4FF)],
                    ),
                  ),
                  child: Icon(
                    isConnected ? Icons.sports_tennis_rounded : Icons.monitor_heart,
                    color: Colors.white.withValues(alpha: .88),
                    size: 40,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  isConnected ? 'All Set' : 'Start Your Journey',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 10),
                Text(
                  isConnected
                      ? 'You’re paired and ready. Start a live session to track swings, speed, and accuracy.'
                      : 'Connect your smart racket and complete your first training session to unlock streaks, achievements, and detailed analytics.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: .80),
                    fontSize: 14,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 14),

                // Primary CTA (now correctly routed)
                BounceTap(
                  onTap: onPrimaryCta,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(22),
                      gradient: const LinearGradient(colors: AppTheme.gCTA),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: .30),
                          blurRadius: 14,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Text(
                      ctaText,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Your Week snapshot
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            color: Colors.black.withOpacity(0.15),
            border: Border.all(color: Colors.white.withOpacity(.08)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(.25),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.auto_graph_rounded, size: 16, color: Colors.white),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Your Week',
                    style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  _StatTile(label: 'Sessions', value: '4'),
                  _StatTile(label: 'Avg Speed', value: '265 km/h'),
                  _StatTile(label: 'Accuracy', value: '84%'),
                  _StatTile(label: 'Streak', value: '3d'),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _IconChip extends StatelessWidget {
  const _IconChip({required this.icon, this.onTap});
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return BounceTap(
      onTap: onTap,
      child: Container(
        height: 34,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: .08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white.withValues(alpha: .12)),
        ),
        child: Icon(icon, size: 18, color: Colors.white),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final String value;
  const _StatTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}

class _PlaceholderTab extends StatelessWidget {
  const _PlaceholderTab({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        '$label – replace with your page',
        style: const TextStyle(color: Colors.white70, fontSize: 16),
      ),
    );
  }
}
