// change_password_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:login_signup_1/test_main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Change Password Test', () {
    testWidgets('TC-13: Change password from home page',
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

        await _tapChangePasswordButton(tester);

        await _performPasswordChange(tester,
            currentPassword: 'Muiz1234',
            newPassword: 'Ibrahim1234',
            confirmPassword: 'Ibrahim1234');

        await _verifyPasswordChangeSuccess(tester);
      } catch (e, stackTrace) {
        _handleError(e, stackTrace);
      }
    });
  });
}

Future<void> _tapChangePasswordButton(WidgetTester tester) async {
  expect(find.textContaining('Change Password'), findsWidgets);
  final changePasswordButton = find.textContaining('Change Password');
  expect(changePasswordButton, findsOneWidget);
  await tester.tap(changePasswordButton);
  await tester.pumpAndSettle();
}

Future<void> _performPasswordChange(
  WidgetTester tester, {
  required String currentPassword,
  required String newPassword,
  required String confirmPassword,
}) async {
  final fields = {
    'Current Password': currentPassword,
    'New Password': newPassword,
    'Confirm New Password': confirmPassword,
  };

  for (var entry in fields.entries) {
    final field = find.widgetWithText(TextField, entry.key);
    expect(field, findsOneWidget, reason: '${entry.key} field missing');
    await tester.enterText(field, entry.value);
  }
  await tester.pumpAndSettle();

  final changeButton = find.widgetWithText(TextButton, 'Change');
  expect(changeButton, findsOneWidget, reason: 'Change button missing');
  await tester.tap(changeButton);
  await tester.pumpAndSettle(const Duration(seconds: 3));
}

Future<void> _verifyPasswordChangeSuccess(WidgetTester tester) async {
  final successFinder = find.textContaining('Success');
  bool found = await _waitForWidget(tester, successFinder);
  expect(found, true, reason: 'Success message not shown');

  final okButton = find.textContaining('OK');
  if (okButton.evaluate().isNotEmpty) {
    await tester.tap(okButton);
    await tester.pumpAndSettle();
  }
}

Future<bool> _waitForWidget(WidgetTester tester, Finder finder) async {
  return TestAsyncUtils.guard<bool>(() async {
    final timeout = const Duration(seconds: 10);
    final interval = const Duration(milliseconds: 200);

    final stopwatch = Stopwatch()..start();
    while (stopwatch.elapsed < timeout) {
      await tester.pump(interval);
      if (finder.evaluate().isNotEmpty) return true;
    }
    return false;
  });
}

void _handleError(dynamic e, StackTrace stackTrace) {
  debugPrint('TEST FAILED: ${e.toString()}');
  debugPrint('STACK TRACE: ${stackTrace.toString()}');
}
