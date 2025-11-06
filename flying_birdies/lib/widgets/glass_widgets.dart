// lib/widgets/glass_widgets.dart
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flying_birdies/app/theme.dart';

/// ------------------------------------------------------------
/// BACKGROUND: diagonal purple→indigo→dark gradient
/// ------------------------------------------------------------
class GradientBackground extends StatelessWidget {
  const GradientBackground({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: AppTheme.heroCorners,
        ),
      ),
      child: child,
    );
  }
}

/// ------------------------------------------------------------
/// GLASS CARD (blurred, frosted panel)
/// ------------------------------------------------------------
class GlassCard extends StatelessWidget {
  const GlassCard({super.key, this.child, this.padding});
  final Widget? child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: padding ?? const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            color: const Color(0x33FFFFFF), // ~20% white
            border: Border.all(color: const Color(0x22FFFFFF)),
            boxShadow: const [
              BoxShadow(
                blurRadius: 16,
                color: Color(0x22000000),
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

/// ------------------------------------------------------------
/// GLASS PANEL (gradient-tinted card, no blur)
/// Used for the colored cards/tiles in your screenshots.
/// ------------------------------------------------------------
class GlassPanel extends StatelessWidget {
  const GlassPanel({
    super.key,
    required this.child,
    this.overlayGradient,
    this.padding = const EdgeInsets.all(16),
  });

  final Widget child;
  final List<Color>? overlayGradient;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: overlayGradient ??
              [Colors.white.withValues(alpha: .10), Colors.white.withValues(alpha: .06)],
        ),
        border: Border.all(color: Colors.white.withValues(alpha: .12)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .25),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(padding: padding, child: child),
    );
  }
}

/// ------------------------------------------------------------
/// FEATURE CARD (icon + title + subtitle) with subtle gradient
/// ------------------------------------------------------------
class FeatureCard extends StatelessWidget {
  const FeatureCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.gradient, // e.g., AppTheme.gPink / gBlue / gTeal
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final List<Color> gradient;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradient,
        ),
        border: Border.all(color: Colors.white.withValues(alpha: .12)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .25),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: .12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 22, color: Colors.white),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      )),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withValues(alpha: .80),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ------------------------------------------------------------
/// GRADIENT BUTTON — matches the “Get Started” / “Connect Sensor”
/// ------------------------------------------------------------
class GradientButton extends StatelessWidget {
  const GradientButton({
    super.key,
    required this.label,
    required this.onTap,
  });

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          gradient: const LinearGradient(colors: AppTheme.gCTA),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: .25),
              blurRadius: 10,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

/// ------------------------------------------------------------
/// BADGE (solid rounded label)
/// ------------------------------------------------------------
class AppBadge extends StatelessWidget {
  const AppBadge({super.key, required this.text, required this.color});
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// ------------------------------------------------------------
/// PILL (chip-like gradient or glass capsule)
/// ------------------------------------------------------------
class Pill extends StatelessWidget {
  const Pill({
    super.key,
    required this.label,
    this.icon,
    this.selected = false,
    this.selectedGradient,
    this.onTap,
  });

  final String label;
  final IconData? icon;
  final bool selected;
  final Gradient? selectedGradient;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    const Gradient fallback = LinearGradient(
      colors: [Color(0xFFFF6FD8), Color(0xFF9B6EFF)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    final decoration = BoxDecoration(
      gradient: selected ? (selectedGradient ?? fallback) : null,
      color: selected ? null : Colors.white.withValues(alpha: .08),
      borderRadius: BorderRadius.circular(22),
      border: Border.all(
        color: selected ? Colors.transparent : Colors.white.withValues(alpha: .30),
        width: 1,
      ),
    );

    final inner = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, color: Colors.white, size: 16),
            const SizedBox(width: 6),
          ],
          Flexible(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style: TextStyle(
                color: Colors.white,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );

    return Material(
      color: Colors.transparent,
      child: Ink(
        decoration: decoration,
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: onTap,
          child: inner,
        ),
      ),
    );
  }
}

/// ------------------------------------------------------------
/// STATUS DOT (tiny colored indicator)
/// ------------------------------------------------------------
class StatusDot extends StatelessWidget {
  const StatusDot({super.key, required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}
// --- ANIMATION HELPERS -------------------------------------------------------

// Tap bounce wrapper for buttons/tiles
class BounceTap extends StatefulWidget {
  const BounceTap({super.key, required this.child, this.onTap});
  final Widget child;
  final VoidCallback? onTap;

  @override
  State<BounceTap> createState() => _BounceTapState();
}

class _BounceTapState extends State<BounceTap> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 90),
    lowerBound: 0.0,
    upperBound: 0.06,
  );

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  void _press() async {
    await _c.forward();
    await _c.reverse();
    widget.onTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _press,
      child: AnimatedBuilder(
        animation: _c,
        builder: (_, child) {
          final scale = 1 - _c.value;
          return Transform.scale(scale: scale, child: child);
        },
        child: widget.child,
      ),
    );
  }
}

// A subtle, breathing gradient that very slowly shifts (background accent)
class AnimatedGradientBackground extends StatefulWidget {
  const AnimatedGradientBackground({super.key, required this.child});
  final Widget child;

  @override
  State<AnimatedGradientBackground> createState() => _AnimatedGradientBackgroundState();
}

class _AnimatedGradientBackgroundState extends State<AnimatedGradientBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(seconds: 12))
        ..repeat(reverse: true);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (_, __) {
        final t = _c.value;
        // lerp the middle color a bit to get a gentle shift
        final mid = Color.lerp(const Color(0xFF7E4AED), const Color(0xFF5E79FF), t)!;
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppTheme.bgDark, mid, AppTheme.bgDark],
            ),
          ),
          child: widget.child,
        );
      },
    );
  }
}
