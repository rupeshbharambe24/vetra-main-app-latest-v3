// test/analyze_flow_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vetra_app/main_ui.dart';

void main() {
  testWidgets('App loads and VETRA Home displays', (tester) async {
    // Load the Neon UI app
    await tester.pumpWidget(const VetraNeonApp());

    // Wait for animations & routing
    await tester.pumpAndSettle();

    // Check if "VETRA" appears anywhere on screen
    expect(find.textContaining('VETRA'), findsWidgets);
  });
}
