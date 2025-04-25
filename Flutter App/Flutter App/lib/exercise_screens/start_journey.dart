import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// ------------------ MODELS ------------------

/// A model for a single exercise.
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
    bool isTimer = json['timer'] ?? false;

    return Exercise(
      name: json['name'],
      machineUse: json['machineUse'] ?? false,
      timer: isTimer,
      description: json['description'] ?? '',
      image: json['image'] ?? 'https://via.placeholder.com/150',
      detailsTimer: json.containsKey('detailsTimer')
          ? ExerciseDetails.fromJson(json['detailsTimer'])
          : (isTimer
              ? ExerciseDetails(sets: 1, reps: [30])
              : ExerciseDetails(sets: 0, reps: [])),
      detailsReps: json.containsKey('detailsReps')
          ? ExerciseDetails.fromJson(json['detailsReps'])
          : (!isTimer
              ? ExerciseDetails(sets: 1, reps: [10])
              : ExerciseDetails(sets: 0, reps: [])),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'machineUse': machineUse,
      'timer': timer,
      'description': description,
      'image': image,
      'typeOfExercise': typeOfExercise,
    };
  }
}

class ExerciseDetails {
  final int sets;
  final List<int> reps;

  ExerciseDetails({required this.sets, required this.reps});

  factory ExerciseDetails.fromJson(Map<String, dynamic> json) {
    return ExerciseDetails(
      sets: json['sets'],
      reps: List<int>.from(json['reps']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sets': sets,
      'reps': reps,
    };
  }
}

class ExerciseJourney {
  final int numberOfExercises;
  final List<Exercise> exercises;

  ExerciseJourney({required this.numberOfExercises, required this.exercises});

  factory ExerciseJourney.fromJson(Map<String, dynamic> json) {
    List<dynamic> exerciseList = json['exercises'];
    List<Exercise> exercises =
        exerciseList.map((e) => Exercise.fromJson(e)).toList();

    return ExerciseJourney(
      numberOfExercises: json['numberOfExercises'],
      exercises: exercises,
    );
  }
}

/// ------------------ API SERVICE ------------------
class ExerciseService {
  static const String baseUrl = 'https://e-fit-backend.onrender.com/user';
  static final storage = FlutterSecureStorage();

  static Future<void> saveExercises(
      List<Map<String, dynamic>> exercises) async {
    try {
      final userEmail = await storage.read(key: 'email');
      if (userEmail == null) {
        throw Exception('User email not found');
      }

      final response = await http.post(
        Uri.parse('$baseUrl/saveexercises'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': userEmail,
          'exercises': exercises.map((e) {
            Exercise exercise = e['exercise'];
            return {
              'exercise': {
                'name': exercise.name,
                'timer': exercise.timer,
                'typeOfExercise': exercise.typeOfExercise,
              },
              'setData': e['setData'],
            };
          }).toList(),
        }),
      );

      if (response.statusCode != 201) {
        throw Exception('Failed to save exercises: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error saving exercises: $e');
    }
  }
}

/// ------------------ HOME SCREEN ------------------

class ExercisesListScreen extends StatefulWidget {
  @override
  _ExercisesListScreenState createState() => _ExercisesListScreenState();
}

class _ExercisesListScreenState extends State<ExercisesListScreen> {
  final String jsonString = '''
  {
    "numberOfExercises": 6,
    "exercises": [
      { "name": "Running", "machineUse": false, "timer": true },
      { "name": "Plank", "machineUse": false, "timer": true },
      { "name": "Bench press", "machineUse": true, "timer": false },
      { "name": "Shoulder press", "machineUse": true, "timer": false },
      { "name": "Dumbell bench press", "machineUse": true, "timer": false },
      { "name": "Lateral raises", "machineUse": true, "timer": false }
    ]
  }
  ''';

  late final ExerciseJourney journey;
  final List<Map<String, dynamic>> chosenExercises = [];
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    Map<String, dynamic> jsonData = jsonDecode(jsonString);
    journey = ExerciseJourney.fromJson(jsonData);
  }

