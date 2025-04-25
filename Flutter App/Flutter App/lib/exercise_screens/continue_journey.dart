import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For TextInputFormatter
import 'dart:convert'; // For jsonDecode, jsonEncode
import 'package:http/http.dart' as http; // For HTTP requests
import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // For Secure Storage

// --- Storage Keys ---
const String userInfoSubmittedFlagKey = 'userInfoSubmitted';
// Keys for storing individual inputs
const String userInfoAgeKey = 'userInfoAge';
const String userInfoWeightKey = 'userInfoWeight';
const String userInfoHeightKey = 'userInfoHeight';
const String userInfoSexKey = 'userInfoSex';
const String userInfoActivityLevelKey = 'userInfoActivityLevel';
const String userInfoWeeklyGoalKey = 'userInfoWeeklyGoal';
const String userInfoApproachBalanceKey = 'userInfoApproachBalance';

// Define the Callback Types needed across classes
typedef PlanGeneratedCallback = void Function(Map<String, dynamic> planData);
typedef EditRequestedCallback = void Function();

// ==========================================================================
// 1. UserInfoFlowManager Widget (Controls which screen to show)
// ==========================================================================
class UserInfoFlowManager extends StatefulWidget {
  @override
  _UserInfoFlowManagerState createState() => _UserInfoFlowManagerState();
}

class _UserInfoFlowManagerState extends State<UserInfoFlowManager> {
  final storage = FlutterSecureStorage();
  bool _isLoading = true;
  bool _showInputForm = true; // Start assuming first time
  Map<String, dynamic>? _currentPlanData; // To hold fetched/generated plan

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

    bool showInput = true; // Default to showing input
    Map<String, dynamic>? fetchedPlanData;

