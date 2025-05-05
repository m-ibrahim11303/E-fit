import 'package:flutter/material.dart';
import 'package:login_signup_1/style.dart';
import 'diet_screens/diet_screen.dart';
import 'exercise_screens/exercise_screen.dart';
import 'settings_screens/settings_screen.dart';
import 'forum_screen.dart';
import 'analytics_screens/analytics_screen.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'bootup/login_signup_page_1.dart';
import 'dart:math';

final FlutterSecureStorage storage = FlutterSecureStorage();

void main() {
  runApp(const FitnessApp());
}

class FitnessApp extends StatelessWidget {
  const FitnessApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

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
    if (mounted) {
      setState(() {
        _userEmail = email ?? 'No email found';
      });
    }
  }

  void _getRandomQuote() {
    setState(() {
      selectedQuote =
          motivationalQuotes[Random().nextInt(motivationalQuotes.length)];
    });
  }

  void _handleLogout() async {
    await storage.delete(key: 'email');
    if (!mounted) return;
    slideTo(context, LoginSignupPage1());
    // Navigator.pushAndRemoveUntil(
    //   context,
    //   MaterialPageRoute(builder: (_) => const LoginSignupPage1()),
    //   (route) => false,
    // );
  }

  void _openSettings() {
    final email = _userEmail ?? 'No email available';
    slideTo(context, SettingsScreen(email: email));
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(builder: (_) => SettingsScreen(email: email)),
    // );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: brightWhite,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.settings, color: darkMaroon),
          onPressed: _openSettings,
          tooltip: 'Settings',
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: darkMaroon),
            onPressed: _handleLogout,
            tooltip: 'Logout',
          ),
        ],
      ),
      backgroundColor: brightWhite,
      body: Column(
        children: [
          Expanded(
            flex: 1,
            child: ClipPath(
              clipper: _CurvedClipper(),
              child: ClipRRect(
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
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  children: [
                    Text(
                      selectedQuote,
                      style: jerseyStyle(18, darkMaroon)
                          .copyWith(fontStyle: FontStyle.italic),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 15),
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      mainAxisSpacing: 15,
                      crossAxisSpacing: 15,
                      childAspectRatio: 1.3,
                      children: [
                        _CustomButton(
                          key: Key('exercises_button'),
                            icon: Icons.fitness_center,
                            label: 'Exercises',
                            color: darkMaroon,
                            onPressed: () {
                              if (!mounted) return;
                              slideTo(context, ExercisesScreen());
                              // Navigator.push(
                              //     context,
                              //     MaterialPageRoute(
                              //         builder: (_) => ExercisesScreen()));
                            }),
                        _CustomButton(
                          key: Key('diet_button'),
                            icon: Icons.restaurant,
                            label: 'Diet',
                            color: darkMaroon,
                            onPressed: () {
                              if (!mounted) return;
                              slideTo(context, DietScreen());
                              // Navigator.push(
                              //     context,
                              //     MaterialPageRoute(
                              //         builder: (_) => DietScreen()));
                            }),
                        _CustomButton(
                          key: Key("analytics_button"),
                            icon: Icons.analytics,
                            label: 'Analytics',
                            color: darkMaroon,
                            onPressed: () {
                              if (!mounted) return;
                              slideTo(context, AnalyticsScreen());
                              // Navigator.push(
                              //     context,
                              //     MaterialPageRoute(
                              //         builder: (_) => AnalyticsScreen()));
                            }),
                        _CustomButton(
                            icon: Icons.forum,
                            label: 'Forums',
                            color: darkMaroon,
                            onPressed: () {
                              if (!mounted) return;
                              slideTo(context, ForumScreen());
                              // Navigator.push(
                              //     context,
                              //     MaterialPageRoute(
                              //         builder: (_) => ForumScreen()));
                            }),
                      ],
                    ),
                    const SizedBox(height: 20),
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
    path.lineTo(0, size.height * 0.85);
    path.quadraticBezierTo(
        size.width / 2, size.height, size.width, size.height * 0.85);
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
    Key? key,
    required this.icon,
    required this.label,
    required this.color,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      color: color,
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: onPressed,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 32, color: brightWhite),
              const SizedBox(height: 8),
              Text(
                label,
                style: jerseyStyle(18, brightWhite),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
