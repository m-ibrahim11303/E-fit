import 'package:flutter/material.dart';
import 'pedometer_service.dart';
import 'diet_screen.dart';
import 'exercise_screen.dart';
import 'settings_screen.dart';
import 'forum_screen.dart';

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
class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _steps = '0';
  String _status = 'Unknown';
  late PedometerService pedometerService;

  @override
  void initState() {
    super.initState();
    pedometerService = PedometerService(
      onStatusChanged: (status) {
        setState(() {
          _status = status;
        });
      },
      onStepsChanged: (steps) {
        setState(() {
          _steps = steps;
        });
      },
    );

    pedometerService.initPedometer();
  }

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
                  onPressed: () => Navigator.push(
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

            // Step Counter Section
            Card(
              margin: EdgeInsets.symmetric(horizontal: 20),
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  children: [
                    Text(
                      'Steps Taken',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    Text(
                      _steps,
                      style: TextStyle(fontSize: 50, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Pedestrian Status',
                      style: TextStyle(fontSize: 18),
                    ),
                    SizedBox(height: 10),
                    Icon(
                      _status == 'walking'
                          ? Icons.directions_walk
                          : _status == 'stopped'
                              ? Icons.accessibility_new
                              : Icons.error,
                      size: 60,
                    ),
                    Text(
                      _status,
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 30),

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
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => ExercisesScreen()),
                      ),
                    ),
                    SizedBox(height: 16),
                    _CustomButton(
                      icon: Icons.restaurant,
                      label: 'Diet',
                      color: Colors.green.shade400,
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => DietScreen()),
                      ),
                    ),
                    SizedBox(height: 16),
                    _CustomButton(
                      icon: Icons.analytics,
                      label: 'Analytics',
                      color: Colors.blue.shade400,
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => ForumScreen()),
                      ),
                    ),
                    SizedBox(height: 16),
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
              colors: [color.withOpacity(0.8), color],
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
