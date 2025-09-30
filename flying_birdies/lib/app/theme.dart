import 'package:flutter/material.dart';

class AppTheme {
  static const seed = Color(0xFF6D28D9);
  static const bgDark = Color(0xFF0B1020);

  static ThemeData build() {
    final base = ThemeData(useMaterial3: true, colorSchemeSeed: seed);
    return base.copyWith(
      scaffoldBackgroundColor: bgDark,
      textTheme: base.textTheme.apply(
        fontFamily: 'Inter',
        bodyColor: Colors.white70,
        displayColor: Colors.white,
      ),
      cardTheme: const CardThemeData(
      color: Color(0x14222B45),
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(16)),
  ),
  elevation: 2,
),

      chipTheme: base.chipTheme.copyWith(
        backgroundColor: const Color(0x221C2540),
        side: BorderSide(color: Colors.white.withValues(alpha : 0.15)),
        labelStyle: const TextStyle(color: Colors.white),
      ),
    );
  }
}
