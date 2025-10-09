import 'dart:ui';
import 'package:flutter/material.dart';

class GlassCard extends StatelessWidget {
  const GlassCard({super.key, this.child, this.padding});
  final Widget? child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: padding ?? const EdgeInsets.all(8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            color: const Color(0x33FFFFFF),
            border: Border.all(color: const Color(0x22FFFFFF)),
            boxShadow: const [BoxShadow(blurRadius: 16, color: Color(0x22000000), offset: Offset(0, 6))],
          ),
          child: child,
        ),
      ),
    );
  }
}

class AppBadge extends StatelessWidget {
  const AppBadge({super.key, required this.text, required this.color});
  final String text;
  final Color color;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(999)),
      child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
    );
  }
}

class Pill extends StatelessWidget {
  const Pill({
    super.key,
    required this.label,
    this.icon,
    this.selected = false,
    this.selectedGradient,
    this.onTap, // optional
  });

  final String label;
  final IconData? icon;
  final bool selected;
  final Gradient? selectedGradient;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final Gradient fallback = const LinearGradient(
      colors: [Color(0xFFFF6FD8), Color(0xFF9B6EFF)],
      begin: Alignment.topLeft, end: Alignment.bottomRight,
    );

    final decoration = BoxDecoration(
      gradient: selected ? (selectedGradient ?? fallback) : null,
      color: selected ? null : Colors.white.withOpacity(0.08),
      borderRadius: BorderRadius.circular(22),
      border: Border.all(
        color: selected ? Colors.transparent : Colors.white30, // a touch stronger
        width: 1,
      ),
    );

    final child = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
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
      ]),
    );

    return Material(
      color: Colors.transparent,
      child: Ink(
        decoration: decoration,
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: onTap,
          child: child,
        ),
      ),
    );
  }
}



class StatusDot extends StatelessWidget {
  const StatusDot({super.key, required this.color});
  final Color color;
  @override
  Widget build(BuildContext context) {
    return Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle));
  }
}
