import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'user_info_flow_manager.dart';

class UserInfoScreen extends StatefulWidget {
  final PlanGeneratedCallback onPlanGenerated;

  UserInfoScreen({Key? key, required this.onPlanGenerated}) : super(key: key);

  @override
  _UserInfoScreenState createState() => _UserInfoScreenState();
}

class _UserInfoScreenState extends State<UserInfoScreen> {
  final _formKey = GlobalKey<FormState>();
  int? _age;
  double? _weight;
  double? _height;
  String? _selectedSex;

  int _activityLevel = 3;
  double _goalKgPerWeek = 0.0;
  double _approachDietWorkoutRatio = 0.5;

  bool _isLoading = false;
  final storage = FlutterSecureStorage();

  final List<String> _sexOptions = ['Male', 'Female'];

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

  double _calculateBMR() {
    if (_age == null ||
        _weight == null ||
        _height == null ||
        _selectedSex == null) return 0;
    if (_selectedSex == 'Male') {
      return (10 * _weight!) + (6.25 * _height!) - (5 * _age!) + 5;
    } else if (_selectedSex == 'Female') {
      return (10 * _weight!) + (6.25 * _height!) - (5 * _age!) - 161;
    }
    return 0;
  }

  double _calculateTDEE() {
    double bmr = _calculateBMR();
    if (bmr <= 0) return 0;
    double activityFactor = _activityFactors[_activityLevel] ?? 1.2;
    return bmr * activityFactor;
  }

  Map<String, int> _calculateCalorieTargets(double tdee) {
    if (tdee <= 0) return {'eat': 2000, 'burn': 200};
    double calorieChangePerWeek = _goalKgPerWeek * 7700;
    double calorieChangePerDay = calorieChangePerWeek / 7;
    double dietAdjustment =
        (1 - _approachDietWorkoutRatio) * calorieChangePerDay;
    double workoutAdjustment = _approachDietWorkoutRatio * calorieChangePerDay;
    int caloriesToEat = (tdee + dietAdjustment).round().clamp(1200, 6000);
    int baseBurn = 250;
    int caloriesToBurn;
    if (_goalKgPerWeek == 0) {
      caloriesToBurn = baseBurn;
    } else {
      caloriesToBurn = (workoutAdjustment.abs()).round();
    }
    caloriesToBurn = caloriesToBurn.clamp(100, 1500);
    return {'eat': caloriesToEat, 'burn': caloriesToBurn};
  }

