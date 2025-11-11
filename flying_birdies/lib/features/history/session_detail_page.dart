import 'package:flutter/material.dart';
import '../../widgets/glass_widgets.dart';

class SessionDetailPage extends StatelessWidget {
  const SessionDetailPage({super.key, required this.sessionId});
  final String sessionId;

  @override
  Widget build(BuildContext context) {
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
              child: Text('Details for $sessionId',
                  style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
            ),
          ),
        ),
      ),
    );
  }
}
