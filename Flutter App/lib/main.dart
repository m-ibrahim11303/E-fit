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
  final List<String> imageUrls = [
    'https://example.com/top-image1.jpg',
    'https://example.com/top-image2.jpg',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.white,
        child: Column(
          children: [
            // Top Section with Vertical Images
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    // App Bar
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: Icon(Icons.settings, size: 30, color: Colors.black),
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => SettingsScreen()),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    // Vertical Image Stack
                    Expanded(
                      child: Column(
                        children: [
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 8.0),
                              child: Image.network(
                                imageUrls[0],
                                fit: BoxFit.cover,
                                loadingBuilder: (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Center(child: CircularProgressIndicator());
                                },
                              ),
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 8.0),
                              child: Image.network(
                                imageUrls[1],
                                fit: BoxFit.cover,
                                loadingBuilder: (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Center(child: CircularProgressIndicator());
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Bottom Section with 2x2 Grid Buttons
            Expanded(
              flex: 3,
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
                      color: Color(0xFF562634),
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => ExercisesScreen()),
                      ),
                    ),
                    _CustomButton(
                      icon: Icons.restaurant,
                      label: 'Diet',
                      color: Color(0xFF562634),
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => DietScreen()),
                      ),
                    ),
                    _CustomButton(
                      icon: Icons.analytics,
                      label: 'Analytics',
                      color: Color(0xFF562634),
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => AnalyticsScreen()),
                      ),
                    ),
                    _CustomButton(
                      icon: Icons.forum,
                      label: 'Forums',
                      color: Color(0xFF562634),
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
      ),
    );
  }
}

// Custom Button Widget (updated for grid layout)
class _CustomButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onPressed;

  _CustomButton({
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
              SizedBox(height: 10),
              Text(
                label,
                style: TextStyle(
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