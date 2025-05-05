import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter/material.dart'; // 👈 This is the missing import
import 'package:login_signup_1/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets("Bootup flow test from Page 1 to Page 4",
      (WidgetTester tester) async {
    app.main();
    await tester.pumpAndSettle();

    // Bootup Page 1 - Tap "Get Started" button
    final getStartedButton = find.text('Get Started');
    expect(getStartedButton, findsOneWidget);
    await tester.tap(getStartedButton);
    await tester.pumpAndSettle();

    // Bootup Page 2 - Tap circular button with arrow icon
    final page2Button = find.byType(ElevatedButton).first;
    expect(page2Button, findsOneWidget);
    await tester.tap(page2Button);
    await tester.pumpAndSettle();

    // Bootup Page 3 - Tap circular button with arrow icon
    final page3Button = find.byType(ElevatedButton).first;
    expect(page3Button, findsOneWidget);
    await tester.tap(page3Button);
    await tester.pumpAndSettle();

    // Bootup Page 4 - Tap circular button with arrow icon
    final page4Button = find.byType(ElevatedButton).first;
    expect(page4Button, findsOneWidget);
    await tester.tap(page4Button);
    await tester.pumpAndSettle();

    // Final Page (LoginSignupPage1) should now be loaded
    // Replace this with an actual unique widget or text from LoginSignupPage1
    expect(find.textContaining('Login'), findsOneWidget);
  });
}
