import 'package:flutter/material.dart';
import 'start_journey.dart';
import 'continue_journey.dart';
import 'step_counter_screen.dart';
import 'dart:convert';

class ExercisesScreen extends StatefulWidget {
  @override
  _ExercisesScreenState createState() => _ExercisesScreenState();
}

class _ExercisesScreenState extends State<ExercisesScreen> {
  int _completedExercises = 12;
  final int _totalExercises = 25;
  int _stepsWalked = 8450;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Fitness Journey'),
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            color: Color(0xFF562634),
          ),
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
                child: Column(
                  children: [
                    _ProgressStat(
                      icon: Icons.check_circle,
                      value: '$_completedExercises/$_totalExercises',
                      label: 'Exercises Completed',
                      color: Color(0xFF562634),
                    ),
                    Divider(height: 30),
                    _ProgressStat(
                      icon: Icons.directions_walk,
                      value: '$_stepsWalked',
                      label: 'Steps Walked',
                      color: Color(0xFF562634),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 30),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _JourneyButton(
                      icon: Icons.flag,
                      label: 'Start New Journey',
                      color: Color(0xFF562634),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ExercisesListScreen(),
                          ),
                        );
                      },
                    ),
                    SizedBox(height: 30),
                    _JourneyButton(
                      icon: Icons.directions_run,
                      label: 'Continue Journey',
                      color: Color(0xFF562634),
                      onPressed: () {
                        final jsonData = jsonDecode(journeyJson);
                        final journey = ExerciseJourney.fromJson(jsonData);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                ActiveJourneyScreen(journey: journey),
                          ),
                        );
                      },
                    ),
                    SizedBox(height: 30),
                    _JourneyButton(
                      icon: Icons.directions_walk,
                      label: 'Step Counter',
                      color: Color(0xFF562634),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => StepCounterScreen(),
                          ),
                        );
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

class _ProgressStat extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _ProgressStat({
    required this.icon,
    required this.value,
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
              value,
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

class _JourneyButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onPressed;

  const _JourneyButton({
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
