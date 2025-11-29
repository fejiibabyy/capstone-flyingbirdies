import 'dart:ui' as ui;
import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../widgets/glass_widgets.dart';

import '../Train/train_tab.dart';
import '../history/history_tab.dart';
import '../stats/stats_tab.dart';

import 'connect_sheet.dart'; // BleDevice + showConnectSheet()

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});
  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  bool _isConnected = false;
  BleDevice? _device;

  Future<void> _openConnectSheet() async {
    final result = await showConnectSheet(context);
    if (result != null) {
      setState(() {
        _isConnected = true;
        _device = result;
      });
    }
  }

  void _handlePrimaryCta() {
    if (_isConnected) {
      setState(() => _index = 1); // Train tab
    } else {
      _openConnectSheet();
    }
  }

  void _goToHistory() => setState(() => _index = 2);

  void _openProfile() {
    Navigator.of(context).pushNamed('/profile');
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
                onGoToHistory: _goToHistory,
                onOpenProfile: _openProfile,
              ),
              TrainTab(deviceName: _device?.name),
              const HistoryTab(),
              StatsTab(),
            ],
          ),
        ),
        bottomNavigationBar: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(18),
            topRight: Radius.circular(18),
          ),
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 14, sigmaY: 14),
            child: Container(
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.black.withValues(alpha: .18)
                    : Colors.white.withValues(alpha: .85),
                border: Border(
                  top: BorderSide(
                    color: isDark
                        ? Colors.white.withValues(alpha: .10)
                        : Colors.black.withValues(alpha: .08),
                  ),
                ),
              ),
              child: Theme(
                data: Theme.of(context).copyWith(
                  navigationBarTheme: NavigationBarThemeData(
                    height: 56,
                    backgroundColor: Colors.transparent,
                    indicatorColor: isDark
                        ? Colors.white.withValues(alpha: .16)
                        : AppTheme.seed.withValues(alpha: .12),
                    labelBehavior:
                        NavigationDestinationLabelBehavior.alwaysShow,
                    iconTheme: WidgetStateProperty.resolveWith((s) {
                      final sel = s.contains(WidgetState.selected);
                      return IconThemeData(
                        color: sel
                            ? (isDark
                                ? Colors.white
                                : AppTheme.seed)
                            : (isDark
                                ? Colors.white.withValues(alpha: .70)
                                : Colors.black.withValues(alpha: .45)),
                        size: 22,
                      );
                    }),
                    labelTextStyle: WidgetStateProperty.resolveWith((s) {
                      final sel = s.contains(WidgetState.selected);
                      return TextStyle(
                        color: sel
                            ? (isDark
                                ? Colors.white
                                : AppTheme.seed)
                            : (isDark
                                ? Colors.white.withValues(alpha: .70)
                                : Colors.black.withValues(alpha: .55)),
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
                      icon: Icon(Icons.calendar_month_outlined),
                      selectedIcon: Icon(Icons.calendar_month_rounded),
                      label: 'History',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.bar_chart_outlined),
                      selectedIcon: Icon(Icons.bar_chart_rounded),
                      label: 'Stats',
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

/// =============================================================
/// HOME TAB
/// =============================================================
class _HomeTab extends StatelessWidget {
  const _HomeTab({
    required this.onOpenConnect,
    required this.onPrimaryCta,
    required this.onGoToHistory,
    required this.onOpenProfile,
    required this.isConnected,
    this.deviceName,
  });

  final VoidCallback onOpenConnect;
  final VoidCallback onPrimaryCta;
  final VoidCallback onGoToHistory;
  final VoidCallback onOpenProfile;
  final bool isConnected;
  final String? deviceName;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryTextColor =
        isDark ? Colors.white : const Color(0xFF111827);
    final secondaryTextColor =
        isDark ? Colors.white.withValues(alpha: .70) : const Color(0xFF6B7280);
    final mutedOnCard =
        isDark ? Colors.white.withValues(alpha: .80) : const Color(0xFF4B5563);

    final subtitle = isConnected
        ? 'Connected to ${deviceName ?? 'your sensor'}'
        : 'Connect your sensor to start training';
    final ctaText = isConnected ? 'Start Session' : 'Connect Sensor';

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: [
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
              child: const Icon(Icons.show_chart,
                  size: 16, color: Colors.white),
            ),
            const SizedBox(width: 10),
            ShaderMask(
              shaderCallback: (r) =>
                  const LinearGradient(colors: AppTheme.titleGradient)
                      .createShader(r),
              child: Text(
                'StrikePro',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: primaryTextColor,
                ),
              ),
            ),
            const Spacer(),
            _IconChip(icon: Icons.bluetooth, onTap: onOpenConnect),
            const SizedBox(width: 8),
            _IconChip(icon: Icons.person_outline, onTap: onOpenProfile),
          ],
        ),
        const SizedBox(height: 12),

        // Welcome text
        Text(
          'Welcome back! 👋',
          style: TextStyle(
            color: primaryTextColor,
            fontSize: 26,
            fontWeight: FontWeight.w800,
            height: 1.15,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: TextStyle(
            color: secondaryTextColor,
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
                    isConnected
                        ? Icons.sports_tennis_rounded
                        : Icons.monitor_heart,
                    color: Colors.white.withValues(alpha: .88),
                    size: 40,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Start Your Journey',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
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
                BounceTap(
                  onTap: onPrimaryCta,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 12),
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
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Your Week card
        Container(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            color: isDark
                ? Colors.black.withValues(alpha: 0.15)
                : Colors.white,
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: .08)
                  : Colors.black.withValues(alpha: .06),
            ),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? Colors.black.withValues(alpha: .25)
                    : Colors.black.withValues(alpha: .08),
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
                      color: isDark
                          ? Colors.white.withValues(alpha: .12)
                          : Colors.black.withValues(alpha: .04),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.auto_graph_rounded,
                        size: 16,
                        color: isDark
                            ? Colors.white
                            : const Color(0xFF111827)),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Your Week',
                    style: TextStyle(
                      color: primaryTextColor,
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                  const Spacer(),
                  BounceTap(
                    onTap: onGoToHistory,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withValues(alpha: .10)
                            : Colors.black.withValues(alpha: .04),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isDark
                              ? Colors.white.withValues(alpha: .12)
                              : Colors.black.withValues(alpha: .08),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Open History',
                            style: TextStyle(
                              color: isDark
                                  ? Colors.white
                                  : const Color(0xFF111827),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Icon(Icons.chevron_right,
                              size: 16,
                              color: isDark
                                  ? Colors.white
                                  : const Color(0xFF111827)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  _StatTile(label: 'Sessions', value: '4'),
                  _StatTile(label: 'Avg Speed', value: '265 km/h'),
                  _StatTile(label: 'Avg Force', value: '74 N'),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return BounceTap(
      onTap: onTap,
      child: Container(
        height: 34,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withValues(alpha: .08)
              : Colors.white.withValues(alpha: .90),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: .12)
                : Colors.black.withValues(alpha: .06),
          ),
        ),
        child: Icon(
          icon,
          size: 18,
          color: isDark
              ? Colors.white
              : const Color(0xFF111827),
        ),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final valueColor =
        isDark ? Colors.white : const Color(0xFF111827);
    final labelColor =
        isDark ? Colors.white.withValues(alpha: .70) : const Color(0xFF6B7280);

    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: valueColor,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(color: labelColor, fontSize: 13),
        ),
      ],
    );
  }
}
