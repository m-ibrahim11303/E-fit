import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'water_screen.dart';
import 'food_screen.dart';
import 'package:login_signup_1/style.dart';

class DietScreen extends StatefulWidget {
  @override
  _DietScreenState createState() => _DietScreenState();
}

class _DietScreenState extends State<DietScreen> {
  double waterIntake = 0;
  double proteinIntake = 0;
  double caloriesIntake = 0;
  bool isLoading = true;
  final storage = FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    fetchTodayIntake();
  }

  Future<void> fetchTodayIntake() async {
    try {
      String? email = await storage.read(key: 'email');
      if (email == null) {
        print('No email found in secure storage');
        setState(() {
          isLoading = false;
        });
        return;
      }

      final response = await http.get(
        Uri.parse(
            'https://e-fit-backend.onrender.com/analytics/charts?email=$email'),
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['success'] == true) {
          final data = jsonData['data'] as List;

          double calories = 0;
          double protein = 0;
          double water = 0;

          for (var item in data) {
            int todayIndex = item['x_vals'].indexOf('Today');
            if (todayIndex != -1) {
              if (item['title'] == 'Calories') {
                calories = (item['y_vals'][todayIndex] as num).toDouble();
              } else if (item['title'] == 'Proteins') {
                protein = (item['y_vals'][todayIndex] as num).toDouble();
              } else if (item['title'] == 'Water Intake') {
                water = (item['y_vals'][todayIndex] as num).toDouble();
              }
            }
          }

          setState(() {
            caloriesIntake = calories;
            proteinIntake = protein;
            waterIntake = water;
            isLoading = false;
          });
        } else {
          print('API returned success: false');
          setState(() {
            isLoading = false;
          });
        }
      } else {
        print('Failed to fetch data: ${response.statusCode}');
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching data: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Diet Tracker'),
        titleTextStyle: jerseyStyle(20, brightWhite),
        //   color: Colors.white,
        //   fontSize: 20,
        // ),
        flexibleSpace: Container(
          color: darkMaroon,
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
                child: isLoading
                    ? Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          child: CircularProgressIndicator(),
                        ),
                      )
                    : Column(
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
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _DietButton(
                      icon: Icons.restaurant,
                      label: 'Log Meal',
                      color: darkMaroon,
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
                      color: darkMaroon,
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
              style: jerseyStyle(14, intakeStatGrey),
              // style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            Text(
              '${value.toStringAsFixed(0)}$unit',
              style: TextStyle(
                fontFamily: "Jersey 25",
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
                Icon(icon, size: 32, color: brightWhite),
                SizedBox(width: 15),
                Text(
                  label,
                  style: TextStyle(
                    fontFamily: "Jersey 25",
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: brightWhite,
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
