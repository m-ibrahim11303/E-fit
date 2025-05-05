// import 'package:flutter/material.dart';
// import 'package:flutter_test/flutter_test.dart';
// import 'package:integration_test/integration_test.dart';
// import 'package:login_signup_1/test_main.dart' as app;

// void main() {
//   IntegrationTestWidgetsFlutterBinding.ensureInitialized();

//   testWidgets("Bootup flow test from Page 1 to Page 4",
//       (WidgetTester tester) async {
//     app.main();
//     await tester
//         .pumpAndSettle(const Duration(seconds: 2)); // Wait for UI to settle

//     final getStartedButton = find.text('Get Started');
//     expect(getStartedButton, findsOneWidget);
//     await tester.tap(getStartedButton);
//     await tester.pumpAndSettle();

//     // final page2Button = find.byType(ElevatedButton).first;
//     // await tester.ensureVisible(find.byType(ElevatedButton));
//     // await tester.tap(find.byType(ElevatedButton));
//     // await tester.pumpAndSettle();
//     // await tester.pumpAndSettle();
//     // expect(find.text('Track Your Diet'), findsOneWidget);
//     // final button2 = find.widgetWithText(ElevatedButton, 'Continue').first;
//     // await tester.tap(button2);
//     // await tester.pumpAndSettle();
//     expect(find.text('Track Your Diet'), findsOneWidget);
//     final button2 = find.byKey(Key('bootupPage2NextButton'));
//     expect(button2, findsOneWidget);
//     await tester.tap(button2);
//     await tester.pumpAndSettle();

//     expect(find.text('Track Your Movement'), findsOneWidget);
//     final button3 = find.byKey(Key('bootupPage3NextButton'));
//     expect(button3, findsOneWidget);
//     await tester.tap(button3);
//     await tester.pumpAndSettle();

//     expect(find.text('Discussion Forum'), findsOneWidget);
//     final button4 = find.byKey(Key('bootupPage4NextButton'));
//     expect(button4, findsOneWidget);
//     await tester.tap(button4);
//     await tester.pumpAndSettle();

//     expect(find.textContaining('Log in'), findsWidgets); // Adjust as needed
//     final button5 = find.byKey(Key('log_in_button'));
//     expect(button5, findsOneWidget);
//     await tester.tap(button5);
//     await tester.pumpAndSettle();

//     // expect(find.textContaining('Forgot password'), findsWidgets);
//     // await tester.pageBack(); // Simulates physical back button on Android
//     // await tester.pumpAndSettle();

//     // expect(find.textContaining('Sign up'), findsWidgets); // Adjust as needed
//     // final button6 = find.byKey(Key('sign_up_button'));
//     // expect(button6, findsOneWidget);
//     // await tester.tap(button6);
//     // await tester.pumpAndSettle();

//     // Validate email error is shown
//     expect(find.textContaining('Email cannot be empty'), findsWidgets);

// // Enter email
//     final emailField = find.byKey(Key('email_input_field'));
//     expect(emailField, findsOneWidget);
//     await tester.enterText(emailField, '26100004@lums.edu.pk');
//     await tester.pumpAndSettle();

// // Enter password
//     final passwordField = find.byKey(Key('password_input_field'));
//     expect(passwordField, findsOneWidget);
//     await tester.enterText(passwordField, 'Fatim123');
//     await tester.pumpAndSettle();

// // Tap login button
//     final button7 = find.byKey(Key('log_in_button'));
//     expect(button7, findsOneWidget);
//     await tester.ensureVisible(button7);
//     await tester.pump(const Duration(milliseconds: 300)); // wait before tap
//     await tester.tap(button7);
//     await tester.pumpAndSettle();

// // Expect success dialog
//     expect(find.textContaining('Success'), findsWidgets);

// // Tap OK
//     final button8 = find.byKey(Key('ok_button'));
//     expect(button8, findsOneWidget);
//     await tester.tap(button8);
//     await tester.pumpAndSettle();

// // Navigate to Exercises screen
//     expect(find.textContaining('Exercises'), findsWidgets);

//     final button9 = find.byKey(Key('exercises_button'));
//     expect(button9, findsOneWidget);
//     await tester.tap(button9);
//     await tester.pumpAndSettle();

//     expect(find.textContaining('Fitness Journey'), findsWidgets);

//     final LogExerciseButton = find.text('Log Exercises');
//     await tester.tap(LogExerciseButton);
//     await tester.pumpAndSettle();

//     // await tester.pumpAndSettle();

//     // Tap the first exercise card
//     final exerciseButton = find.text('Running');
//     await tester.tap(exerciseButton);
//     await tester.pumpAndSettle();

//     // Tap the "3 sets" button
//     final set3ButtonFinder = find.widgetWithText(ElevatedButton, '3');
//     expect(set3ButtonFinder, findsOneWidget);
//     await tester.tap(set3ButtonFinder);
//     await tester.pumpAndSettle();

//     // Enter values in the 3 fields
//     final textFields = find.byType(TextField);
//     expect(textFields, findsAtLeastNWidgets(3));
//     await tester.enterText(textFields.at(0), '500');
//     await tester.enterText(textFields.at(1), '400');
//     await tester.enterText(textFields.at(2), '300');

//     await tester.pumpAndSettle();

//     // Tap the "Add Workout" button
//     final addWorkoutButton = find.widgetWithText(ElevatedButton, 'Add Workout');
//     expect(addWorkoutButton, findsOneWidget);
//     await tester.tap(addWorkoutButton);
//     await tester.pumpAndSettle();
//   });
// }
