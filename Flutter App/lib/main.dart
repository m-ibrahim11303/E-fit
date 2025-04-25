import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // Add secure storage
import 'bootup/bootup_page_1.dart'; // Import the BootupPage1 widget
import 'home_page.dart'; // Import the HomeScreen widget

// Global secure storage instance
final FlutterSecureStorage storage = FlutterSecureStorage();

void main() async {
  // Ensure that Flutter bindings are initialized for async operations
  WidgetsFlutterBinding.ensureInitialized();

  // Check if email exists in secure storage
  final String? email = await storage.read(key: 'email');

  // Run the app with conditional initial route
  runApp(MyApp(initialRoute: email != null));
}

class MyApp extends StatelessWidget {
  final bool initialRoute; // True if email exists, false otherwise

  const MyApp({Key? key, required this.initialRoute}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: initialRoute ? HomeScreen() : const BootupPage1(),
    );
  }
}
