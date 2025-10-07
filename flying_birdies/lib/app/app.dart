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
            begin: Alignment.topLeft, 
            end: Alignment.bottomRight,
            colors: [AppTheme.bgDark, Color.fromARGB(255, 126, 74, 237), AppTheme.bgDark],
          ),
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            surfaceTintColor: Colors.transparent,
            centerTitle: true,
            elevation: 0,
            title: ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [Color(0xFFFF6FD8), Color(0xFF9B6EFF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ).createShader(bounds),
              child: const Text(
                'StrikePro',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),

          body: pages[index],
          
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              color: const Color.fromARGB(240, 11, 16, 32), // Solid dark background
              border: Border(
                top: BorderSide(
                  color: const Color.fromARGB(255, 109, 40, 217).withOpacity(0.3),
                  width: 2,
                ),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: NavigationBar(
              backgroundColor: Colors.transparent,
              indicatorColor: const Color.fromARGB(100, 109, 40, 217),
              selectedIndex: index,
              onDestinationSelected: (i) => setState(() => index = i),
              labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
              height: 70,
              destinations: [
                NavigationDestination(
                  icon: Icon(
                    Icons.dashboard_outlined, 
                    color: const Color.fromARGB(180, 255, 255, 255),
                    size: 26,
                  ),
                  selectedIcon: const Icon(
                    Icons.dashboard, 
                    color: Color.fromARGB(255, 255, 215, 0),
                    size: 26,
                  ),
                  label: 'Live',
                ),
                NavigationDestination(
                  icon: Icon(
                    Icons.history_outlined, 
                    color: const Color.fromARGB(180, 255, 255, 255),
                    size: 26,
                  ),
                  selectedIcon: const Icon(
                    Icons.history, 
                    color: Color.fromARGB(255, 255, 215, 0),
                    size: 26,
                  ),
                  label: 'History',
                ),
                NavigationDestination(
                  icon: Icon(
                    Icons.bar_chart_outlined, 
                    color: const Color.fromARGB(180, 255, 255, 255),
                    size: 26,
                  ),
                  selectedIcon: const Icon(
                    Icons.bar_chart, 
                    color: Color.fromARGB(255, 255, 215, 0),
                    size: 26,
                  ),
                  label: 'Charts',
                ),
                NavigationDestination(
                  icon: Icon(
                    Icons.tips_and_updates_outlined, 
                    color: const Color.fromARGB(180, 255, 255, 255),
                    size: 26,
                  ),
                  selectedIcon: const Icon(
                    Icons.tips_and_updates, 
                    color: Color.fromARGB(255, 255, 215, 0),
                    size: 26,
                  ),
                  label: 'Tips',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}