    try {
      // 1. Check the flag first
      String? flag = await storage.read(key: userInfoSubmittedFlagKey);
      bool hasSubmittedBefore = flag == 'true';

      if (hasSubmittedBefore) {
        // If the flag exists, INTEND to show the plan screen.
        showInput = false;
        print(
            "User has submitted before. Attempting to regenerate plan from stored inputs...");
        // 2. Fetch stored inputs and regenerate the plan
        fetchedPlanData = await _fetchStoredInputsAndGeneratePlan();

        if (fetchedPlanData == null) {
          print(
              "Could not regenerate plan from stored inputs. Plan screen will show error state.");
          // Build method will handle showing the error screen
        } else {
          print("Plan regenerated successfully from stored inputs.");
        }
      } else {
        // First time user, definitely show input
        print("First time user or flag not set.");
        showInput = true;
      }
    } catch (e) {
      print("Error during initial state check: $e");
      showInput = true; // Fallback to input form on error
      fetchedPlanData = null;
    } finally {
      // Update the state *once*
      if (mounted) {
        setState(() {
          _showInputForm = showInput;
          _currentPlanData = fetchedPlanData;
          _isLoading = false;
        });
      }
    }
  }

  // --- New Method: Fetch Stored Inputs and Call Generate API ---
  Future<Map<String, dynamic>?> _fetchStoredInputsAndGeneratePlan() async {
    print("Fetching stored user inputs...");
    String? userEmail;
    Map<String, dynamic>? storedInputs;
    try {
      // Fetch email first (essential)
      userEmail = await storage.read(key: 'email');
      if (userEmail == null) {
        print("Cannot generate plan: Email not found in storage.");
        return null;
      }

      // Fetch all required inputs
      Map<String, String?> rawInputs = await storage.readAll(
          // Optionally specify keys if needed, but readAll is often fine here
          );

      // Validate and parse stored inputs
      int? age = int.tryParse(rawInputs[userInfoAgeKey] ?? '');
      double? weight = double.tryParse(rawInputs[userInfoWeightKey] ?? '');
      double? height = double.tryParse(rawInputs[userInfoHeightKey] ?? '');
      String? sex = rawInputs[userInfoSexKey];
      double? activityLevelValue =
          double.tryParse(rawInputs[userInfoActivityLevelKey] ?? '');
      double? weeklyGoalValue =
          double.tryParse(rawInputs[userInfoWeeklyGoalKey] ?? '');
      // double? approachBalanceValue = double.tryParse(rawInputs[userInfoApproachBalanceKey] ?? ''); // If needed

      // --- Basic Validation ---
      if (age == null ||
          weight == null ||
          height == null ||
          sex == null ||
          sex.isEmpty ||
          activityLevelValue == null ||
          weeklyGoalValue == null) {
        print("Stored input data is incomplete or invalid.");
        // Optionally: Clear the flag and stored inputs? Or just return null?
        // await storage.delete(key: userInfoSubmittedFlagKey); // Example: Force re-entry
        return null;
      }

      // Store parsed inputs for BMR/TDEE calculation
      storedInputs = {
        'age': age,
        'weight': weight,
        'height': height,
        'sex': sex,
        'activityLevelValue': activityLevelValue,
        'weeklyGoalValue': weeklyGoalValue,
        // 'approachBalanceValue': approachBalanceValue,
      };
    } catch (e) {
      print("Error reading stored inputs: $e");
      return null;
    }

    // --- Calculate BMR/TDEE based on stored inputs ---
    // Note: We need the mapping from slider value to factor/label again here
    final List<String> activityLabels = [
      'Sedentary',
      'Light',
      'Moderate',
      'Active',
      'Very Active'
    ];
    final List<double> activityFactors = [1.2, 1.375, 1.55, 1.725, 1.9];
    final List<String> goalLabels = [
      'Lose Weight',
      'Maintain Weight',
      'Gain Muscle'
    ];

    double bmr = _calculateBMRForInputs(storedInputs);
    double tdee = _calculateTDEEForInputs(storedInputs, activityFactors);

    if (bmr == 0 || tdee == 0) {
      print("Could not calculate BMR/TDEE from stored inputs.");
      return null;
    }

    Map<String, int> calorieTargets =
        _calculateCalorieTargetsForInputs(storedInputs, tdee);

    // --- Prepare API Payload ---
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
      // Convert slider values back to labels for the API
      "activityLevel": activityLabels[storedInputs['activityLevelValue']!
          .round()
          .clamp(0, activityLabels.length - 1)],
      "goal": goalLabels[storedInputs['weeklyGoalValue']!
          .round()
          .clamp(0, goalLabels.length - 1)],
      // Include other fields if your backend requires them
    };

    print("Regenerating plan with payload: $requestData");

    // --- Call Generate API ---
    final url = Uri.parse('https://e-fit-backend.onrender.com/ai/generate');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode(requestData),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        print("Plan regenerated via API successfully.");
        return responseData['plan']
            as Map<String, dynamic>?; // Return the plan part
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

  // --- Calculation Helpers adapted for stored data map ---
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
      Map<String, dynamic> inputs, List<double> activityFactors) {
    double bmr = _calculateBMRForInputs(inputs);
    if (bmr == 0) return 0;
    double? activityLevelValue = inputs['activityLevelValue'];
    if (activityLevelValue == null) return 0;

    int activityIndex =
        activityLevelValue.round().clamp(0, activityFactors.length - 1);
    double activityFactor = activityFactors[activityIndex];
    return bmr * activityFactor;
  }

  Map<String, int> _calculateCalorieTargetsForInputs(
      Map<String, dynamic> inputs, double tdee) {
    double? weeklyGoalValue = inputs['weeklyGoalValue'];
    if (weeklyGoalValue == null || tdee == 0) {
      return {'eat': 2000, 'burn': 200}; // Fallback
    }

    int goalIndex = weeklyGoalValue.round().clamp(0, 2); // Assuming 3 goals
    int caloriesToEat;
    int caloriesToBurn;
    int baseBurn = 250;

    switch (goalIndex) {
      case 0: // Lose Weight
        caloriesToEat = (tdee - 500).round().clamp(1200, 5000);
        caloriesToBurn = (baseBurn + 150).clamp(100, 1000);
        break;
      case 2: // Gain Muscle
        caloriesToEat = (tdee + 300).round().clamp(1200, 5000);
        caloriesToBurn = baseBurn.clamp(100, 1000);
        break;
      case 1: // Maintain Weight
      default:
        caloriesToEat = tdee.round().clamp(1200, 5000);
        caloriesToBurn = baseBurn.clamp(100, 1000);
        break;
    }
    return {'eat': caloriesToEat, 'burn': caloriesToBurn};
  }

  // Callback from UserInfoScreen when a plan is *first* generated
  void _handlePlanGenerated(Map<String, dynamic> newPlanData) async {
    try {
      // Set the flag *only after* successful generation from input screen
      await storage.write(key: userInfoSubmittedFlagKey, value: 'true');
      print("UserInfoSubmitted flag set.");

      if (mounted) {
        setState(() {
          _currentPlanData = newPlanData;
          _showInputForm = false; // Switch to display screen
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Error saving flag after plan generation: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving preference. Plan generated.')),
        );
        // Still show the plan
        setState(() {
          _currentPlanData = newPlanData;
          _showInputForm = false;
          _isLoading = false;
        });
      }
    }
  }

  // Callback from PlanDisplayScreen when edit is requested
  void _handleEditRequested() {
    if (mounted) {
      setState(() {
        _showInputForm = true; // Switch back to input form
        // Clear plan data, it will be regenerated on next load or submit
        _currentPlanData = null;
        // Keep the flag and stored inputs - let next submit overwrite
      });
    }
  }

  // --- Build Method (Same as previous revision) ---
  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text("Loading Your Info..."),
          backgroundColor: Color(0xFF562634),
          foregroundColor: Colors.white,
        ),
        body:
            Center(child: CircularProgressIndicator(color: Color(0xFF562634))),
      );
    }

    if (_showInputForm) {
      // Show Input Form
      return UserInfoScreen(onPlanGenerated: _handlePlanGenerated);
    } else {
      // Intend to show Plan Display
      if (_currentPlanData != null) {
        // Data is ready, show the actual plan
        return PlanDisplayScreen(
          planData: _currentPlanData!,
          onEditRequested: _handleEditRequested,
        );
      } else {
        // Data fetch/regeneration failed, but user *has* submitted before.
        print("Showing plan display structure, but data regeneration failed.");
        return Scaffold(
          appBar: AppBar(
            title: Text("Plan Unavailable"),
            backgroundColor: Color(0xFF562634),
            foregroundColor: Colors.white,
            actions: [
              IconButton(
                icon: Icon(Icons.edit),
                tooltip: 'Edit Details',
                onPressed: _handleEditRequested, // Switch back to input form
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
              child: Text(
                "Could not load or regenerate your plan based on previously saved details. Please try editing your details.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey[700]),
              ),
            )),
          ),
        );
      }
    }
  }
}

// ==========================================================================
// 2. UserInfoScreen Widget (The Input Form)
// ==========================================================================
class UserInfoScreen extends StatefulWidget {
  final PlanGeneratedCallback onPlanGenerated;

  UserInfoScreen({Key? key, required this.onPlanGenerated}) : super(key: key);

  @override
  _UserInfoScreenState createState() => _UserInfoScreenState();
}

class _UserInfoScreenState extends State<UserInfoScreen> {
  final _formKey = GlobalKey<FormState>();
  // State variables for inputs
  int? _age;
  double? _weight;
  double? _height;
  String? _selectedSex;
  double _activityLevel = 2; // Default index/value for Moderate
  double _weeklyGoal = 1; // Default index/value for Maintain Weight
  double _approachBalance = 1; // Default index/value for Balanced

  bool _isLoading = false;
  final storage = FlutterSecureStorage();

  // Definitions for sliders/dropdowns (keep these)
  final List<String> _sexOptions = ['Male', 'Female'];
  final List<String> _activityLabels = [
    'Sedentary',
    'Light',
    'Moderate',
    'Active',
    'Very Active'
  ];
  final List<double> _activityFactors = [1.2, 1.375, 1.55, 1.725, 1.9];
  final List<String> _goalLabels = [
    'Lose Weight',
    'Maintain Weight',
    'Gain Muscle'
  ];
  final List<String> _approachLabels = ['Gentle', 'Balanced', 'Intense'];

  // --- Calculation Helpers (Keep as they were) ---
  double _calculateBMR() {
    if (_age == null ||
        _weight == null ||
        _height == null ||
        _selectedSex == null) return 0;
    if (_selectedSex == 'Male')
      return (10 * _weight!) + (6.25 * _height!) - (5 * _age!) + 5;
    if (_selectedSex == 'Female')
      return (10 * _weight!) + (6.25 * _height!) - (5 * _age!) - 161;
    return 0;
  }

  double _calculateTDEE() {
    double bmr = _calculateBMR();
    if (bmr == 0) return 0;
    int activityIndex =
        _activityLevel.round().clamp(0, _activityFactors.length - 1);
    return bmr * _activityFactors[activityIndex];
  }

  Map<String, int> _calculateCalorieTargets(double tdee) {
    int goalIndex = _weeklyGoal.round().clamp(0, _goalLabels.length - 1);
    int caloriesToEat;
    int caloriesToBurn;
    int baseBurn = 250;
    if (tdee == 0) return {'eat': 2000, 'burn': 200};
    switch (goalIndex) {
      case 0:
        caloriesToEat = (tdee - 500).round().clamp(1200, 5000);
        caloriesToBurn = (baseBurn + 150).clamp(100, 1000);
        break;
      case 2:
        caloriesToEat = (tdee + 300).round().clamp(1200, 5000);
        caloriesToBurn = baseBurn.clamp(100, 1000);
        break;
      case 1:
      default:
        caloriesToEat = tdee.round().clamp(1200, 5000);
        caloriesToBurn = baseBurn.clamp(100, 1000);
        break;
    }
    return {'eat': caloriesToEat, 'burn': caloriesToBurn};
  }

  // --- Method to Store User Inputs ---
  Future<bool> _storeUserInfo() async {
    // Only store if inputs are valid (redundant check, but safe)
    if (_age == null ||
        _weight == null ||
        _height == null ||
        _selectedSex == null) {
      print("Cannot store info: inputs are incomplete.");
      return false;
    }
    try {
      print("Storing user inputs...");
      await storage.write(key: userInfoAgeKey, value: _age!.toString());
      await storage.write(key: userInfoWeightKey, value: _weight!.toString());
      await storage.write(key: userInfoHeightKey, value: _height!.toString());
      await storage.write(key: userInfoSexKey, value: _selectedSex!);
      await storage.write(
          key: userInfoActivityLevelKey, value: _activityLevel.toString());
      await storage.write(
          key: userInfoWeeklyGoalKey, value: _weeklyGoal.toString());
      await storage.write(
          key: userInfoApproachBalanceKey, value: _approachBalance.toString());
      print("Inputs stored successfully.");
      return true;
    } catch (e) {
      print("Error storing user info: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error saving your details. Please try again.')),
        );
      }
      return false;
    }
  }

  // --- API Call ---
  Future<void> _generatePlan() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });

    // --- Store Inputs Before Calling API ---
    bool stored = await _storeUserInfo();
    if (!stored) {
      // Stop if inputs couldn't be stored
      if (mounted)
        setState(() {
          _isLoading = false;
        });
      return;
    }
    // --- End Storing Inputs ---

    String? userEmail;
    try {
      userEmail = await storage.read(key: 'email');
      if (userEmail == null) throw Exception("Email not found. Please log in.");
    } catch (e) {
      print("Error reading email: $e");
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error fetching email: $e')));
        setState(() => _isLoading = false);
      }
      return;
    }

    double bmr = _calculateBMR();
    double tdee = _calculateTDEE();
    if (bmr == 0 || tdee == 0) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Check inputs (Sex).')));
        setState(() => _isLoading = false);
      }
      return;
    }
    Map<String, int> calorieTargets = _calculateCalorieTargets(tdee);

    // Prepare data payload
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
      "activityLevel": _activityLabels[
          _activityLevel.round().clamp(0, _activityLabels.length - 1)],
      "goal": _goalLabels[_weeklyGoal.round().clamp(0, _goalLabels.length - 1)],
    };

    final url = Uri.parse('https://e-fit-backend.onrender.com/ai/generate');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode(requestData),
      );

      if (!mounted) return;

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        // Call the MANAGER's callback (which will set the flag)
        widget.onPlanGenerated(responseData['plan'] as Map<String, dynamic>);
      } else {
        print(
            'Error generating plan: ${response.statusCode} - ${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Error generating plan: ${response.statusCode}.')));
      }
    } catch (error) {
      print('Error sending request: $error');
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Network error.')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // --- Input Field Widgets (Keep as they were) ---
  Widget _buildTextField({
    required String label,
    required TextInputType keyboardType,
    required ValueChanged<String> onChanged,
    String? Function(String?)? validator,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
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
        onChanged: (String? newValue) {
          setState(() {
            _selectedSex = newValue;
          });
        },
        items: _sexOptions
            .map<DropdownMenuItem<String>>((String value) =>
                DropdownMenuItem<String>(value: value, child: Text(value)))
            .toList(),
        validator: (value) => value == null ? 'Please select sex' : null,
      ),
    );
  }

  Widget _buildSlider({
    required String label,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required List<String> labels,
    required ValueChanged<double> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$label: ${labels[value.round().clamp(0, labels.length - 1)]}',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500)), // Added clamp for safety
          Slider(
            value: value, min: min, max: max, divisions: divisions,
            label: labels[value.round().clamp(0, labels.length - 1)],
            onChanged: (newValue) {
              setState(() {
                onChanged(newValue);
              });
            }, // Direct setState
            activeColor: Color(0xFF562634),
            inactiveColor: Color(0xFF562634).withOpacity(0.3),
          ),
        ],
      ),
    );
  }

  // --- Build Method (Keep as it was) ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
                        : (int.tryParse(v) ?? 0) <= 10 ||
                                (int.tryParse(v) ?? 999) > 120
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
                        : (double.tryParse(v) ?? 0) <= 20 ||
                                (double.tryParse(v) ?? 999) > 300
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
                        : (double.tryParse(v) ?? 0) <= 50 ||
                                (double.tryParse(v) ?? 999) > 250
                            ? 'Height: 50-250 cm'
                            : null,
                  ),
                  _buildDropdownField(),
                  SizedBox(height: 20),
                  _buildSlider(
                    label: 'Activity Level',
                    value: _activityLevel,
                    min: 0,
                    max: (_activityLabels.length - 1).toDouble(),
                    divisions: _activityLabels.length - 1,
                    labels: _activityLabels,
                    onChanged: (nv) => _activityLevel = nv,
                  ),
                  _buildSlider(
                    label: 'Weekly Goal',
                    value: _weeklyGoal,
                    min: 0,
                    max: (_goalLabels.length - 1).toDouble(),
                    divisions: _goalLabels.length - 1,
                    labels: _goalLabels,
                    onChanged: (nv) => _weeklyGoal = nv,
                  ),
                  _buildSlider(
                    label: 'Approach Balance',
                    value: _approachBalance,
                    min: 0,
                    max: (_approachLabels.length - 1).toDouble(),
                    divisions: _approachLabels.length - 1,
                    labels: _approachLabels,
                    onChanged: (nv) => _approachBalance = nv,
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

// ==========================================================================
// 3. PlanDisplayScreen Widget (Shows the generated plan)
// ==========================================================================
class PlanDisplayScreen extends StatelessWidget {
  final Map<String, dynamic>
      planData; // Manager ensures non-null when showing this
  final EditRequestedCallback onEditRequested;

  const PlanDisplayScreen({
    Key? key,
    required this.planData,
    required this.onEditRequested,
  }) : super(key: key);

  // Helper to format exercise details (Keep as it was)
  String _formatExerciseDetails(Map<String, dynamic> exercise) {
    String details = '';
    if (exercise.containsKey('sets') && exercise.containsKey('reps'))
      details += '${exercise['sets']} sets x ${exercise['reps']} reps';
    else if (exercise.containsKey('time')) {
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
        title: Text('Your Generated Plan'),
        backgroundColor: Color(0xFF562634),
        foregroundColor: Colors.white,
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
            // --- Diet Section ---
            Text('Daily Diet Plan',
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF562634))),
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
                              style: TextStyle(fontStyle: FontStyle.italic))),
                    ...dietItems
                        .map((item) => ListTile(
                              leading: Icon(Icons.restaurant_menu,
                                  color: Colors.orange[700]),
                              title: Text(item['name'] ?? 'Item?',
                                  style:
                                      TextStyle(fontWeight: FontWeight.w500)),
                              trailing: Text(
                                  '${item['calories'] ?? 0}kcal/${item['proteins'] ?? 0}g P',
                                  style: TextStyle(color: Colors.grey[700])),
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
                                  fontWeight: FontWeight.bold, fontSize: 15)),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 24),
            // --- Exercise Section ---
            Text('Daily Exercise Plan',
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF562634))),
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
                              style: TextStyle(fontStyle: FontStyle.italic))),
                    ...exerciseItems
                        .map((item) => ListTile(
                              leading: Icon(Icons.fitness_center,
                                  color: Colors.blue[700]),
                              title: Text(item['name'] ?? 'Exercise?',
                                  style:
                                      TextStyle(fontWeight: FontWeight.w500)),
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
                                  fontWeight: FontWeight.bold, fontSize: 15)),
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
