import 'dart:math'; // Keep if you plan to use Random elsewhere
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// Ensure these paths are correct for your project structure
import 'bootup/bootup_page_1.dart'; // Assuming this is your initial setup page
import 'home_page.dart'; // Assuming this is your main content page
import 'notification_service.dart';

// Global secure storage instance
final FlutterSecureStorage storage = FlutterSecureStorage();
// Global notification service instance
final NotificationService notificationService = NotificationService();

void main() async {
  // MUST be the first line in main
  WidgetsFlutterBinding.ensureInitialized();
  print('[main.dart] Starting main function...');

  try {
    // 1. Initialize notification service
    print('[main.dart] Initializing notification service...');
    await notificationService
        .init(); // Initializes plugin, timezone, requests permissions
    print('[main.dart] Notification service initialized.');

    // 2. IMMEDIATE TEST NOTIFICATION (Using showCustomNotification)
    print('[main.dart] Triggering immediate test notification...');
    await notificationService.showCustomNotification(
        'Test Notification', // Title for the test
        'This is an immediate test!', // Body for the test
        1 // Unique ID for this test notification
        );
    print('[main.dart] Immediate test notification call completed.');

    // 3. Check and Request Exact Alarm Permission (for scheduled notifications)
    // This is crucial for reliable timed notifications on Android 12+
    print('[main.dart] Checking exact alarm permission...');
    final bool canScheduleExact =
        await notificationService.canScheduleExactAlarms();
    print('[main.dart] Can schedule exact alarms initially: $canScheduleExact');
    if (!canScheduleExact) {
      print('[main.dart] Requesting exact alarm permission...');
      // This will likely open a system settings page for the user on Android
      await notificationService.requestExactAlarmPermission();
      // Note: The permission might not be granted immediately after this call.
      // The user needs to interact with the system setting.
    }

    // 4. Schedule the Daily 8 AM Notification
    print('[main.dart] Scheduling daily 8 AM motivation...');
    // This uses ID 0 internally as defined in NotificationService
    await notificationService.scheduleDailyMotivation();
    print('[main.dart] Daily 8 AM motivation scheduling initiated.');

    // --- Optional: You can comment these out if not needed for testing ---
    // print('[main.dart] Scheduling one-time motivation (in 1 min)...');
    // await notificationService.scheduleOneTimeMotivation(); // Uses ID 2 internally
    // print('[main.dart] One-time motivation scheduled.');
    // --- End Optional Section ---

    // 5. Check User Login Status (Example using secure storage)
    print('[main.dart] Reading email from secure storage...');
    final String? email = await storage.read(key: 'email');
    print('[main.dart] Email read: $email');
    final bool isLoggedIn = email != null; // Determine if user is logged in

    // 6. Run the Flutter App UI
    print('[main.dart] Starting app UI...');
    runApp(MyApp(isLoggedIn: isLoggedIn));
  } catch (e, stackTrace) {
    print('[main.dart] FATAL Error during initialization: $e');
    print('[main.dart] Stack trace: $stackTrace');
    // Fallback in case of a critical error during setup
    // Consider showing a dedicated error screen instead of just BootupPage1
    runApp(MyApp(isLoggedIn: false)); // Default to logged-out state on error
  }
}

class MyApp extends StatelessWidget {
  // Renamed parameter for clarity
  final bool isLoggedIn;

  const MyApp({Key? key, required this.isLoggedIn}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fitness App', // Add a title
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // Optional: Define a basic theme
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      // Use the isLoggedIn flag to determine the initial screen
      home: isLoggedIn ? HomeScreen() : const BootupPage1(),
      // Consider using named routes for larger applications:
      // initialRoute: isLoggedIn ? '/home' : '/bootup',
      // routes: {
      //   '/home': (context) => HomeScreen(),
      //   '/bootup': (context) => const BootupPage1(),
      //   // Add other routes here
      // },
    );
  }
}

// --- Placeholder Widgets (Replace with your actual imports/widgets) ---
// Ensure you have these files/widgets created and imported correctly

// class HomeScreen extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Home')),
//       body: Center(child: Text('Welcome Home!')),
//     );
//   }
// }

// class BootupPage1 extends StatelessWidget {
//   const BootupPage1({Key? key}) : super(key: key);
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Setup')),
//       body: Center(child: Text('Initial Setup / Login Screen')),
//     );
//   }
// }
