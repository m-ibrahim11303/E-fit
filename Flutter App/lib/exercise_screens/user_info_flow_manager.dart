import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'user_info_screen.dart';
import 'plan_display_screen.dart';

const String userInfoSubmittedFlagKey = 'userInfoSubmitted';
const String userInfoAgeKey = 'userInfoAge';
const String userInfoWeightKey = 'userInfoWeight';
const String userInfoHeightKey = 'userInfoHeight';
const String userInfoSexKey = 'userInfoSex';
const String userInfoActivityLevelKey = 'userInfoActivityLevel';
const String userInfoGoalKgKey = 'userInfoGoalKg';
const String userInfoApproachRatioKey = 'userInfoApproachRatio';

typedef PlanGeneratedCallback = void Function(Map<String, dynamic> planData);
typedef EditRequestedCallback = void Function();

class UserInfoFlowManager extends StatefulWidget {
  @override
  _UserInfoFlowManagerState createState() => _UserInfoFlowManagerState();
}

class _UserInfoFlowManagerState extends State<UserInfoFlowManager> {
  final storage = FlutterSecureStorage();
  bool _isLoading = true;
  bool _showInputForm = true;
  Map<String, dynamic>? _currentPlanData;

  final Map<int, String> _activityLevelLabels = {
    1: "Sedentary (little/no exercise)",
    2: "Lightly active (1–3 days/week)",
    3: "Moderately active (3–5 days/week)",
    4: "Very active (6–7 days/week)",
    5: "Super active (athlete/training)",
  };
  final Map<int, double> _activityFactors = {
    1: 1.2,
    2: 1.375,
    3: 1.55,
    4: 1.725,
    5: 1.9,
  };

  @override
  void initState() {
    super.initState();
    _checkInitialState();
  }

