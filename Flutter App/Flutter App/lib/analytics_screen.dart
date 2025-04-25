import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; // Keep for history screens
import 'dart:convert'; // Keep for history screens
import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // Keep for history screens
import 'analytics_test.dart'; // <--- Make sure this imports ActivityGraphScreen class

// Define the primary color consistently
const Color primaryColor = Color(0xFF562634);

class AnalyticsScreen extends StatelessWidget {
  // Remains StatelessWidget for this version
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double horizontalPadding = 40.0;
    double buttonSpacing = 20.0;
    double availableWidth = screenWidth - horizontalPadding - buttonSpacing;
    double historyButtonWidth = availableWidth / 2;
    double historyButtonHeight = historyButtonWidth * 0.8;

    // Define size for the large central button
    // Make it a significant portion of the screen width, e.g., 70%
    double largeButtonWidth = screenWidth * 0.7;
    // Make height proportional or fixed, e.g., 40% of its width
    double largeButtonHeight = largeButtonWidth * 0.4;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Analytics'),
        backgroundColor: primaryColor, // Use defined color
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20,
        ),
        // --- REMOVED actions list ---
        // actions: [ ... IconButton removed ... ],
      ),
      body: Container(
        color: Colors.grey[100], // Use a light background color
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // --- History Buttons at the Top ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _CustomButton(
                    icon: Icons.fitness_center,
                    label: 'Workout\nHistory',
                    color: primaryColor,
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => WorkoutHistoryScreen()),
                    ),
                    buttonSize: Size(historyButtonWidth, historyButtonHeight),
                  ),
                  _CustomButton(
                    icon: Icons.restaurant,
                    label: 'Diet\nHistory',
                    color: primaryColor,
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => DietHistoryScreen()),
                    ),
                    buttonSize: Size(historyButtonWidth, historyButtonHeight),
                  ),
                ],
              ),
              // --- END History Buttons ---

              // --- Large Centered Button ---
              // Use Expanded to take remaining space and Center to position the button
              Expanded(
                child: Center(
                  child: _CustomButton(
                    // Use the same custom button widget
                    icon: Icons.bar_chart, // Icon for analytics/charts
                    label: 'Detailed\nAnalytics', // Clear label
                    color: primaryColor, // Use consistent color
                    onPressed: () {
                      // Navigate to the detailed screen when pressed
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ActivityGraphScreen()),
                      );
                    },
                    // Use the larger, calculated size
                    buttonSize: Size(largeButtonWidth, largeButtonHeight),
                  ),
                ),
              ),
              // --- END Large Centered Button ---
            ],
          ),
        ),
      ),
    );
  }
}

// _CustomButton Widget (Unchanged from previous version)
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
    required this.buttonSize,
  });

  @override
  Widget build(BuildContext context) {
    double fontSize = buttonSize.height * 0.12;
    if (fontSize < 14) fontSize = 14;
    if (fontSize > 18) fontSize = 18;
    double iconSize = buttonSize.height * 0.25;
    if (iconSize < 24) iconSize = 24;
    if (iconSize > 35) iconSize = 35;

    return SizedBox(
      width: buttonSize.width,
      height: buttonSize.height,
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          borderRadius: BorderRadius.circular(15),
          onTap: onPressed,
          child: Container(
            decoration: BoxDecoration(color: color),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: iconSize, color: Colors.white),
                SizedBox(height: 8),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    label,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: fontSize,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
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

// --- History Screen Definitions ---
// (Include the actual implementations of WorkoutHistoryScreen and DietHistoryScreen here)

// Workout History Screen (Keep the full StatefulWidget implementation)
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

// Diet History Screen (Keep the full StatefulWidget implementation)
class DietHistoryScreen extends StatefulWidget {
  @override
  _DietHistoryScreenState createState() => _DietHistoryScreenState();
}

class _DietHistoryScreenState extends State<DietHistoryScreen> {
  Map<String, dynamic> dietData = {"numberOfDays": 0, "days": []};
  bool isLoading = true;
  String errorMessage = '';
  final storage = FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    fetchDietHistory();
  }

  Future<void> fetchDietHistory() async {
    if (!mounted) return;
    setState(() {
      isLoading = true;
      errorMessage = '';
    });
    const apiUrl = 'https://e-fit-backend.onrender.com/user/diethistory';
    try {
      final userEmail = await storage.read(key: 'email');
      if (!mounted) return;
      if (userEmail == null || userEmail.isEmpty) {
        setState(() {
          isLoading = false;
          errorMessage = 'User email not found.';
        });
        return;
      }
      final response = await http.get(
        Uri.parse('$apiUrl?email=$userEmail'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 15));
      if (!mounted) return;
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          setState(() {
            dietData = {
              "numberOfDays": (data['data']['numberOfDays'] as int?) ?? 0,
              "days":
                  List<Map<String, dynamic>>.from(data['data']['days'] ?? [])
            };
            isLoading = false;
          });
        } else {
          setState(() {
            isLoading = false;
            errorMessage = data['message'] ?? 'Failed to load diet history';
          });
        }
      } else {
        String specificError = response.statusCode == 404
            ? 'Diet history not found.'
            : 'Server error: ${response.statusCode}';
        setState(() {
          isLoading = false;
          errorMessage = 'Failed to load diet history: $specificError';
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
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Diet History'),
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
              onPressed: fetchDietHistory,
              tooltip: 'Refresh History',
            ),
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
                        Icon(Icons.error_outline, color: Colors.red, size: 40),
                        SizedBox(height: 10),
                        Text(errorMessage, textAlign: TextAlign.center),
                        SizedBox(height: 10),
                        ElevatedButton.icon(
                          icon: Icon(Icons.refresh),
                          label: Text('Retry'),
                          onPressed: fetchDietHistory,
                          style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                              foregroundColor: Colors.white),
                        )
                      ],
                    ),
                  ))
                : (dietData['days'] as List).isEmpty
                    ? Center(
                        child: Text(
                            'No diet history found.\nGo log some meals!',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 16, color: Colors.grey[600])))
                    : ListView.builder(
                        padding: EdgeInsets.all(16),
                        itemCount: (dietData['days'] as List).length,
                        itemBuilder: (context, dayIndex) {
                          final day = (dietData['days'] as List)[dayIndex]
                                  as Map<String, dynamic>? ??
                              {};
                          final String dayName =
                              day['name'] as String? ?? 'Unknown Day';
                          final List<dynamic> meals =
                              day['meals'] as List<dynamic>? ?? [];
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
                                  if (meals.isEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child: Text("No meals logged.",
                                          style: TextStyle(
                                              fontStyle: FontStyle.italic,
                                              color: Colors.grey[600])),
                                    )
                                  else
                                    ...List.generate(meals.length, (mealIndex) {
                                      final mealMap = meals[mealIndex]
                                              as Map<String, dynamic>? ??
                                          {};
                                      final mealName = mealMap.keys.isNotEmpty
                                          ? mealMap.keys.first
                                          : 'Unknown Meal';
                                      final nutrition = mealMap
                                              .values.isNotEmpty
                                          ? (mealMap.values.first as String? ??
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
                                              mealName,
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                                color: Colors.black87,
                                              ),
                                            ),
                                            if (nutrition.isNotEmpty) ...[
                                              SizedBox(height: 6),
                                              Text(
                                                nutrition,
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
// --- End History Screen Definitions ---
