import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:async';
import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // Add secure storage

// JSON data stored locally in the Dart file.
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

// Global secure storage instance
final FlutterSecureStorage storage = FlutterSecureStorage();

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fitness Journey',
      theme: ThemeData(primarySwatch: Colors.red),
      home: ExercisesScreen(),
    );
  }
}

class Exercise {
  final String name;
  final bool machineUse;
  final bool timer;
  final String description;
  final String image;
  final String typeOfExercise;
  final ExerciseDetails detailsTimer;
  final ExerciseDetails detailsReps;

  Exercise({
    required this.name,
    required this.machineUse,
    required this.timer,
    this.description = '',
    this.image = 'https://via.placeholder.com/150',
    String? typeOfExercise,
    ExerciseDetails? detailsTimer,
    ExerciseDetails? detailsReps,
  })  : typeOfExercise = typeOfExercise ?? (timer ? 'timer' : 'reps'),
        detailsTimer = detailsTimer ??
            (timer
                ? ExerciseDetails(sets: 1, reps: [30])
                : ExerciseDetails(sets: 0, reps: [])),
        detailsReps = detailsReps ??
            (!timer
                ? ExerciseDetails(sets: 1, reps: [10])
                : ExerciseDetails(sets: 0, reps: []));

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      name: json['name'],
      machineUse: json['machineUse'] ?? false,
      timer: json['timer'] ?? false,
      description: json['description'] ?? '',
      image: json['image'] ?? 'https://via.placeholder.com/150',
      detailsTimer: json.containsKey('detailsTimer')
          ? ExerciseDetails.fromJson(json['detailsTimer'])
          : (json['timer']
              ? ExerciseDetails(sets: 1, reps: [30])
              : ExerciseDetails(sets: 0, reps: [])),
      detailsReps: json.containsKey('detailsReps')
          ? ExerciseDetails.fromJson(json['detailsReps'])
          : (!json['timer']
              ? ExerciseDetails(sets: 1, reps: [10])
              : ExerciseDetails(sets: 0, reps: [])),
    );
  }
}

class ExercisesScreen extends StatefulWidget {
  @override
  _ExercisesScreenState createState() => _ExercisesScreenState();
}

class _ExercisesScreenState extends State<ExercisesScreen> {
  int _completedExercises = 12;
  final int _totalExercises = 25;
  int _stepsWalked = 8450;
  String? _userEmail; // To store the fetched email
  final List<Exercise> _todayExercises = [
    Exercise(name: 'Push-ups', machineUse: false, timer: false),
    Exercise(name: 'Squats', machineUse: false, timer: false),
    Exercise(name: 'Plank', machineUse: false, timer: true),
  ];

  @override
  void initState() {
    super.initState();
    _fetchEmail(); // Fetch email when the screen initializes
  }

  Future<void> _fetchEmail() async {
    final String? email = await storage.read(key: 'email');
    setState(() {
      _userEmail = email ?? 'No email found'; // Default message if no email
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Fitness Journey email'), //, '$_userEmail'), // Display email here
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
                      label: 'Steps Walked email: ($_userEmail)', // Display email here
                      color: Colors.blue,
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
                      gradient: LinearGradient(
                        colors: [Colors.red[700]!, Colors.orange[700]!],
                      ),
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
                      gradient: LinearGradient(
                        colors: [Colors.amber[600]!, Colors.orange[700]!],
                      ),
                      onPressed: () {
                        // Parse the local JSON string and create an ExerciseJourney object.
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

class ExercisesListScreen extends StatelessWidget {
  final String jsonString = '''
  {
    "numberOfExercises": 6,
    "exercises": [
        {
            "name": "Running",
            "machineUse": false,
            "timer": true
        },
        {
            "name": "Plank",
            "machineUse": false,
            "timer": true
        },
        {
            "name": "Bench press",
            "machineUse": true,
            "timer": false
        },
        {
            "name": "Shoulder press",
            "machineUse": true,
            "timer": false
        },
        {
            "name": "Dumbell bench press",
            "machineUse": true,
            "timer": false
        },
        {
            "name": "Lateral raises",
            "machineUse": true,
            "timer": false
        }
    ]
  }
  ''';

  ExerciseJourney parseJourney() {
    final jsonData = jsonDecode(jsonString);
    return ExerciseJourney.fromJson(jsonData);
  }

  @override
  Widget build(BuildContext context) {
    final journey = parseJourney();
    return Scaffold(
      appBar: AppBar(
        title: Text('Exercise Journey'),
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
          padding: EdgeInsets.all(16),
          child: ListView.builder(
            itemCount: journey.exercises.length,
            itemBuilder: (context, index) {
              final exercise = journey.exercises[index];
              return Card(
                elevation: 4,
                margin: EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: ListTile(
                  tileColor:
                      exercise.machineUse ? Colors.blue[50] : Colors.green[50],
                  title: Text(
                    exercise.name,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  subtitle: Text(
                    exercise.machineUse
                        ? 'Machine Exercise'
                        : 'Bodyweight Exercise',
                    style: TextStyle(
                      color: Colors.grey[600],
                    ),
                  ),
                  trailing: Icon(
                    exercise.machineUse
                        ? Icons.fitness_center
                        : Icons.self_improvement,
                    color: Colors.red[800],
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ExerciseSetupScreen(exercise: exercise),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class ExerciseSetupScreen extends StatefulWidget {
  final Exercise exercise;

  ExerciseSetupScreen({required this.exercise});

  @override
  _ExerciseSetupScreenState createState() => _ExerciseSetupScreenState();
}

class _ExerciseSetupScreenState extends State<ExerciseSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  int? _numberOfSets;
  List<TextEditingController> _setControllers = [];

  @override
  void dispose() {
    for (var controller in _setControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _generateSetFields(int sets) {
    setState(() {
      _numberOfSets = sets;
      _setControllers = List.generate(sets, (index) => TextEditingController());
    });
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      List<Map<String, dynamic>> setData = [];

      for (int i = 0; i < _setControllers.length; i++) {
        setData.add({
          'set': i + 1,
          'value': _setControllers[i].text,
          'type': widget.exercise.timer ? 'seconds' : 'reps'
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Workout saved: ${setData.toString()}'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.exercise.name),
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
          padding: EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                if (_numberOfSets == null)
                  TextFormField(
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Number of Sets',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Required';
                      final parsed = int.tryParse(value);
                      if (parsed == null || parsed < 1) return 'Invalid number';
                      return null;
                    },
                    onSaved: (value) {
                      final sets = int.parse(value!);
                      _generateSetFields(sets);
                    },
                  )
                else
                  ..._setControllers.asMap().entries.map((entry) {
                    final index = entry.key;
                    final controller = entry.value;
                    return Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: TextFormField(
                        controller: controller,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: widget.exercise.timer
                              ? 'Set ${index + 1} Time (seconds)'
                              : 'Set ${index + 1} Reps',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Required';
                          if (int.tryParse(value) == null)
                            return 'Invalid number';
                          return null;
                        },
                      ),
                    );
                  }).toList(),
                SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[800],
                    padding: EdgeInsets.symmetric(vertical: 15),
                  ),
                  onPressed: () {
                    if (_numberOfSets == null) {
                      if (_formKey.currentState!.validate()) {
                        _formKey.currentState!.save();
                      }
                    } else {
                      _submit();
                    }
                  },
                  child: Text(
                    _numberOfSets == null ? 'Continue' : 'Save Workout',
                    style: TextStyle(fontSize: 18, color: Colors.white),
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

class ExerciseJourney {
  final int numberOfExercises;
  final List<Exercise> exercises;

  ExerciseJourney({
    required this.numberOfExercises,
    required this.exercises,
  });

  factory ExerciseJourney.fromJson(Map<String, dynamic> json) {
    var exercises =
        (json['exercises'] as List).map((e) => Exercise.fromJson(e)).toList();

    return ExerciseJourney(
      numberOfExercises: json['numberOfExercises'],
      exercises: exercises,
    );
  }
}

class ExerciseDetails {
  final int sets;
  final List<int> reps;

  ExerciseDetails({
    required this.sets,
    required this.reps,
  });

  factory ExerciseDetails.fromJson(Map<String, dynamic> json) {
    return ExerciseDetails(
      sets: json['sets'],
      reps: List<int>.from(json['reps']),
    );
  }
}

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
  bool _showCompletionMessage = false;

  Exercise get currentExercise =>
      widget.journey.exercises[_currentExerciseIndex];
  ExerciseDetails get currentDetails =>
      currentExercise.typeOfExercise == 'timer'
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
            _stopTimer();
          }
        } else {
          _currentTime++;
        }
      });
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      _showCompletionMessage = true;
    });

    Future.delayed(Duration(seconds: 3), () {
      setState(() => _showCompletionMessage = false);
      _nextStep();
    });
  }

  void _nextStep() {
    if (_currentSet < currentDetails.sets - 1) {
      setState(() => _currentSet++);
    } else {
      if (_currentExerciseIndex < widget.journey.exercises.length - 1) {
        setState(() {
          _currentExerciseIndex++;
          _currentSet = 0;
        });
      } else {
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Active Journey'),
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
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  currentExercise.timer ? Icons.timer : Icons.fitness_center,
                  size: 100,
                  color: Colors.red[800],
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
                            color: Colors.red.shade800,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          currentExercise.description,
                          textAlign: TextAlign.center,
                          style:
                              TextStyle(fontSize: 16, color: Colors.grey[700]),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  'Set ${_currentSet + 1} of ${currentDetails.sets}',
                  style: TextStyle(fontSize: 18),
                ),
                SizedBox(height: 20),
                Text(
                  currentExercise.typeOfExercise == 'timer'
                      ? 'Time remaining: $_currentTime seconds'
                      : 'Reps completed: $_currentTime',
                  style: TextStyle(fontSize: 20),
                ),
                SizedBox(height: 30),
                if (_showCompletionMessage)
                  Text(
                    _currentExerciseIndex ==
                                widget.journey.exercises.length - 1 &&
                            _currentSet == currentDetails.sets - 1
                        ? 'All done for the day! 🎉'
                        : 'Great work!',
                    style: TextStyle(
                      fontSize: 24,
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                if (!_showCompletionMessage && !_isRunning)
                  ElevatedButton(
                    onPressed: _startExercise,
                    child: Text('Start ${currentExercise.name}'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[800],
                      foregroundColor: Colors.white,
                      padding:
                          EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    ),
                  ),
                if (_isRunning)
                  ElevatedButton(
                    onPressed: _stopTimer,
                    child: Text('Stop'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[800],
                      foregroundColor: Colors.white,
                      padding:
                          EdgeInsets.symmetric(horizontal: 40, vertical: 15),
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