  Future<void> _checkInitialState() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });

    bool showInput = true;
    Map<String, dynamic>? fetchedPlanData;

    try {
      String? flag = await storage.read(key: userInfoSubmittedFlagKey);
      bool hasSubmittedBefore = flag == 'true';

      if (hasSubmittedBefore) {
        fetchedPlanData = await _fetchStoredInputsAndGeneratePlan();
        if (fetchedPlanData != null) {
          showInput = false;
        } else {
          showInput = true;
        }
      } else {
        showInput = true;
      }
    } catch (e) {
      print("Error during initial state check: $e");
      showInput = true;
      fetchedPlanData = null;
    } finally {
      if (mounted) {
        setState(() {
          _showInputForm = showInput;
          _currentPlanData = fetchedPlanData;
          _isLoading = false;
        });
      }
    }
  }

  Future<Map<String, dynamic>?> _fetchStoredInputsAndGeneratePlan() async {
    String? userEmail;
    Map<String, dynamic>? storedInputs;
    try {
      userEmail = await storage.read(key: 'email');
      if (userEmail == null) {
        print("Error: Email not found in storage.");
        return null;
      }

      Map<String, String?> rawInputs = await storage.readAll();

      int? age = int.tryParse(rawInputs[userInfoAgeKey] ?? '');
      double? weight = double.tryParse(rawInputs[userInfoWeightKey] ?? '');
      double? height = double.tryParse(rawInputs[userInfoHeightKey] ?? '');
      String? sex = rawInputs[userInfoSexKey];
      int? activityLevel =
          int.tryParse(rawInputs[userInfoActivityLevelKey] ?? '');
      double? goalKgPerWeek =
          double.tryParse(rawInputs[userInfoGoalKgKey] ?? '');
      double? approachDietWorkoutRatio =
          double.tryParse(rawInputs[userInfoApproachRatioKey] ?? '');

      if (age == null ||
          weight == null ||
          height == null ||
          sex == null ||
          sex.isEmpty ||
          activityLevel == null ||
          goalKgPerWeek == null ||
          approachDietWorkoutRatio == null) {
        print("Error: Missing or invalid stored user info.");
        print(
            "Age: $age, Weight: $weight, Height: $height, Sex: $sex, Activity: $activityLevel, GoalKg: $goalKgPerWeek, Approach: $approachDietWorkoutRatio");
        return null;
      }

      storedInputs = {
        'age': age,
        'weight': weight,
        'height': height,
        'sex': sex,
        'activityLevel': activityLevel,
        'goalKgPerWeek': goalKgPerWeek,
        'approachDietWorkoutRatio': approachDietWorkoutRatio,
      };
    } catch (e) {
      print("Error reading stored inputs: $e");
      return null;
    }

    double bmr = _calculateBMRForInputs(storedInputs);
    double tdee = _calculateTDEEForInputs(storedInputs, _activityFactors);

    if (bmr <= 0 || tdee <= 0) {
      print("Error: Calculated BMR ($bmr) or TDEE ($tdee) is invalid.");
      return null;
    }

    Map<String, int> calorieTargets =
        _calculateCalorieTargetsForInputs(storedInputs, tdee);

    String goalString;
    double goalKg = storedInputs['goalKgPerWeek'];
    if (goalKg < -0.1) {
      goalString = "Lose Weight";
    } else if (goalKg > 0.1) {
      goalString = "Gain Muscle";
    } else {
      goalString = "Maintain Weight";
    }

    int activityLevelValue = storedInputs['activityLevel'];
    String activityLevelString =
        _activityLevelLabels[activityLevelValue] ?? "Moderately active";

    final Map<String, dynamic> requestData = {
      "email": userEmail,
      "BMR": bmr.round(),
      "TDEE": tdee.round(),
      "caloriesToEat": calorieTargets['eat'],
      "caloriesToBurn": calorieTargets['burn'],
      "age": storedInputs['age'],
      "weight": storedInputs['weight'],
      "height": storedInputs['height'],
      "sex": storedInputs['sex'],
      "activityLevel": activityLevelString,
      "goal": goalString,
    };

    print("Regenerating plan with data: ${jsonEncode(requestData)}");

    final url = Uri.parse('https://e-fit-backend.onrender.com/ai/generate');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode(requestData),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        if (responseData['plan'] != null &&
            responseData['plan'] is Map<String, dynamic>) {
          print("Plan regeneration successful.");
          return responseData['plan'];
        } else {
          print(
              'Error: Plan data missing or invalid in API response during regeneration.');
          return null;
        }
      } else {
        print(
            'Error regenerating plan via API: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print("Network or parsing error regenerating plan: $e");
      return null;
    }
  }

  double _calculateBMRForInputs(Map<String, dynamic> inputs) {
    int? age = inputs['age'];
    double? weight = inputs['weight'];
    double? height = inputs['height'];
    String? sex = inputs['sex'];

    if (age == null || weight == null || height == null || sex == null)
      return 0;

    if (sex == 'Male') {
      return (10 * weight) + (6.25 * height) - (5 * age) + 5;
    } else if (sex == 'Female') {
      return (10 * weight) + (6.25 * height) - (5 * age) - 161;
    }
    return 0;
  }

  double _calculateTDEEForInputs(
      Map<String, dynamic> inputs, Map<int, double> activityFactors) {
    double bmr = _calculateBMRForInputs(inputs);
    if (bmr <= 0) return 0;
    int? activityLevel = inputs['activityLevel'];
    if (activityLevel == null) return 0;
    double activityFactor = activityFactors[activityLevel] ?? 1.2;
    return bmr * activityFactor;
  }

  Map<String, int> _calculateCalorieTargetsForInputs(
      Map<String, dynamic> inputs, double tdee) {
    double? goalKgPerWeek = inputs['goalKgPerWeek'];
    double? approachDietWorkoutRatio = inputs['approachDietWorkoutRatio'];

    if (goalKgPerWeek == null ||
        approachDietWorkoutRatio == null ||
        tdee <= 0) {
      print(
          "Warning: Missing goal/approach data or invalid TDEE ($tdee) for calorie target calculation. Returning defaults.");
      return {'eat': 2000, 'burn': 200};
    }

    double calorieChangePerWeek = goalKgPerWeek * 7700;
    double calorieChangePerDay = calorieChangePerWeek / 7;
    double dietAdjustment =
        (1 - approachDietWorkoutRatio) * calorieChangePerDay;
    double workoutAdjustment = approachDietWorkoutRatio * calorieChangePerDay;

    int caloriesToEat = (tdee + dietAdjustment).round().clamp(1200, 6000);

    int baseBurn = 250;
    int caloriesToBurn;
    if (goalKgPerWeek == 0) {
      caloriesToBurn = baseBurn;
    } else {
      caloriesToBurn = (workoutAdjustment.abs()).round();
    }
    caloriesToBurn = caloriesToBurn.clamp(100, 1500);

    return {'eat': caloriesToEat, 'burn': caloriesToBurn};
  }

  void _handlePlanGenerated(Map<String, dynamic> newPlanData) async {
    try {
      await storage.write(key: userInfoSubmittedFlagKey, value: 'true');
      print("User info submitted flag set.");

      if (mounted) {
        setState(() {
          _currentPlanData = newPlanData;
          _showInputForm = false;
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Error saving flag after plan generation: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving preference. Plan generated.')),
        );
        setState(() {
          _currentPlanData = newPlanData;
          _showInputForm = false;
          _isLoading = false;
        });
      }
    }
  }

  void _handleEditRequested() {
    print("Edit requested. Showing input form.");
    if (mounted) {
      setState(() {
        _showInputForm = true;
        _currentPlanData = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context)),
          title: Text("Loading Your Info..."),
          backgroundColor: Color(0xFF562634),
          foregroundColor: Colors.white,
        ),
        body:
            Center(child: CircularProgressIndicator(color: Color(0xFF562634))),
      );
    }

    if (_showInputForm) {
      return UserInfoScreen(onPlanGenerated: _handlePlanGenerated);
    } else {
      if (_currentPlanData != null) {
        return PlanDisplayScreen(
          planData: _currentPlanData!,
          onEditRequested: _handleEditRequested,
        );
      } else {
        return Scaffold(
          appBar: AppBar(
            title: Text("Plan Unavailable"),
            backgroundColor: Color(0xFF562634),
            foregroundColor: Colors.white,
            actions: [
              IconButton(
                icon: Icon(Icons.edit),
                tooltip: 'Edit Details',
                onPressed: _handleEditRequested,
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
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, color: Colors.red[700], size: 50),
                  SizedBox(height: 15),
                  Text(
                    "We couldn't load or regenerate your plan based on previously saved details.",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.grey[800]),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Please tap the edit icon (✎) in the top bar to re-enter your details.",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 15, color: Colors.grey[700]),
                  ),
                ],
              ),
            )),
          ),
        );
      }
    }
  }
}
