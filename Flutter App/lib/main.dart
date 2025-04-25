import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'bootup/bootup_page_1.dart';
import 'home_page.dart';

final FlutterSecureStorage storage = FlutterSecureStorage();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final String? email = await storage.read(key: 'email');

  runApp(MyApp(initialRoute: email != null));
}

class MyApp extends StatelessWidget {
  final bool initialRoute;

  const MyApp({Key? key, required this.initialRoute}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: initialRoute ? HomeScreen() : const BootupPage1(),
    );
  }
}
