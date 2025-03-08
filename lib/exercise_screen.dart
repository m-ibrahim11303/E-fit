import 'package:flutter/material.dart';

// Exercises Screen
class Exercise {
  final String name;
  final String description;

  Exercise(this.name, this.description);
}

// Exercises Screen
class ExercisesScreen extends StatefulWidget {
  @override
  _ExercisesScreenState createState() => _ExercisesScreenState();
}

class _ExercisesScreenState extends State<ExercisesScreen> {
  int _completedExercises = 12;
  final int _totalExercises = 25;
  int _stepsWalked = 8450;
  final List<Exercise> _todayExercises = [
    Exercise('Push-ups', '3 sets of 15 reps'),
    Exercise('Squats', '4 sets of 20 reps'),
    Exercise('Plank', '3 sets of 1 minute'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Fitness Journey'),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.red.shade900, Colors.yellow.shade800],
            ),
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
              // Progress Stats
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
                      color: Colors.green,
                    ),
                    Divider(height: 30),
                    _ProgressStat(
                      icon: Icons.directions_walk,
                      value: '$_stepsWalked',
                      label: 'Steps Walked',
                      color: Colors.blue,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 30),
              // Action Buttons
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _JourneyButton(
                      icon: Icons.flag,
                      label: 'Start New Journey',
                      gradient: LinearGradient(
                        colors: [Colors.red[700]!, Colors.orange[700]!],
                      ),
                      onPressed: () {
                        // Handle new journey start
                        setState(() {
                          _completedExercises = 0;
                          _stepsWalked = 0;
                        });
                      },
                    ),
                    SizedBox(height: 30),
                    _JourneyButton(
                      icon: Icons.directions_run,
                      label: 'Continue Journey',
                      gradient: LinearGradient(
                        colors: [Colors.amber[600]!, Colors.orange[700]!],
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (_) => WorkoutTimer(
                                  exercise: _todayExercises.first,
                                ),
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

// Progress Stat Widget
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

// Journey Button Widget
class _JourneyButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Gradient gradient;
  final VoidCallback onPressed;

  const _JourneyButton({
    required this.icon,
    required this.label,
    required this.gradient,
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
          gradient: gradient,
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

// Workout Timer
class WorkoutTimer extends StatefulWidget {
  final Exercise exercise;

  WorkoutTimer({required this.exercise});

  @override
  _WorkoutTimerState createState() => _WorkoutTimerState();
}

class _WorkoutTimerState extends State<WorkoutTimer> {
  bool _isRunning = false;
  int _secondsElapsed = 0;
  String _message = '';

  void _startTimer() {
    setState(() {
      _isRunning = true;
      _message = '';
    });
    Future.delayed(Duration(seconds: 1), _updateTimer);
  }

  void _updateTimer() {
    if (_isRunning) {
      setState(() {
        _secondsElapsed++;
      });
      Future.delayed(Duration(seconds: 1), _updateTimer);
    }
  }

  void _stopTimer() {
    setState(() {
      _isRunning = false;
      _message = 'Great work!';
    });
  }

  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.exercise.name)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _formatTime(_secondsElapsed),
              style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            if (!_isRunning && _secondsElapsed == 0)
              ElevatedButton(
                onPressed: _startTimer,
                child: Text('Start Timer'),
              ),
            if (_isRunning)
              ElevatedButton(onPressed: _stopTimer, child: Text('Stop')),
            if (_message.isNotEmpty)
              Padding(
                padding: EdgeInsets.only(top: 20),
                child: Text(
                  _message,
                  style: TextStyle(fontSize: 24, color: Colors.green),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
