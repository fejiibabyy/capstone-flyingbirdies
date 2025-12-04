import 'package:flutter/material.dart';
import '../../widgets/glass_widgets.dart';

class SessionDetailPage extends StatelessWidget {
  const SessionDetailPage({super.key, required this.sessionId});
  final String sessionId;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor =
        isDark ? Colors.white : const Color(0xFF111827);

    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Session Details'),
          leading: const BackButton(),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: Center(
          child: GlassCard(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Details for $sessionId',
                style: TextStyle(
                  color: textColor,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
