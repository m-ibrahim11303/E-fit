// bootup_page_1_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:login_signup_1/bootup/bootup_page_1.dart';
import 'package:login_signup_1/bootup/bootup_page_2.dart';
import 'package:login_signup_1/style.dart';

void main() {
  group('BootupPage1 Tests', () {
    testWidgets(
        'Displays U-Fit text, motivational quote, and "Get Started" button',
        (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(home: BootupPage1()));
      await tester.pumpAndSettle();

      expect(find.text('U-Fit'), findsOneWidget);

      // Verify that a motivational quote is present with the correct DefaultTextStyle
      expect(
          find.byWidgetPredicate((widget) =>
              widget is DefaultTextStyle &&
              widget.style == jerseyStyle(20) &&
              widget.child is Text &&
              (widget.child as Text).textAlign == TextAlign.center),
          findsOneWidget);

      expect(
          find.widgetWithText(ElevatedButton, 'Get Started'), findsOneWidget);
    });

    testWidgets('Button navigates to BootupPage2', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(home: BootupPage1()));
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(ElevatedButton, 'Get Started'));
      await tester.pumpAndSettle();

      expect(find.widgetWithText(Text, 'Track Your Diet'), findsOneWidget);
    });
  });
}
