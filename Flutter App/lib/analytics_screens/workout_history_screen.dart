import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const Color primaryColor = Color(0xFF562634);

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
    if (!mounted) return;
    setState(() {
      isLoading = true;
      errorMessage = '';
    });
    try {
      final email = await storage.read(key: 'email');
      if (!mounted) return;
      if (email == null || email.isEmpty) {
        setState(() {
          isLoading = false;
          errorMessage = 'User email not found. Please log in.';
        });
        return;
      }
      final response = await http.get(
        Uri.parse(
            'https://e-fit-backend.onrender.com/user/workouthistory?email=$email'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 15));
      if (!mounted) return;
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          setState(() {
            workoutData = {
              "numberOfDays": (data['data']['numberOfDays'] as int?) ?? 0,
              "days":
                  List<Map<String, dynamic>>.from(data['data']['days'] ?? [])
            };
            isLoading = false;
          });
        } else {
          setState(() {
            isLoading = false;
            errorMessage = data['message'] ?? 'Failed to load workout history';
          });
        }
      } else {
        String specificError = response.statusCode == 404
            ? 'Workout history not found.'
            : 'Server error: ${response.statusCode}';
        setState(() {
          isLoading = false;
          errorMessage = 'Failed to load workout history: $specificError';
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
        errorMessage = 'An error occurred: ${e.toString()}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context)),
        title: Text('Workout History'),
        backgroundColor: primaryColor,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        actions: [
          if (!isLoading)
            IconButton(
              icon: Icon(Icons.refresh, color: Colors.white),
              onPressed: fetchWorkoutHistory,
              tooltip: 'Refresh History',
            )
        ],
      ),
      body: Container(
        color: Colors.grey[100],
        child: isLoading
            ? Center(child: CircularProgressIndicator(color: primaryColor))
            : errorMessage.isNotEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.error_outline,
                              color: Colors.red, size: 40),
                          SizedBox(height: 10),
                          Text(errorMessage, textAlign: TextAlign.center),
                          SizedBox(height: 10),
                          ElevatedButton.icon(
                            icon: Icon(Icons.refresh),
                            label: Text('Retry'),
                            onPressed: fetchWorkoutHistory,
                            style: ElevatedButton.styleFrom(
                                backgroundColor: primaryColor,
                                foregroundColor: Colors.white),
                          )
                        ],
                      ),
                    ),
                  )
                : (workoutData['days'] as List).isEmpty
                    ? Center(
                        child: Text(
                            'No workout history found.\nGo log some workouts!',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 16, color: Colors.grey[600])))
                    : ListView.builder(
                        padding: EdgeInsets.all(16),
                        itemCount: (workoutData['days'] as List).length,
                        itemBuilder: (context, dayIndex) {
                          final day = (workoutData['days'] as List)[dayIndex]
                                  as Map<String, dynamic>? ??
                              {};
                          final String dayName =
                              day['name'] as String? ?? 'Unknown Day';
                          final List<dynamic> exercises =
                              day['exercises'] as List<dynamic>? ?? [];
                          return Card(
                            margin: EdgeInsets.only(bottom: 16),
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    dayName,
                                    style: TextStyle(
                                      color: primaryColor,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Divider(height: 20, color: Colors.grey[300]),
                                  if (exercises.isEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child: Text("No exercises logged.",
                                          style: TextStyle(
                                              fontStyle: FontStyle.italic,
                                              color: Colors.grey[600])),
                                    )
                                  else
                                    ...List.generate(exercises.length,
                                        (exerciseIndex) {
                                      final exerciseMap =
                                          exercises[exerciseIndex]
                                                  as Map<String, dynamic>? ??
                                              {};
                                      final exerciseName =
                                          exerciseMap.keys.isNotEmpty
                                              ? exerciseMap.keys.first
                                              : 'Unknown Exercise';
                                      final sets = exerciseMap.values.isNotEmpty
                                          ? (exerciseMap.values.first
                                                  as String? ??
                                              '')
                                          : '';
                                      return Container(
                                        width: double.infinity,
                                        margin: EdgeInsets.only(bottom: 10),
                                        decoration: BoxDecoration(
                                            color: Colors.grey[50],
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            border: Border.all(
                                                color: Colors.grey[200]!)),
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
                                                color: Colors.black87,
                                              ),
                                            ),
                                            if (sets.isNotEmpty) ...[
                                              SizedBox(height: 6),
                                              Text(
                                                sets,
                                                style: TextStyle(
                                                  color: Colors.grey[700],
                                                  fontSize: 14,
                                                  height: 1.4,
                                                ),
                                              ),
                                            ]
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