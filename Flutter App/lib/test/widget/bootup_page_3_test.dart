// bootup_page_3_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:login_signup_1/bootup/bootup_page_3.dart';
import 'package:login_signup_1/bootup/bootup_page_4.dart';
import 'package:login_signup_1/style.dart';

void main() {
  group('BootupPage3 Tests', () {
    testWidgets('Displays "Track Your Movement" text and description',
        (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(home: BootupPage3()));
      await tester.pumpAndSettle();

      // Check for DefaultTextStyle
      expect(
          find.byWidgetPredicate((widget) =>
              widget is DefaultTextStyle &&
              widget.style == jerseyStyle(48, Color(0xFFFFFFFF)) &&
              widget.child is Text &&
              (widget.child as Text).data == 'Track Your Movement' &&
              (widget.child as Text).textAlign == TextAlign.center),
          findsOneWidget);

      expect(
          find.byWidgetPredicate((widget) =>
              widget is DefaultTextStyle &&
              widget.style == jerseyStyle(24, Color(0xFFFFFFFF)) &&
              widget.child is Text &&
              (widget.child as Text).data ==
                  'Track your workouts & physical activity and get custom AI recommendations based on your personal goals' &&
              (widget.child as Text).textAlign == TextAlign.center),
          findsOneWidget);
    });

    testWidgets('Displays the right arrow button', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(home: BootupPage3()));
      await tester.pumpAndSettle();

      expect(find.byType(ElevatedButton), findsOneWidget);

      expect(
          find.descendant(
            of: find.byType(ElevatedButton),
            matching: find.byType(Image),
          ),
          findsOneWidget);
    });

    testWidgets('Right arrow button navigates to BootupPage4',
        (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(home: BootupPage3()));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      expect(find.widgetWithText(Text, 'Discussion Forum'), findsOneWidget);
    });
  });
}