  Future<bool> _storeUserInfo() async {
    if (_age == null ||
        _weight == null ||
        _height == null ||
        _selectedSex == null) return false;
    try {
      await storage.write(key: userInfoAgeKey, value: _age!.toString());
      await storage.write(key: userInfoWeightKey, value: _weight!.toString());
      await storage.write(key: userInfoHeightKey, value: _height!.toString());
      await storage.write(key: userInfoSexKey, value: _selectedSex!);
      await storage.write(
          key: userInfoActivityLevelKey, value: _activityLevel.toString());
      await storage.write(
          key: userInfoGoalKgKey, value: _goalKgPerWeek.toString());
      await storage.write(
          key: userInfoApproachRatioKey,
          value: _approachDietWorkoutRatio.toString());
      return true;
    } catch (e) {
      print("Error storing user info: $e");
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error saving details.')));
      }
      return false;
    }
  }

  Future<void> _generatePlan() async {
    if (!_formKey.currentState!.validate()) return;
    if (!mounted) return;
    setState(() => _isLoading = true);

    bool stored = await _storeUserInfo();
    if (!stored) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    String? userEmail = await storage.read(key: 'email');
    if (userEmail == null) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: Email not found.')));
        setState(() => _isLoading = false);
      }
      return;
    }

    double bmr = _calculateBMR();
    double tdee = _calculateTDEE();
    if (bmr <= 0 || tdee <= 0) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Please check all inputs.')));
        setState(() => _isLoading = false);
      }
      return;
    }
    Map<String, int> calorieTargets = _calculateCalorieTargets(tdee);

    String goalString;
    if (_goalKgPerWeek < -0.1)
      goalString = "Lose Weight";
    else if (_goalKgPerWeek > 0.1)
      goalString = "Gain Muscle";
    else
      goalString = "Maintain Weight";

    final Map<String, dynamic> requestData = {
      "email": userEmail,
      "BMR": bmr.round(),
      "TDEE": tdee.round(),
      "caloriesToEat": calorieTargets['eat'],
      "caloriesToBurn": calorieTargets['burn'],
      "age": _age,
      "weight": _weight,
      "height": _height,
      "sex": _selectedSex,
      "activityLevel": _activityLevelLabels[_activityLevel] ?? "Unknown",
      "goal": goalString,
    };

    final url = Uri.parse('https://e-fit-backend.onrender.com/ai/generate');
    try {
      final response = await http.post(url,
          headers: {'Content-Type': 'application/json; charset=UTF-8'},
          body: jsonEncode(requestData));
      if (!mounted) return;
      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        if (responseData['plan'] != null &&
            responseData['plan'] is Map<String, dynamic>) {
          widget.onPlanGenerated(responseData['plan']);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error: Invalid plan data received.')));
        }
      } else {
        String errorMessage = 'Error generating plan (${response.statusCode}).';
        try {
          Map<String, dynamic> errorBody = jsonDecode(response.body);
          if (errorBody['message'] != null)
            errorMessage += ' ${errorBody['message']}';
        } catch (_) {}
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(errorMessage)));
      }
    } catch (error) {
      if (mounted)
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Network error: $error')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _buildTextField({
    required String label,
    required TextInputType keyboardType,
    required ValueChanged<String> onChanged,
    String? Function(String?)? validator,
    List<TextInputFormatter>? inputFormatters,
    String? initialValue,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        initialValue: initialValue,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
          filled: true,
          fillColor: Colors.white.withOpacity(0.7),
        ),
        keyboardType: keyboardType,
        onChanged: onChanged,
        validator: validator,
        inputFormatters: inputFormatters,
      ),
    );
  }

  Widget _buildDropdownField() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: 'Sex (Required for Calculation)',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
          filled: true,
          fillColor: Colors.white.withOpacity(0.7),
        ),
        value: _selectedSex,
        hint: Text('Select Sex'),
        onChanged: (String? newValue) =>
            setState(() => _selectedSex = newValue),
        items: _sexOptions
            .map<DropdownMenuItem<String>>((String value) =>
                DropdownMenuItem<String>(value: value, child: Text(value)))
            .toList(),
        validator: (value) => value == null ? 'Please select sex' : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    String currentActivityLabel =
        _activityLevelLabels[_activityLevel] ?? "Unknown";

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context)),
        title: Text('Tell Us About You'),
        backgroundColor: Color(0xFF562634),
        foregroundColor: Colors.white,
        automaticallyImplyLeading: Navigator.canPop(context),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.amber[50]!, Colors.red[50]!],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: 10),
                  _buildTextField(
                    label: 'Age',
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    onChanged: (value) => _age = int.tryParse(value),
                    validator: (v) => (v == null || v.isEmpty)
                        ? 'Age?'
                        : ((int.tryParse(v) ?? 0) <= 10 ||
                                (int.tryParse(v) ?? 999) > 120)
                            ? 'Age: 11-120'
                            : null,
                  ),
                  _buildTextField(
                    label: 'Weight (kg)',
                    keyboardType:
                        TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                          RegExp(r'^\d+\.?\d{0,1}'))
                    ],
                    onChanged: (value) => _weight = double.tryParse(value),
                    validator: (v) => (v == null || v.isEmpty)
                        ? 'Weight?'
                        : ((double.tryParse(v) ?? 0) <= 20 ||
                                (double.tryParse(v) ?? 999) > 300)
                            ? 'Weight: 20-300 kg'
                            : null,
                  ),
                  _buildTextField(
                    label: 'Height (cm)',
                    keyboardType:
                        TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                          RegExp(r'^\d+\.?\d{0,1}'))
                    ],
                    onChanged: (value) => _height = double.tryParse(value),
                    validator: (v) => (v == null || v.isEmpty)
                        ? 'Height?'
                        : ((double.tryParse(v) ?? 0) <= 50 ||
                                (double.tryParse(v) ?? 999) > 250)
                            ? 'Height: 50-250 cm'
                            : null,
                  ),
                  _buildDropdownField(),
                  SizedBox(height: 20),
                  Text(
                    "Activity Level: $currentActivityLabel",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  Slider(
                    min: 1,
                    max: 5,
                    divisions: 4,
                    value: _activityLevel.toDouble(),
                    label: currentActivityLabel,
                    onChanged: (val) =>
                        setState(() => _activityLevel = val.round()),
                    activeColor: Color(0xFF562634),
                    inactiveColor: Color(0xFF562634).withOpacity(0.3),
                  ),
                  SizedBox(height: 20),
                  Text(
                    "Goal (kg/week): ${_goalKgPerWeek.toStringAsFixed(1)}",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  Slider(
                    min: -1.5,
                    max: 1.5,
                    divisions: 30,
                    label: "${_goalKgPerWeek.toStringAsFixed(1)}",
                    value: _goalKgPerWeek,
                    onChanged: (val) => setState(() => _goalKgPerWeek = val),
                    activeColor: Color(0xFF562634),
                    inactiveColor: Color(0xFF562634).withOpacity(0.3),
                  ),
                  SizedBox(height: 20),
                  Text(
                    "Approach (0 = diet, 1 = workout): ${_approachDietWorkoutRatio.toStringAsFixed(2)}",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  Slider(
                    min: 0.05,
                    max: 0.95,
                    divisions: 18,
                    label: "${_approachDietWorkoutRatio.toStringAsFixed(2)}",
                    value: _approachDietWorkoutRatio,
                    onChanged: (val) =>
                        setState(() => _approachDietWorkoutRatio = val),
                    activeColor: Color(0xFF562634),
                    inactiveColor: Color(0xFF562634).withOpacity(0.3),
                  ),
                  SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _generatePlan,
                    child: _isLoading
                        ? SizedBox(
                            height: 20.0,
                            width: 20.0,
                            child: CircularProgressIndicator(
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                                strokeWidth: 2.0))
                        : Text('Generate Plan'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF562634),
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 15),
                      textStyle: TextStyle(fontSize: 18),
                      disabledBackgroundColor:
                          Color(0xFF562634).withOpacity(0.5),
                    ),
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
