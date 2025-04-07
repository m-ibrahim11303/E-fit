import 'package:flutter/material.dart';
import 'dart:async';
import 'start_journey.dart';

const String journeyJson = '''
{
  "numberOfExercises": 3,
  "exercises": [
    {
      "name": "Push-ups",
      "description": "A basic upper body exercise.",
      "image": "assets/images/pushups.png",
      "typeOfExercise": "reps",
      "detailsTimer": {
        "sets": 0,
        "reps": []
      },
      "detailsReps": {
        "sets": 3,
        "reps": [10, 12, 15]
      }
    },
    {
      "name": "Plank",
      "description": "A core strengthening exercise.",
      "image": "assets/images/plank.png",
      "typeOfExercise": "timer",
      "detailsTimer": {
        "sets": 3,
        "reps": [30, 45, 60]
      },
      "detailsReps": {
        "sets": 0,
        "reps": []
      }
    },
    {
      "name": "Squats",
      "description": "A lower body strength exercise.",
      "image": "assets/images/squats.png",
      "typeOfExercise": "reps",
      "detailsTimer": {
        "sets": 0,
        "reps": []
      },
      "detailsReps": {
        "sets": 4,
        "reps": [15, 15, 12, 10]
      }
    }
  ]
}
''';

class ActiveJourneyScreen extends StatefulWidget {
  final ExerciseJourney journey;

  ActiveJourneyScreen({required this.journey});

  @override
  _ActiveJourneyScreenState createState() => _ActiveJourneyScreenState();
}

class _ActiveJourneyScreenState extends State<ActiveJourneyScreen> {
  int _currentExerciseIndex = 0;
  int _currentSet = 0;
  int _currentTime = 0;
  bool _isRunning = false;
  Timer? _timer;

  Exercise get currentExercise => widget.journey.exercises[_currentExerciseIndex];
  ExerciseDetails get currentDetails => currentExercise.typeOfExercise == 'timer'
      ? currentExercise.detailsTimer
      : currentExercise.detailsReps;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startExercise() {
    setState(() {
      _isRunning = true;
      _currentTime = currentExercise.typeOfExercise == 'timer'
          ? currentDetails.reps[_currentSet]
          : 0;
    });

    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (currentExercise.typeOfExercise == 'timer') {
          if (_currentTime > 0) {
            _currentTime--;
          } else {
            _timer?.cancel();
            _showNextSetDialog();
          }
        } else {
          _currentTime++;
        }
      });
    });
  }

  void _showNextSetDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Time's up!"),
        content: Text("Ready for next set?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _nextStep();
            },
            child: Text('Next Set'),
          ),
        ],
      ),
    );
  }

  void _stopTimer() {
    _timer?.cancel();
    if (currentExercise.typeOfExercise != 'timer') {
      _nextStep();
    }
    setState(() => _isRunning = false);
  }

  void _navigateToEndScreen() {
    _timer?.cancel();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => EndScreen()),
    );
  }

  void _nextStep() {
    if (_currentSet < currentDetails.reps.length - 1) {
      setState(() => _currentSet++);
      if (currentExercise.typeOfExercise == 'timer') _startExercise();
    } else {
      if (_currentExerciseIndex < widget.journey.exercises.length - 1) {
        setState(() {
          _currentExerciseIndex++;
          _currentSet = 0;
        });
        if (currentExercise.typeOfExercise == 'timer') _startExercise();
      } else {
        _navigateToEndScreen();
      }
    }
  }

  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Active Journey'),
        flexibleSpace: Container(
          decoration: BoxDecoration(color: Color(0xFF562634)),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.stop),
            onPressed: _navigateToEndScreen,
            tooltip: 'Complete Offline',
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.amber[50]!, Colors.red[50]!],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  currentExercise.timer ? Icons.timer : Icons.fitness_center,
                  size: 100,
                  color: Color(0xFF562634),
                ),
                SizedBox(height: 20),
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 4,
                  margin: EdgeInsets.symmetric(horizontal: 20),
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Text(
                          currentExercise.name,
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF562634),
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          currentExercise.description,
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  'Set ${_currentSet + 1} of ${currentDetails.reps.length}',
                  style: TextStyle(fontSize: 18),
                ),
                SizedBox(height: 20),
                Text(
                  currentExercise.typeOfExercise == 'timer'
                      ? 'Time remaining: $_currentTime seconds'
                      : 'Elapsed time: ${_formatTime(_currentTime)}',
                  style: TextStyle(fontSize: 20),
                ),
                SizedBox(height: 30),
                if (!_isRunning)
                  ElevatedButton(
                    onPressed: _startExercise,
                    child: Text(
                      currentExercise.typeOfExercise == 'timer' 
                          ? 'Start ${currentExercise.name}'
                          : 'Begin Exercise',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF562634),
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    ),
                  ),
                if (_isRunning)
                  Column(
                    children: [
                      ElevatedButton(
                        onPressed: _stopTimer,
                        child: Text(
                          currentExercise.typeOfExercise == 'timer' 
                              ? 'Stop' 
                              : 'Done',
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF562634),
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class EndScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Feedback'),
        backgroundColor: Color(0xFF562634),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.amber[50]!, Colors.red[50]!],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'How did you find today\'s exercises?',
                style: TextStyle(fontSize: 24, color: Color(0xFF562634)),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 30),
              _buildDifficultyButton('Easy', context),
              _buildDifficultyButton('Medium', context),
              _buildDifficultyButton('Hard', context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDifficultyButton(String difficulty, BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: ElevatedButton(
        onPressed: () => Navigator.pop(context),
        child: Text(
          difficulty,
          style: TextStyle(fontSize: 20),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFF562634),
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
      ),
    );
  }
}
