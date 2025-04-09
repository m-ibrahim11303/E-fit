import 'package:flutter/material.dart';
import 'diet_screens/diet_screen.dart';
import 'exercise_screens/exercise_screen.dart';
import 'settings_screen.dart';
import 'forum_screen.dart';
import 'analytics_screen.dart';

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

class HomeScreen extends StatelessWidget {
  final String imageAsset = 'assets/logo.png';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Top Section with Curved Image (50% height)
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
          // Bottom Section with 2x2 Grid Buttons
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

// Custom Button Widget (keep the same as original)
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}
