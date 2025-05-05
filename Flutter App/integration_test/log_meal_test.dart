import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:login_signup_1/test_main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets("Bootup flow test from Page 1 to Page 4",
      (WidgetTester tester) async {
    app.main();
    await tester
        .pumpAndSettle(const Duration(seconds: 2)); 

    final getStartedButton = find.text('Get Started');
    expect(getStartedButton, findsOneWidget);
    await tester.tap(getStartedButton);
    await tester.pumpAndSettle();

    expect(find.text('Track Your Diet'), findsOneWidget);
    final button2 = find.byKey(Key('bootupPage2NextButton'));
    expect(button2, findsOneWidget);
    await tester.tap(button2);
    await tester.pumpAndSettle();

    expect(find.text('Track Your Movement'), findsOneWidget);
    final button3 = find.byKey(Key('bootupPage3NextButton'));
    expect(button3, findsOneWidget);
    await tester.tap(button3);
    await tester.pumpAndSettle();

    expect(find.text('Discussion Forum'), findsOneWidget);
    final button4 = find.byKey(Key('bootupPage4NextButton'));
    expect(button4, findsOneWidget);
    await tester.tap(button4);
    await tester.pumpAndSettle();

    expect(find.textContaining('Log in'), findsWidgets); 
    final button5 = find.byKey(Key('log_in_button'));
    expect(button5, findsOneWidget);
    await tester.tap(button5);
    await tester.pumpAndSettle();

    // Validate email error is shown
    expect(find.textContaining('Email cannot be empty'), findsWidgets);

// Enter email
    final emailField = find.byKey(Key('email_input_field'));
    expect(emailField, findsOneWidget);
    await tester.enterText(emailField, '26100004@lums.edu.pk');
    await tester.pumpAndSettle();

// Enter password
    final passwordField = find.byKey(Key('password_input_field'));
    expect(passwordField, findsOneWidget);
    await tester.enterText(passwordField, 'Fatim123');
    await tester.pumpAndSettle();

// Tap login button
    final button7 = find.byKey(Key('log_in_button'));
    expect(button7, findsOneWidget);
    await tester.ensureVisible(button7);
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(button7);
    await tester.pumpAndSettle();

// Expect success dialog
    expect(find.textContaining('Success'), findsWidgets);

// Tap OK
    final button8 = find.byKey(Key('ok_button'));
    expect(button8, findsOneWidget);
    await tester.tap(button8);
    await tester.pumpAndSettle();

// Navigate to Exercises screen
    expect(find.textContaining('Diet'), findsWidgets);

    final button9 = find.byKey(Key('diet_button'));
    expect(button9, findsOneWidget);
    await tester.tap(button9);
    await tester.pumpAndSettle();

    expect(find.textContaining('Diet Tracker'), findsWidgets);

    final LogMealButton = find.text('Log Meal');
    await tester.tap(LogMealButton);
    await tester.pumpAndSettle();

    // Tap the first exercise card
    final PDCButton = find.text('PDC');
    await tester.tap(PDCButton);
    await tester.pumpAndSettle();

    // Tap on the first dish (Roti)
    final rotiTile = find.text('Roti');
    expect(rotiTile, findsOneWidget);
    await tester.tap(rotiTile);
    await tester.pumpAndSettle();

    // Enter values in the 3 fields
    final button10 = find.byKey(Key('add_dish_button'));
    expect(button10, findsOneWidget);
    await tester.tap(button10);
    await tester.pumpAndSettle();

    await tester.pumpAndSettle();

    // Tap the "Add Workout" button
    final saveAllItems = find.widgetWithText(ElevatedButton, 'Save All Items');
    expect(saveAllItems, findsOneWidget);
    await tester.tap(saveAllItems);
    await tester.pumpAndSettle();
  });
}
