import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter/material.dart';
import 'package:login_signup_1/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Forum Post Flow', () {
    testWidgets('User can post in forum and remain on screen',
        (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      expect(find.textContaining('Forums'), findsWidgets);
      final forumButton = find.textContaining('Forums');
      expect(forumButton, findsOneWidget);
      await tester.tap(forumButton);
      await tester.pumpAndSettle();

      final forumField = find.byWidgetPredicate(
        (widget) =>
            widget is TextField &&
            widget.decoration?.hintText == 'Share your thoughts...',
      );
      await tester.enterText(forumField, 'hehe haha');

      expect(find.textContaining('Post'), findsWidgets);
      final postButton = find.textContaining('Post');
      expect(postButton, findsOneWidget);
      await tester.tap(postButton);
      await tester.pumpAndSettle();

      final stopwatch = Stopwatch()..start();
      while (stopwatch.elapsed < Duration(seconds: 10)) {
        await tester.pump(Duration(milliseconds: 100));
      }

      await tester.pageBack();
      await tester.pumpAndSettle(Duration(seconds: 2));
    });
  });
}
