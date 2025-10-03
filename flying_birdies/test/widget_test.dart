import 'package:flutter_test/flutter_test.dart';
import 'package:flying_birdies/app/app.dart';
import 'package:flutter/material.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const FlyingBirdiesApp());
    // Basic sanity check: app title appears in the AppBar
    expect(find.text('Flying Birdies'), findsOneWidget);
  });
}
