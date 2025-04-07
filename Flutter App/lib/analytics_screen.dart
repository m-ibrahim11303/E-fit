import 'package:flutter/material.dart';

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
                              child: Image.network(
                                imageUrls[0],
                                fit: BoxFit.cover,
                                loadingBuilder: (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Center(child: CircularProgressIndicator());
                                },
                              ),
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 8.0),
                              child: Image.network(
                                imageUrls[1],
                                fit: BoxFit.cover,
                                loadingBuilder: (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Center(child: CircularProgressIndicator());
                                },
                              ),
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 8.0),
                              child: Image.network(
                                imageUrls[2],
                                fit: BoxFit.cover,
                                loadingBuilder: (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Center(child: CircularProgressIndicator());
                                },
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
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _CustomButton(
                      icon: Icons.fitness_center,
                      label: 'Workout\nHistory',
                      color: Color(0xFF562634),
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => WorkoutHistoryScreen()),
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

// Explicitly declared workout data
const Map<String, dynamic> workoutData = {
  "numberOfDays": 3,
  "days": [
    {
      "name": "Today",
      "noOfExercises": 3,
      "exercises": [
        {"Running": "Set 1: 10 minutes\n"},
        {"Bench Press": "Set 1: 12 reps\nSet 2: 10 reps\nSet 3: 8 reps"},
        {"Incline Dumbbell Press": "Set 1: 12 reps"}
      ]
    },
    {
      "name": "Thursday",
      "noOfExercises": 1,
      "exercises": [
        {"Bench Press": "Set 1: 12 reps\nSet 2: 10 reps\nSet 3: 8 reps"}
      ]
    },
    {
      "name": "Wednesday",
      "noOfExercises": 2,
      "exercises": [
        {"Running": "Set 1: 10 minutes\n"},
        {"Bench Press": "Set 1: 12 reps\nSet 2: 10 reps\nSet 3: 8 reps"}
      ]
    }
  ]
};

class WorkoutHistoryScreen extends StatelessWidget {
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
        child: ListView.builder(
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
                    ...List.generate(day['exercises'].length, (exerciseIndex) {
                      final exercise = day['exercises'][exerciseIndex];
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
                          crossAxisAlignment: CrossAxisAlignment.start,
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

// Diet History Data
const Map<String, dynamic> dietData = {
  "numberOfDays": 1,
  "days": [
    {
      "name": "Today",
      "noOfMeals": 3,
      "meals": [
        {
          "PDC - Eggs and paratha": "Calories(kcal): 700\nProtein(grams): 35\n"
        },
        {
          "Chicken and pasta": "Calories(kcal): 700\nProtein(grams): 35\n"
        },
        {
          "Panini": "Calories(kcal): 700\nProtein(grams): 35\n"
        }
      ]
    }
  ]
};

// Diet History Screen
class DietHistoryScreen extends StatelessWidget {
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
        child: ListView.builder(
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
                    ...List.generate(day['meals'].length, (mealIndex) {
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
                          crossAxisAlignment: CrossAxisAlignment.start,
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

// Add this button next to your Workout History button:
