import 'package:flutter/material.dart';

class MetricCard extends StatelessWidget {
  final String label, value;
  final Widget? trailing;
  const MetricCard({super.key, required this.label, required this.value, this.trailing});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    
    // Different gradient colors for each different metric type
    final gradient = _getGradientForLabel(label);
    
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradient,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: gradient[0].withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon for each metric
              _getIconForLabel(label),
              const SizedBox(height: 12),
              
              // Label
              Text(
                label,
                style: t.titleSmall?.copyWith(
                  color: Colors.white.withOpacity(0.9),
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              
              // Value with the gradient text
              ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [Colors.white, Color(0xFFE0E0E0)],
                ).createShader(bounds),
                child: Text(
                  value,
                  style: t.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 28,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              
              if (trailing != null) ...[
                const SizedBox(height: 8),
                trailing!
              ],
            ],
          ),
        ),
      ),
    );
  }

  // Get the gradient colors based on metric type
  List<Color> _getGradientForLabel(String label) {
    if (label.contains('Force') || label.contains('Impact')) {
      return [
        const Color.fromARGB(255, 105, 38, 212).withOpacity(0.8), // Purple
        const Color.fromARGB(255, 147, 51, 234).withOpacity(0.6), // Lighter purple
      ];
    } else if (label.contains('Speed') || label.contains('Racket')) {
      return [
        const Color.fromARGB(255, 14, 165, 233).withOpacity(0.8), // Cyan
        const Color.fromARGB(255, 6, 182, 212).withOpacity(0.6),  // Light cyan
      ];
    } else if (label.contains('Acceleration')) {
      return [
        const Color.fromARGB(255, 236, 72, 153).withOpacity(0.8), // Pink
        const Color.fromARGB(255, 244, 114, 182).withOpacity(0.6), // Light pink
      ];
    } else if (label.contains('Session')) {
      return [
        const Color.fromARGB(255, 16, 185, 129).withOpacity(0.8), // Green
        const Color.fromARGB(255, 52, 211, 153).withOpacity(0.6),  // Light green
      ];
    }
    // Default gradient
    return [
      const Color.fromARGB(255, 105, 38, 212).withOpacity(0.8),
      const Color.fromARGB(255, 147, 51, 234).withOpacity(0.6),
    ];
  }

  // Get icon based on metric type
  Widget _getIconForLabel(String label) {
    IconData icon;
    Color iconColor = const Color.fromARGB(255, 255, 215, 0); // Bright Gold for all icons
    
    if (label.contains('Force') || label.contains('Impact')) {
      icon = Icons.flash_on;
    } else if (label.contains('Speed') || label.contains('Racket')) {
      icon = Icons.speed;
    } else if (label.contains('Acceleration')) {
      icon = Icons.trending_up;
    } else if (label.contains('Session')) {
      icon = Icons.analytics;
    } else {
      icon = Icons.info_outline;
    }
    
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: iconColor.withOpacity(0.2),
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        color: iconColor,
        size: 26,
      ),
    );
  }
}