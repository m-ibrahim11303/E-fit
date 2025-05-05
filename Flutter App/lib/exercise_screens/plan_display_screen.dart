import 'package:flutter/material.dart';
import 'package:login_signup_1/style.dart';
import 'user_info_flow_manager.dart';

class PlanDisplayScreen extends StatelessWidget {
  final Map<String, dynamic> planData;
  final EditRequestedCallback onEditRequested;

  const PlanDisplayScreen({
    Key? key,
    required this.planData,
    required this.onEditRequested,
  }) : super(key: key);

  String _formatExerciseDetails(Map<String, dynamic> exercise) {
    String details = '';
    if (exercise.containsKey('sets') && exercise.containsKey('reps')) {
      details += '${exercise['sets']} sets x ${exercise['reps']} reps';
    } else if (exercise.containsKey('time')) {
      int s = exercise['time'] ?? 0, m = s ~/ 60, r = s % 60;
      if (m > 0) details += '$m min ';
      if (r > 0) details += '$r sec';
      if (details.isEmpty) details = 'Time?';
    }
    int cal = exercise['calories_burned'] as int? ?? 0;
    return details.isNotEmpty ? '$details ($cal kcal)' : '($cal kcal)';
  }

  @override
  Widget build(BuildContext context) {
    final List<dynamic> dietItems = planData['diet'] as List<dynamic>? ?? [];
    final List<dynamic> exerciseItems =
        planData['exercises'] as List<dynamic>? ?? [];
    int totalDietCalories =
        dietItems.fold(0, (sum, item) => sum + (item['calories'] as int? ?? 0));
    int totalDietProteins =
        dietItems.fold(0, (sum, item) => sum + (item['proteins'] as int? ?? 0));
    int totalExerciseCalories = exerciseItems.fold(
        0, (sum, item) => sum + (item['calories_burned'] as int? ?? 0));

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context)),
        title: Text('Your Generated Plan'),
        backgroundColor: darkMaroon,
        foregroundColor: brightWhite,
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            tooltip: 'Edit Details',
            onPressed: onEditRequested,
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
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            Text('Daily Diet Plan',
                style: TextStyle(
                    fontFamily: "Jersey 25",
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: darkMaroon)),
            SizedBox(height: 8),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (dietItems.isEmpty)
                      Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text("No diet items generated.",
                              style: TextStyle(fontStyle: FontStyle.italic, fontFamily: "Jersey 25"))),
                    ...dietItems
                        .map((item) => ListTile(
                              leading: Icon(Icons.restaurant_menu,
                                  color: Colors.orange[700]),
                              title: Text(item['name'] ?? 'Item?',
                                  style:
                                      TextStyle(fontWeight: FontWeight.w500, fontFamily: "Jersey 25")),
                              trailing: Text(
                                  '${item['calories'] ?? 0}kcal/${item['proteins'] ?? 0}g P',
                                  style: TextStyle(color: Colors.grey[700], fontFamily: "Jersey 25")),
                            ))
                        .toList(),
                    if (dietItems.isNotEmpty) Divider(),
                    if (dietItems.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0, right: 16.0),
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                              'Total: $totalDietCalories kcal / ${totalDietProteins}g Protein',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 15, fontFamily: "Jersey 25")),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 24),
            Text('Daily Exercise Plan',
                style: TextStyle(
                    fontFamily: "Jersey 25",
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: darkMaroon)),
            SizedBox(height: 8),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (exerciseItems.isEmpty)
                      Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text("No exercises generated.",
                              style: TextStyle(fontStyle: FontStyle.italic, fontFamily: "Jersey 25"))),
                    ...exerciseItems
                        .map((item) => ListTile(
                              leading: Icon(Icons.fitness_center,
                                  color: Colors.blue[700]),
                              title: Text(item['name'] ?? 'Exercise?',
                                  style:
                                      TextStyle(fontWeight: FontWeight.w500, fontFamily: "Jersey 25")),
                              subtitle: Text(_formatExerciseDetails(
                                  item as Map<String, dynamic>)),
                            ))
                        .toList(),
                    if (exerciseItems.isNotEmpty) Divider(),
                    if (exerciseItems.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0, right: 16.0),
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Text('Total Burn: $totalExerciseCalories kcal',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 15, fontFamily: "Jersey 25")),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
