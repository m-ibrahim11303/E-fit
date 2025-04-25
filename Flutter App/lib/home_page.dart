import 'package:flutter/material.dart';
import 'diet_screens/diet_screen.dart';
import 'exercise_screens/exercise_screen.dart';
import 'settings_screens/settings_screen.dart';
import 'forum_screen.dart';
import 'analytics_screen.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'bootup/login_signup_page_1.dart';
import 'dart:math';

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

  final List<String> motivationalQuotes = [
    "Every workout counts. Stay consistent.",
    "Small steps every day lead to big results.",
    "Energy and persistence conquer all things.",
    "You are one workout away from a good mood.",
    "Earn your body.",
  ];

  String selectedQuote = "";

  @override
  void initState() {
    super.initState();
    _fetchEmail();
    _getRandomQuote();
  }

  Future<void> _fetchEmail() async {
    final String? email = await storage.read(key: 'email');
    setState(() {
      _userEmail = email ?? 'No email found';
    });
  }

  void _getRandomQuote() {
    setState(() {
      selectedQuote =
          motivationalQuotes[Random().nextInt(motivationalQuotes.length)];
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
            child: SingleChildScrollView(
              // Added to prevent potential overflow if still too tight
              child: Padding(
                padding: const EdgeInsets.all(15.0), // Reduced padding
                child: Column(
                  children: [
                    Text(
                      selectedQuote,
                      style: TextStyle(
                        fontSize: 18, // Reduced font size
                        fontStyle: FontStyle.italic,
                        color: Colors.black54,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 15), // Reduced height
                    GridView.count(
                      shrinkWrap: true,
                      physics:
                          NeverScrollableScrollPhysics(), // Prevent grid scrolling inside SingleChildScrollView
                      crossAxisCount: 2,
                      mainAxisSpacing: 15, // Reduced spacing
                      crossAxisSpacing: 15, // Reduced spacing
                      childAspectRatio:
                          1.3, // Adjusted aspect ratio to make items shorter
                      children: [
                        _CustomButton(
                          icon: Icons.fitness_center,
                          label: 'Exercises',
                          color: const Color(0xFF562634),
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => ExercisesScreen()),
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
                            MaterialPageRoute(
                                builder: (_) => AnalyticsScreen()),
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
                  ],
                ),
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
              Icon(icon, size: 28, color: Colors.white), // Reduced icon size
              const SizedBox(height: 8), // Reduced height
              Text(
                label,
                style: const TextStyle(
                  fontSize: 16, // Reduced font size
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
