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
        side: BorderSide(color: Colors.white.withValues(alpha: 0.15)),
        labelStyle: const TextStyle(color: Colors.white),
      ),
      
      // Navigation bar text styling
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.transparent,
        indicatorColor: const Color(0xFF6D28D9).withOpacity(0.4),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Color.fromARGB(255, 255, 215, 0), // Bright gold for selected
            );
          }
          return const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color.fromARGB(230, 255, 255, 255), // Very bright white for unselected
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(
              color: Color.fromARGB(255, 255, 215, 0), // Bright gold
              size: 26,
            );
          }
          return const IconThemeData(
            color: Color.fromARGB(200, 255, 255, 255), // Bright white
            size: 26,
          );
        }),
      ),
    );
  }
}