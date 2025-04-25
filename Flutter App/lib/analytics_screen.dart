import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// Dynamic image sources
const List<String> imageUrls = [
  'https://example.com/analytics1.jpg',
  'https://example.com/analytics2.jpg',
  'https://example.com/analytics3.jpg',
];

class AnalyticsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Analytics'),
        backgroundColor: Color(0xFF562634),
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20,
        ),
      ),
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
                    SizedBox(height: 20), // Spacing below app bar
                    // Vertical Image Stack
                    Expanded(
                      child: Column(
                        children: [
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 8.0),
                              child: Image.asset(
                                'assets/images/analytics_place_holder.png',
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 8.0),
                              child: Image.asset(
                                'assets/images/analytics_place_holder2.png',
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 8.0),
                              child: Image.asset(
                                'assets/images/analytics_place_holder3.png',
                                fit: BoxFit.cover,
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
            // Bottom Section with Horizontal Buttons
            Expanded(
              flex: 1,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _CustomButton(
                      icon: Icons.fitness_center,
                      label: 'Workout\nHistory',
                      color: Color(0xFF562634),
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => WorkoutHistoryScreen()),
                      ),
                      buttonSize: Size(160, 160),
                    ),
                    _CustomButton(
                      icon: Icons.restaurant,
                      label: 'Diet\nHistory',
                      color: Color(0xFF562634),
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => DietHistoryScreen()),
                      ),
                      buttonSize: Size(160, 160),
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

class _CustomButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onPressed;
  final Size buttonSize;

  const _CustomButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onPressed,
    this.buttonSize = const Size(150, 150),
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: buttonSize.width,
      height: buttonSize.height,
      child: Card(
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
                SizedBox(height: 8),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    label,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
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

// Workout History Screen
class WorkoutHistoryScreen extends StatefulWidget {
  @override
  _WorkoutHistoryScreenState createState() => _WorkoutHistoryScreenState();
}

class _WorkoutHistoryScreenState extends State<WorkoutHistoryScreen> {
  Map<String, dynamic> workoutData = {"numberOfDays": 0, "days": []};
  bool isLoading = true;
  String errorMessage = '';
  final storage = FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    fetchWorkoutHistory();
  }

  Future<void> fetchWorkoutHistory() async {
    try {
      final email = await storage.read(key: 'email');

      if (email == null) {
        setState(() {
          isLoading = false;
          errorMessage = 'User email not found.';
        });
        return;
      }

      final response = await http.get(
        Uri.parse(
            'https://e-fit-backend.onrender.com/user/workouthistory?email=$email'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          setState(() {
            workoutData = data['data'];
            isLoading = false;
          });
        } else {
          setState(() {
            isLoading = false;
            errorMessage = data['message'] ?? 'Failed to load workout history';
          });
        }
      } else {
        setState(() {
          isLoading = false;
          errorMessage =
              'Failed to load workout history: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Error: ${e.toString()}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Workout History'),
        backgroundColor: Color(0xFF562634),
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: Container(
        color: Colors.white,
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : errorMessage.isNotEmpty
                ? Center(child: Text(errorMessage))
                : workoutData['numberOfDays'] == 0
                    ? Center(child: Text('No workout history available'))
                    : ListView.builder(
                        padding: EdgeInsets.all(16),
                        itemCount: workoutData['days'].length,
                        itemBuilder: (context, dayIndex) {
                          final day = workoutData['days'][dayIndex];
                          return Padding(
                            padding: EdgeInsets.only(bottom: 20),
                            child: Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Color(0xFF562634),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    day['name'],
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  ...List.generate(day['exercises'].length,
                                      (exerciseIndex) {
                                    final exercise =
                                        day['exercises'][exerciseIndex];
                                    final exerciseName = exercise.keys.first;
                                    final sets = exercise.values.first;
                                    return Container(
                                      width: double.infinity,
                                      margin: EdgeInsets.only(bottom: 8),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      padding: EdgeInsets.all(12),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            exerciseName,
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                          SizedBox(height: 6),
                                          Text(
                                            sets,
                                            style: TextStyle(
                                              color: Colors.grey[700],
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
      ),
    );
  }
}

// Diet History Screen
class DietHistoryScreen extends StatefulWidget {
  @override
  _DietHistoryScreenState createState() => _DietHistoryScreenState();
}

class _DietHistoryScreenState extends State<DietHistoryScreen> {
  Map<String, dynamic> dietData = {"numberOfDays": 0, "days": []};
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    fetchDietHistory();
  }

  Future<void> fetchDietHistory() async {
    const apiUrl = 'https://e-fit-backend.onrender.com/user/diethistory';
    final storage = FlutterSecureStorage();

    try {
      final userEmail = await storage.read(key: 'email');

      if (userEmail == null) {
        setState(() {
          isLoading = false;
          errorMessage = 'User email not found.';
        });
        return;
      }

      final response = await http.get(Uri.parse('$apiUrl?email=$userEmail'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          setState(() {
            dietData = data['data'];
            isLoading = false;
          });
        } else {
          setState(() {
            isLoading = false;
            errorMessage = data['message'] ?? 'Failed to load diet history';
          });
        }
      } else {
        setState(() {
          isLoading = false;
          errorMessage = 'Failed to load diet history: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Error: ${e.toString()}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Diet History'),
        backgroundColor: Color(0xFF562634),
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: Container(
        color: Colors.white,
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : errorMessage.isNotEmpty
                ? Center(child: Text(errorMessage))
                : dietData['numberOfDays'] == 0
                    ? Center(child: Text('No diet history available'))
                    : ListView.builder(
                        padding: EdgeInsets.all(16),
                        itemCount: dietData['days'].length,
                        itemBuilder: (context, dayIndex) {
                          final day = dietData['days'][dayIndex];
                          return Padding(
                            padding: EdgeInsets.only(bottom: 20),
                            child: Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Color(0xFF562634),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    day['name'],
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  ...List.generate(day['meals'].length,
                                      (mealIndex) {
                                    final meal = day['meals'][mealIndex];
                                    final mealName = meal.keys.first;
                                    final nutrition = meal.values.first;
                                    return Container(
                                      width: double.infinity,
                                      margin: EdgeInsets.only(bottom: 8),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      padding: EdgeInsets.all(12),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            mealName,
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                          SizedBox(height: 6),
                                          Text(
                                            nutrition,
                                            style: TextStyle(
                                              color: Colors.grey[700],
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
      ),
    );
  }
}
