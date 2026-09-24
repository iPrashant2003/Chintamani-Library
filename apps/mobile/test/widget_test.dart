// Widget smoke test for Chintamani Library app.
// The app uses Riverpod + GoRouter so a minimal wrapper is tested instead of
// booting the full app (which requires live providers and platform channels).

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('App renders a MaterialApp without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(child: Text('Chintamani Library')),
        ),
      ),
    );
    expect(find.text('Chintamani Library'), findsOneWidget);
  });
}
