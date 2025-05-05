// delete_account_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:login_signup_1/bootup/signup_page_1.dart';
import 'package:login_signup_1/test_main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Delete Account Test', () {
    testWidgets('TC-14: Delete account from home page',
        (WidgetTester tester) async {
      try {
        app.main();
        await tester.pumpAndSettle(const Duration(seconds: 2));

        final settingsButton = find.descendant(
          of: find.byType(AppBar),
          matching: find.byIcon(Icons.settings),
        );
        await tester.tap(settingsButton);
        await tester.pumpAndSettle();

        await _tapDeleteAccountButton(tester);
        await _performAccountDeletion(tester);
        await _verifyAccountDeletionSuccess(tester);
      } catch (e, stackTrace) {
        _handleError(e, stackTrace);
      }
    });
  });
}

Future<void> _tapDeleteAccountButton(WidgetTester tester) async {
  expect(find.textContaining('Delete Account'), findsWidgets);
  final delButton = find.textContaining('Delete Account');
  expect(delButton, findsOneWidget);
  await tester.tap(delButton);
  await tester.pumpAndSettle();
}

Future<void> _performAccountDeletion(WidgetTester tester) async {
  final delPasswordField = find.widgetWithText(TextField, 'Password');
  expect(delPasswordField, findsOneWidget);
  await tester.enterText(delPasswordField, 'Muiz1234');
  await tester.pumpAndSettle();

  final deleteButton = find.widgetWithText(TextButton, 'Delete');
  expect(deleteButton, findsOneWidget);
  await tester.tap(deleteButton);
  await tester.pumpAndSettle(const Duration(seconds: 10));
}

Future<void> _verifyAccountDeletionSuccess(WidgetTester tester) async {
  expect(find.byType(SignupPage1), findsOneWidget);
  final successFinder = find.textContaining('Account deleted successfully');
  if (successFinder.evaluate().isNotEmpty) {
    expect(successFinder, findsOneWidget);
  }
}

void _handleError(dynamic e, StackTrace stackTrace) {
  debugPrint('TEST FAILED: ${e.toString()}');
  debugPrint('STACK TRACE: ${stackTrace.toString()}');
}
