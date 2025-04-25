import 'package:flutter/material.dart';
import 'diet_screens/diet_screen.dart';
import 'exercise_screens/exercise_screen.dart';
import 'settings_screens/settings_screen.dart';
import 'forum_screen.dart';
import 'analytics_screen.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'bootup/login_signup_page_1.dart';

final FlutterSecureStorage storage = FlutterSecureStorage();

void main() {
  runApp(FitnessApp());
}

class FitnessApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final String imageAsset = 'assets/images/home_page_logo.png';
  String? _userEmail;

  @override
  void initState() {
    super.initState();
    _fetchEmail();
  }

  Future<void> _fetchEmail() async {
    final String? email = await storage.read(key: 'email');
    setState(() {
      _userEmail = email ?? 'No email found';
    });
  }

  void _handleLogout() async {
    await storage.delete(key: 'email');
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => LoginSignupPage1()),
      (route) => false,
    );
  }

  void _openSettings() {
    final email = _userEmail ?? 'No email available';
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => SettingsScreen(email: email)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.settings, color: Colors.black),
          onPressed: _openSettings,
          tooltip: 'Settings',
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: Colors.black),
            onPressed: _handleLogout,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            flex: 1,
            child: ClipPath(
              clipper: _CurvedClipper(),
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
                child: Image.asset(
                  imageAsset,
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 20,
                crossAxisSpacing: 20,
                childAspectRatio: 1.2,
                children: [
                  _CustomButton(
                    icon: Icons.fitness_center,
                    label: 'Exercises',
                    color: const Color(0xFF562634),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => ExercisesScreen()),
                    ),
                  ),
                  _CustomButton(
                    icon: Icons.restaurant,
                    label: 'Diet',
                    color: const Color(0xFF562634),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => DietScreen()),
                    ),
                  ),
                  _CustomButton(
                    icon: Icons.analytics,
                    label: 'Analytics',
                    color: const Color(0xFF562634),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => AnalyticsScreen()),
                    ),
                  ),
                  _CustomButton(
                    icon: Icons.forum,
                    label: 'Forums',
                    color: const Color(0xFF562634),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => ForumScreen()),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CurvedClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.moveTo(0, 0);
    path.lineTo(0, size.height - 100);
    path.quadraticBezierTo(
      size.width * 0.25,
      size.height,
      size.width * 0.5,
      size.height - 50,
    );
    path.quadraticBezierTo(
      size.width * 0.75,
      size.height - 100,
      size.width,
      size.height - 50,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class _CustomButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onPressed;

  const _CustomButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onPressed,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: color,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 30, color: Colors.white),
              const SizedBox(height: 10),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
