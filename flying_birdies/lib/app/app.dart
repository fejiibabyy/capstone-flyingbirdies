import 'package:flutter/material.dart';
import 'theme.dart';
import 'package:flying_birdies/features/onboarding/welcome_screen.dart';

class FlyingBirdiesApp extends StatelessWidget {
  const FlyingBirdiesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flying Birdies',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.build(),
      home: const WelcomeScreen(),
    );
  }
}