  Future<void> openExerciseSetup(Exercise exercise) async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
          builder: (_) => ExerciseSetupScreen(exercise: exercise)),
    );
    if (result != null) {
      setState(() {
        chosenExercises.add({
          'id': DateTime.now().millisecondsSinceEpoch.toString(),
          'exercise': result['exercise'],
          'setData': result['setData'],
        });
      });
    }
  }

  void removeChosenExercise(String id) {
    setState(() {
      chosenExercises.removeWhere((entry) => entry['id'] == id);
    });
  }

  Future<void> saveExercises() async {
    if (chosenExercises.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No exercises to save!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      await ExerciseService.saveExercises(chosenExercises);

      // Show success message only on successful save
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Exercises saved successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      // Clear the selected exercises after successful save
      setState(() {
        chosenExercises.clear();
      });
    } catch (e) {
      // Show error message only if there's an actual error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save exercises: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      // Ensure the saving state is reset regardless of success or failure
      setState(() {
        _isSaving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Log Workout'),
        titleTextStyle: TextStyle(color: Colors.white, fontSize: 20),
        flexibleSpace: Container(color: Color(0xFF562634)),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.amber[50]!, Colors.red[50]!],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        padding: EdgeInsets.all(24),
        child: ListView(
          children: [
            ...journey.exercises.map((exercise) {
              return ExerciseCard(
                exercise: exercise,
                onTap: () => openExerciseSetup(exercise),
              );
            }).toList(),
            if (chosenExercises.isNotEmpty) ...[
              SizedBox(height: 30),
              Text(
                'Selected Exercises:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              ...chosenExercises.map((entry) {
                Exercise exercise = entry['exercise'] as Exercise;
                List<Map<String, dynamic>> sets =
                    List<Map<String, dynamic>>.from(entry['setData']);
                String subtitle = sets.map((setInfo) {
                  final value = setInfo['value'];
                  final type = setInfo['type'];
                  final weight = setInfo.containsKey('weight')
                      ? ' @ ${setInfo['weight']}kg'
                      : '';
                  return '${setInfo['set']}: $value $type$weight';
                }).join('  •  ');
                return ListTile(
                  contentPadding: EdgeInsets.symmetric(horizontal: 0),
                  title: Text(exercise.name),
                  subtitle: Text(subtitle),
                  trailing: IconButton(
                    icon: Icon(Icons.close, color: Colors.red),
                    onPressed: () => removeChosenExercise(entry['id']),
                  ),
                );
              }).toList(),
              SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF562634),
                  padding: EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                onPressed: _isSaving ? null : saveExercises,
                child: _isSaving
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text('Save All Exercises',
                        style: TextStyle(color: Colors.white)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// ------------------ EXERCISE CARD ------------------

class ExerciseCard extends StatelessWidget {
  final Exercise exercise;
  final VoidCallback onTap;

  const ExerciseCard({
    required this.exercise,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      margin: EdgeInsets.symmetric(vertical: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: exercise.machineUse ? Colors.blue[50] : Colors.green[50],
            borderRadius: BorderRadius.circular(15),
          ),
          child: Row(
            children: [
              Icon(
                exercise.machineUse
                    ? Icons.fitness_center
                    : Icons.self_improvement,
                color: Colors.red[800],
              ),
              SizedBox(width: 16),
              Expanded(
                child: Text(
                  exercise.name,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
              ),
              Icon(Icons.arrow_forward_ios, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}

/// ------------------ EXERCISE SETUP SCREEN ------------------

class ExerciseSetupScreen extends StatefulWidget {
  final Exercise exercise;

  ExerciseSetupScreen({required this.exercise});

  @override
  _ExerciseSetupScreenState createState() => _ExerciseSetupScreenState();
}

class _ExerciseSetupScreenState extends State<ExerciseSetupScreen> {
  int? numberOfSets;
  List<TextEditingController> repControllers = [];
  List<TextEditingController> weightControllers = [];

  @override
  void dispose() {
    for (var controller in repControllers) controller.dispose();
    for (var controller in weightControllers) controller.dispose();
    super.dispose();
  }

  void generateSetFields(int sets) {
    setState(() {
      numberOfSets = sets;
      repControllers = List.generate(sets, (_) => TextEditingController());
      if (widget.exercise.machineUse && !widget.exercise.timer) {
        weightControllers = List.generate(sets, (_) => TextEditingController());
      } else {
        weightControllers = [];
      }
    });
  }

  void submitSetup() {
    for (var controller in repControllers) {
      if (controller.text.isEmpty || int.tryParse(controller.text) == null) {
        return showError('Please enter valid numbers for all sets.');
      }
    }
    if (widget.exercise.machineUse && !widget.exercise.timer) {
      for (var controller in weightControllers) {
        if (controller.text.isEmpty ||
            double.tryParse(controller.text) == null) {
          return showError('Please enter valid weights for all sets.');
        }
      }
    }

    final setData = List.generate(repControllers.length, (i) {
      Map<String, dynamic> data = {
        'set': i + 1,
        'value': repControllers[i].text,
        'type': widget.exercise.timer ? 'seconds' : 'reps',
      };
      if (widget.exercise.machineUse && !widget.exercise.timer) {
        data['weight'] = weightControllers[i].text;
      }
      return data;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Workout added! Make sure to save before leaving!'),
        backgroundColor: Colors.green,
      ),
    );

    Navigator.of(context).pop({
      'exercise': widget.exercise,
      'setData': setData,
    });
  }

  void showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.exercise.name),
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        flexibleSpace: Container(color: Color(0xFF562634)),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.amber[50]!, Colors.red[50]!],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        padding: EdgeInsets.all(16),
        child: ListView(
          children: [
            Text(
              'Select Number of Sets',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: List.generate(5, (i) {
                int setCount = i + 1;
                bool isSelected = numberOfSets == setCount;
                return ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        isSelected ? Colors.red[800] : Colors.grey[300],
                  ),
                  onPressed: () => generateSetFields(setCount),
                  child: Text(
                    '$setCount',
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black87,
                      fontSize: 16,
                    ),
                  ),
                );
              }),
            ),
            if (numberOfSets != null) ...[
              SizedBox(height: 24),
              ...List.generate(numberOfSets!, (i) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: TextField(
                        controller: repControllers[i],
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: widget.exercise.timer
                              ? 'Set ${i + 1} Time (sec)'
                              : 'Set ${i + 1} Reps',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    if (widget.exercise.machineUse && !widget.exercise.timer)
                      Padding(
                        padding: EdgeInsets.only(bottom: 8),
                        child: TextField(
                          controller: weightControllers[i],
                          keyboardType:
                              TextInputType.numberWithOptions(decimal: true),
                          decoration: InputDecoration(
                            labelText: 'Set ${i + 1} Weight (kg)',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                  ],
                );
              }),
              SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF562634),
                  padding: EdgeInsets.symmetric(vertical: 15),
                ),
                onPressed: submitSetup,
                child: Text(
                  'Add Workout',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
