import 'package:flutter/material.dart';

class AppTheme {
  // Brand + surfaces
  static const seed = Color(0xFF6D28D9);
  static const bgDark = Color(0xFF0B1020);
  static const surfaceGlass = Color(0x14222B45); // translucent card fill

  // Gradients 
  static const heroCorners = [bgDark, Color(0xFF7E4AED), bgDark];
  static const titleGradient = [Color(0xFFFF6FD8), Color(0xFF9B6EFF)];
  static const gPink  = [Color(0xFF5C2C7C), Color(0xFFBA2FA2)];
  static const gBlue  = [Color(0xFF1E426E), Color(0xFF1B98C0)];
  static const gTeal  = [Color(0xFF173B48), Color(0xFF13A0A0)];
  static const gCTA   = [Color(0xFFFA60D1), Color(0xFF7B7BFF)];
  static const gQA    = [Color(0xFF0FAE96), Color(0xFF1F6FEB)];

  static ThemeData build() {
    // Your SDK expects background/onBackground to be avoided; lean on surface.
    final base = ThemeData(
      useMaterial3: true,
      colorSchemeSeed: seed,
      brightness: Brightness.dark,
    );

    final scheme = base.colorScheme.copyWith(
      // Prefer surfaces; keep scaffold bg separate
      surface: const Color(0xFF12172A),
      onSurface: Colors.white70,
      outline: const Color(0x22FFFFFF),
    );

    return base.copyWith(
      colorScheme: scheme,
      scaffoldBackgroundColor: bgDark,

      // Typography (Inter declared in pubspec)
      textTheme: base.textTheme.apply(
        fontFamily: 'Inter',
        bodyColor: Colors.white70,
        displayColor: Colors.white,
      ),

      // AppBar: glassy / no elevation
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
        titleTextStyle: TextStyle(
          fontFamily: 'Inter',
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),

      // Cards (older SDK expects CardThemeData)
      cardTheme: const CardThemeData(
        color: surfaceGlass,
        margin: EdgeInsets.zero,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
          side: BorderSide(color: Color(0x1FFFFFFF)),
        ),
      ),

      // Inputs
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0x141C2540),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: TextStyle(color: Colors.white.withValues(alpha: .5)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0x1FFFFFFF)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: .35)),
        ),
      ),

      // Chips
      chipTheme: base.chipTheme.copyWith(
        backgroundColor: const Color(0x221C2540),
        side: BorderSide(color: Colors.white.withValues(alpha: 0.15)),
        labelStyle: const TextStyle(color: Colors.white),
        showCheckmark: false,
      ),

      // Buttons
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: seed,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: Colors.white.withValues(alpha: .25)),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),

      // Bottom Navigation (older SDK wants WidgetState/WidgetStateProperty)
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.transparent,
        indicatorColor: const Color(0xFF6D28D9).withValues(alpha: 0.40),
        height: 64,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final sel = states.contains(WidgetState.selected);
          return TextStyle(
            fontSize: 13,
            fontWeight: sel ? FontWeight.bold : FontWeight.w600,
            color: sel
                ? const Color.fromARGB(255, 255, 215, 0)
                : const Color.fromARGB(230, 255, 255, 255),
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final sel = states.contains(WidgetState.selected);
          return IconThemeData(
            size: 26,
            color: sel
                ? const Color.fromARGB(255, 255, 215, 0)
                : const Color.fromARGB(200, 255, 255, 255),
          );
        }),
      ),

      dividerTheme: const DividerThemeData(
        color: Color(0x22FFFFFF),
        thickness: 1,
        space: 1,
      ),
    );
  }
}
