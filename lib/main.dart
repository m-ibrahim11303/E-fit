import 'package:flutter/material.dart';
import 'diet_screen.dart';
import 'exercise_screen.dart';
import 'settings_screen.dart';

void main() {
  runApp(FitnessApp());
}

class FitnessApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fitness App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: HomeScreen(),
    );
  }
}

// Home screen
class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.red.shade900, Colors.deepOrange.shade300],
          ),
        ),
        child: Column(
          children: [
            // App Bar with Settings Button
            Padding(
              padding: EdgeInsets.only(top: 40, right: 20),
              child: Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  icon: Icon(Icons.settings, size: 30, color: Colors.white),
                  onPressed:
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => SettingsScreen()),
                      ),
                ),
              ),
            ),
            SizedBox(height: 20),
            // App Title
            Text(
              'E-fit',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 40),
            // Scrollable Buttons
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    _CustomButton(
                      icon: Icons.fitness_center,
                      label: 'Exercises',
                      color: Colors.orange.shade400,
                      onPressed:
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ExercisesScreen(),
                            ),
                          ),
                    ),
                    SizedBox(height: 16),
                    _CustomButton(
                      icon: Icons.restaurant,
                      label: 'Diet',
                      color: Colors.green.shade400,
                      onPressed:
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => DietScreen()),
                          ),
                    ),
                    SizedBox(height: 16),
                    _CustomButton(
                      icon: Icons.analytics,
                      label: 'Analytics',
                      color: Colors.blue.shade400,
                      onPressed:
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => AnalyticsScreen(),
                            ),
                          ),
                    ),
                    SizedBox(height: 16),
                    _CustomButton(
                      icon: Icons.forum,
                      label: 'Forums',
                      color: Colors.teal.shade400,
                      onPressed:
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => ForumScreen()),
                          ),
                    ),
                    SizedBox(height: 16), // Add bottom padding
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

// Custom Button Widget
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
          width: double.infinity, // Make buttons full width
          padding: EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [color.withValues(), color],
            ),
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

// Forum screen
class ForumScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Forums')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.forum, size: 60, color: Colors.grey),
            SizedBox(height: 20),
            Text(
              'Forum Feature (Placeholder)',
              style: TextStyle(fontSize: 20, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

