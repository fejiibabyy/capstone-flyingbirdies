import 'package:flutter/material.dart';
import '../../widgets/glass_widgets.dart';
import 'history_tab.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        // Let the gradient paint under the status bar
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          title: const Text('History'),
          leading: const BackButton(),
          elevation: 0,
          backgroundColor: Colors.transparent,
        ),
        // Give some top padding so content isn’t under the notch
        body: Padding(
          padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 8),
          child: const HistoryTab(),
        ),
      ),
    );
  }
}
