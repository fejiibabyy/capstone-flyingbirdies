import 'package:flutter/material.dart';
import 'theme.dart';

import 'package:flying_birdies/features/live/widgets/live_page.dart';
import 'package:flying_birdies/features/history/widgets/history_page.dart';
import 'package:flying_birdies/features/charts/widgets/charts_page.dart';
import 'package:flying_birdies/features/tips/tips_page.dart';


class FlyingBirdiesApp extends StatefulWidget {
  const FlyingBirdiesApp({super.key});

  @override
  State<FlyingBirdiesApp> createState() => _FlyingBirdiesAppState();
}

class _FlyingBirdiesAppState extends State<FlyingBirdiesApp> {
  int index = 0;
  final pages = [LivePage(), HistoryPage(), ChartsPage(), TipsPage()];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flying Birdies',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.build(),
      home: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft, end: Alignment.bottomRight,
            colors: [AppTheme.bgDark, Color.fromARGB(255, 126, 74, 237), AppTheme.bgDark],
          ),
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            surfaceTintColor: Colors.transparent,
            centerTitle: true,
           title: ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Color(0xFFFF6FD8), Color(0xFF9B6EFF)], // purple → deep blue
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ).createShader(bounds),
          child: const Text(
            'StrikePro',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.white, // Needed but will be overridden by gradient
            ),
          ),
        ),
          ),

          body: pages[index],
          bottomNavigationBar: NavigationBar(
            backgroundColor: const Color(0x111C2540),
            indicatorColor: const Color(0x336D28D9),
            selectedIndex: index,
            onDestinationSelected: (i) => setState(() => index = i),
            destinations: const [
              NavigationDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard), label: 'Live'),
              NavigationDestination(icon: Icon(Icons.history_outlined), selectedIcon: Icon(Icons.history), label: 'History'),
              NavigationDestination(icon: Icon(Icons.bar_chart_outlined), selectedIcon: Icon(Icons.bar_chart), label: 'Charts'),
              NavigationDestination(icon: Icon(Icons.tips_and_updates_outlined), selectedIcon: Icon(Icons.tips_and_updates), label: 'Tips'),
            ],
          ),
        ),
      ),
    );
  }
}
