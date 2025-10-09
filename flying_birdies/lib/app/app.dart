import 'package:flutter/material.dart';
import 'theme.dart';

// keep these as-is if your pubspec name is flying_birdies.
// If you ever see “Target of URI doesn’t exist”, switch to relative imports.
import 'package:flying_birdies/features/live/widgets/live_page.dart';
import 'package:flying_birdies/features/history/widgets/history_page.dart';
import 'package:flying_birdies/features/charts/widgets/charts_page.dart';
import 'package:flying_birdies/features/tips/tips_page.dart';
import 'package:flying_birdies/widgets/glass_widgets.dart';

class FlyingBirdiesApp extends StatefulWidget {
  const FlyingBirdiesApp({super.key});

  @override
  State<FlyingBirdiesApp> createState() => _FlyingBirdiesAppState();
}

class _FlyingBirdiesAppState extends State<FlyingBirdiesApp> {
  int index = 0;
  final pages = const [LivePage(), HistoryPage(), ChartsPage(), TipsPage()];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flying Birdies',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.build().copyWith(
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: true,
        ),
        navigationBarTheme: const NavigationBarThemeData(
          backgroundColor: Colors.transparent,
          indicatorColor: Color(0x336D28D9),
          height: 64,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        ),
      ),
      home: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppTheme.bgDark, Color(0xFF7E4AED), AppTheme.bgDark],
          ),
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,

          // ── HEADER ────────────────────────────────────────────────────────────
          appBar: AppBar(
            centerTitle: true,
            title: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                    gradient: LinearGradient(
                      colors: [Color(0xFFFF6FD8), Color(0xFF7E4AED)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: const Icon(Icons.show_chart, size: 16, color: Colors.white),
                ),
                const SizedBox(width: 8),
                ShaderMask(
                  shaderCallback: (b) => const LinearGradient(
                    colors: [Color(0xFFFF6FD8), Color(0xFF9B6EFF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ).createShader(b),
                  child: const Text(
                    'StrikePro',
                    style: TextStyle(
                      fontSize: 24, // slightly smaller = less crowding
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(96),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24),
                      child: Text(
                        'Elite Badminton • Smart Analytics • Peak Performance',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 10,
                      runSpacing: 8,
                      alignment: WrapAlignment.center,
                      children: [
                        Pill(
                          label: 'Live Analytics',
                          icon: Icons.podcasts_outlined,
                          selected: true, // always colored
                          selectedGradient: const LinearGradient(
                            colors: [Color(0xFFFF6FD8), Color(0xFFF968A6)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        Pill(
                          label: 'Smart Analytics',
                          icon: Icons.insights_outlined,
                          selected: true,
                          selectedGradient: const LinearGradient(
                            colors: [Color(0xFF69B4FF), Color(0xFF3B82F6)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        Pill(
                          label: 'Pro Training',
                          icon: Icons.workspace_premium_outlined,
                          selected: true,
                          selectedGradient: const LinearGradient(
                            colors: [Color(0xFF7ED957), Color(0xFF34C759)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── BODY ─────────────────────────────────────────────────────────────
          body: pages[index],

          // ── BOTTOM NAV ───────────────────────────────────────────────────────
          bottomNavigationBar: NavigationBar(
            selectedIndex: index,
            onDestinationSelected: (i) => setState(() => index = i),
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.dashboard_outlined),
                selectedIcon: Icon(Icons.dashboard),
                label: 'Live',
              ),
              NavigationDestination(
                icon: Icon(Icons.history_outlined),
                selectedIcon: Icon(Icons.history),
                label: 'History',
              ),
              NavigationDestination(
                icon: Icon(Icons.bar_chart_outlined),
                selectedIcon: Icon(Icons.bar_chart),
                label: 'Charts',
              ),
              NavigationDestination(
                icon: Icon(Icons.tips_and_updates_outlined),
                selectedIcon: Icon(Icons.tips_and_updates),
                label: 'Tips',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
