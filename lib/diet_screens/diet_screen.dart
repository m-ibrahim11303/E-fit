import 'package:flutter/material.dart';
import 'water_screen.dart';
import 'food_screen.dart';

// Diet screen

class DietScreen extends StatefulWidget {
  @override
  _DietScreenState createState() => _DietScreenState();
}

class _DietScreenState extends State<DietScreen> {
  double waterIntake = 0; // in ml
  double proteinIntake = 0; // in grams
  double caloriesIntake = 0; // in kcal

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Diet Tracker'),
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20,
        ),
        flexibleSpace: Container(
          color: Color(0xFF562634),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.amber[50]!, Colors.red[50]!],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Daily Intake Summary
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _IntakeStat(
                      icon: Icons.water_drop,
                      value: waterIntake,
                      unit: 'ml',
                      label: 'Water Intake',
                      color: Colors.blue[200]!,
                    ),
                    Divider(height: 30),
                    _IntakeStat(
                      icon: Icons.fitness_center,
                      value: proteinIntake,
                      unit: 'g',
                      label: 'Protein Intake',
                      color: Colors.green[400]!,
                    ),
                    Divider(height: 30),
                    _IntakeStat(
                      icon: Icons.local_fire_department,
                      value: caloriesIntake,
                      unit: 'kcal',
                      label: 'Calories',
                      color: Colors.orange[400]!,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 30),
              // Logging Buttons
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _DietButton(
                      icon: Icons.restaurant,
                      label: 'Log Meal',
                      color: Color(0xFF562634), // Solid color instead of gradient
                      onPressed: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => MealLogScreen()),
                        );
                        if (result != null) {
                          setState(() {
                            caloriesIntake += result['calories'];
                            proteinIntake += result['protein'];
                          });
                        }
                      },
                    ),
                    SizedBox(height: 30),
                    _DietButton(
                      icon: Icons.local_drink,
                      label: 'Log Drink',
                      color: Color(0xFF562634),
                      onPressed: () async {
                        final water = await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => DrinkLogScreen()),
                        );
                        if (water != null) {
                          setState(() {
                            waterIntake += water;
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _IntakeStat extends StatelessWidget {
  final IconData icon;
  final double value;
  final String unit;
  final String label;
  final Color color;

  const _IntakeStat({
    required this.icon,
    required this.value,
    required this.unit,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 32, color: color),
        SizedBox(width: 15),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            Text(
              '${value.toStringAsFixed(0)}$unit',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// Add this widget class in the same file (outside DietScreen class)
class _DietButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onPressed;

  const _DietButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 4,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: color,
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onPressed,
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 20, horizontal: 30),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 32, color: Colors.white),
                SizedBox(width: 15),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

