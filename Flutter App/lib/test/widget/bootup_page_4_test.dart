// bootup_page_4_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:login_signup_1/bootup/bootup_page_4.dart';
import 'package:login_signup_1/bootup/login_signup_page_1.dart';
import 'package:login_signup_1/style.dart';

void main() {
  group('BootupPage4 Tests', () {
    testWidgets('Displays "Discussion Forum" text and description',
        (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(home: BootupPage4()));
      await tester.pumpAndSettle();

      // Check for DefaultTextStyle
      expect(
          find.byWidgetPredicate((widget) =>
              widget is DefaultTextStyle &&
              widget.style == jerseyStyle(48, Color(0xFFFFFFFF)) &&
              widget.child is Text &&
              (widget.child as Text).data == 'Discussion Forum' &&
              (widget.child as Text).textAlign == TextAlign.center),
          findsOneWidget);

      expect(
          find.byWidgetPredicate((widget) =>
              widget is DefaultTextStyle &&
              widget.style == jerseyStyle(24, Color(0xFFFFFFFF)) &&
              widget.child is Text &&
              (widget.child as Text).data ==
                  'A community space for you to share experiences, ask questions, and engage with others.' &&
              (widget.child as Text).textAlign == TextAlign.center),
          findsOneWidget);
    });

    testWidgets('Displays the right arrow button', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(home: BootupPage4()));
      await tester.pumpAndSettle();

      expect(find.byType(ElevatedButton), findsOneWidget);

      expect(
          find.descendant(
            of: find.byType(ElevatedButton),
            matching: find.byType(Image),
          ),
          findsOneWidget);
    });

    testWidgets('Right arrow button navigates to LoginSignupPage1',
        (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(home: BootupPage4()));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      // Check for a unique Widget from LoginSignupPage1
      expect(find.text('Create Account'), findsOneWidget);
    });
  });
}
