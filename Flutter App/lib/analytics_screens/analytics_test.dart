import 'dart:convert';
import 'dart:async'; // Import for Timer if needed, used in timeout
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:login_signup_1/style.dart'; // Assuming this defines darkMaroon, brightWhite, jerseyStyle etc.
import 'package:intl/intl.dart'; // Import intl package for date formatting

// Moved main function outside the class to the top level
void main() {
  runApp(const MaterialApp(
    // Added a default home or route for testing if needed
    home:
        ActivityGraphScreenWrapper(), // Use a wrapper if needed for context/theme
    debugShowCheckedModeBanner: false, // Optional: remove debug banner
  ));
}

// Optional Wrapper if ActivityGraphScreen needs Material context immediately
class ActivityGraphScreenWrapper extends StatelessWidget {
  const ActivityGraphScreenWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    // Provide Material context if styles rely on it, otherwise just return ActivityGraphScreen()
    return const ActivityGraphScreen();
  }
}

class ActivityGraphScreen extends StatefulWidget {
  const ActivityGraphScreen({super.key});

  @override
  _ActivityGraphScreenState createState() => _ActivityGraphScreenState();
}

class _ActivityGraphScreenState extends State<ActivityGraphScreen> {
  int? _selectedSpotIndexCalories;
  int? _selectedSpotIndexProtein;
  int? _selectedSpotIndexWater;
  List<Map<String, dynamic>>? _chartData;
  double? _bmi;
  double? _bmr;
  double? _tdee;
  int? _streak;
  final FlutterSecureStorage storage = const FlutterSecureStorage();

  // Trophy state
  bool _hasBronzeTrophy = false;
  bool _hasSilverTrophy = false;
  bool _hasGoldTrophy = false;

  // Loading state
  bool _isLoading = true; // Start loading initially

  @override
  void initState() {
    super.initState();
    // Fetch data immediately when the widget is initialized
    _fetchData();
  }

  // Combined fetch method
  Future<void> _fetchData() async {
    // Ensure we start in loading state if called again (e.g., refresh)
    if (!_isLoading && mounted) {
      setState(() {
        _isLoading = true;
      });
    }
    await _loadTrophyStatus(); // Load trophies first
    await _fetchChartData(); // Then fetch chart data which might affect streak/trophies
    // Ensure setState is called after all async operations if mounted
    if (mounted) {
      setState(() {
        _isLoading = false; // Mark loading as complete
      });
    }
  }

  // Load trophy status from storage
  Future<void> _loadTrophyStatus() async {
    // Added try-catch for potential storage errors
    try {
      _hasBronzeTrophy =
          (await storage.read(key: 'bronzeTrophy') ?? 'false') == 'true';
      _hasSilverTrophy =
          (await storage.read(key: 'silverTrophy') ?? 'false') == 'true';
      _hasGoldTrophy =
          (await storage.read(key: 'goldTrophy') ?? 'false') == 'true';
      print(
          "Loaded Trophies: Bronze=$_hasBronzeTrophy, Silver=$_hasSilverTrophy, Gold=$_hasGoldTrophy");
    } catch (e) {
      print("Error loading trophy status: $e");
      // Set defaults if loading fails
      _hasBronzeTrophy = false;
      _hasSilverTrophy = false;
      _hasGoldTrophy = false;
    }
  }

  Future<void> _saveTrophyStatus() async {
    try {
      await storage.write(
          key: 'bronzeTrophy', value: _hasBronzeTrophy.toString());
      await storage.write(
          key: 'silverTrophy', value: _hasSilverTrophy.toString());
      await storage.write(key: 'goldTrophy', value: _hasGoldTrophy.toString());
      print(
          "Saved Trophies: Bronze=$_hasBronzeTrophy, Silver=$_hasSilverTrophy, Gold=$_hasGoldTrophy");
    } catch (e) {
      print("Error saving trophy status: $e");
    }
  }

  Future<void> _resetTrophyStatus() async {
    print("Attempting to reset trophies...");
    try {
      await storage.delete(key: 'bronzeTrophy');
      await storage.delete(key: 'silverTrophy');
      await storage.delete(key: 'goldTrophy');
      print("Trophy keys deleted from storage.");
    } catch (e) {
      print("Error resetting trophy status in storage: $e");
    }
    // Check mount status before calling setState
    if (mounted) {
      setState(() {
        _hasBronzeTrophy = false;
        _hasSilverTrophy = false;
        _hasGoldTrophy = false;
      });
      print("Trophy state reset in UI.");
    } else {
      print("Widget not mounted, cannot reset trophy state in UI immediately.");
      // Set the flags directly if needed, though setState is safer
      _hasBronzeTrophy = false;
      _hasSilverTrophy = false;
      _hasGoldTrophy = false;
    }
  }

    Future<void> _fetchChartData() async {
    String? email;
    try {
      email = await storage.read(key: 'email');
    } catch (e) {
      print("Error reading email from storage: $e");
      // No need to handle loading state here, _fetchData does it
      return;
    }

    if (email == null || email.isEmpty) {
      print('Email not found in storage.');
      // No need to handle loading state here, _fetchData does it
      return;
    }

    // Use local variables to store fetched data before setting state
    List<Map<String, dynamic>>? fetchedChartData;
    double? fetchedBmi;
    double? fetchedBmr;
    double? fetchedTdee;
    int? fetchedStreak = _streak; // Preserve current streak if fetch fails
    String? fetchError;
    int? previousStreak = _streak; // Store streak before fetching
    bool trophyStatusCorrected = false; // Flag to track if correction happened

    try {
      // Fetch chart and streak data concurrently
      final responses = await Future.wait([
        http.get(
          Uri.parse(
              'https://e-fit-backend.onrender.com/analytics/charts?email=$email'),
          headers: {'Content-Type': 'application/json'},
        ).timeout(const Duration(seconds: 20)),
        http.get(
          Uri.parse(
              'https://e-fit-backend.onrender.com/user/streaks?email=$email'),
          headers: {'Content-Type': 'application/json'},
        ).timeout(const Duration(seconds: 15)),
      ]);

      final chartResponse = responses[0];
      final streakResponse = responses[1];

      Map<String, dynamic>? chartJsonData;
      Map<String, dynamic>? streakJsonData;

      // Process chart response (remains the same)
      if (chartResponse.statusCode == 200) {
        chartJsonData = jsonDecode(chartResponse.body);
        if (chartJsonData != null && chartJsonData['success'] == true) {
          if (chartJsonData['data'] != null) {
            fetchedChartData =
                List<Map<String, dynamic>>.from(chartJsonData['data']);
          } else {
            fetchedChartData = [];
          }
          fetchedBmi = (chartJsonData['bmi'] as num?)?.toDouble();
          fetchedBmr = (chartJsonData['bmr'] as num?)?.toDouble();
          fetchedTdee = (chartJsonData['tdee'] as num?)?.toDouble();
        } else {
          fetchError =
              'Chart API Error: ${chartJsonData?['message'] ?? 'Unknown error'}';
          print(fetchError);
        }
      } else {
        fetchError =
            'Failed to load chart data: ${chartResponse.statusCode} ${chartResponse.reasonPhrase}';
        print(fetchError);
      }

      // Process streak response
      if (streakResponse.statusCode == 200) {
        streakJsonData = jsonDecode(streakResponse.body);
        print('Streak Response: $streakJsonData');
        if (streakJsonData != null && streakJsonData['success'] == true) {
          final newStreak = (streakJsonData['streak'] as num?)?.toInt();
          print(
              'Previous Streak: $previousStreak, New Streak from API: $newStreak');

          // *** START FIX: Validate and Correct Trophy Status based on newStreak ***
          if (newStreak != null) {
            // Check Gold: Must have streak >= 15
            if (_hasGoldTrophy && newStreak < 15) {
              print(
                  "Correcting trophy status: Gold removed (Streak $newStreak < 15)");
              _hasGoldTrophy = false;
              trophyStatusCorrected = true;
            }
            // Check Silver: Must have streak >= 10
            if (_hasSilverTrophy && newStreak < 10) {
              print(
                  "Correcting trophy status: Silver removed (Streak $newStreak < 10)");
              _hasSilverTrophy = false;
              trophyStatusCorrected = true;
            }
            // Check Bronze: Must have streak >= 5
            if (_hasBronzeTrophy && newStreak < 5) {
              print(
                  "Correcting trophy status: Bronze removed (Streak $newStreak < 5)");
              _hasBronzeTrophy = false;
              trophyStatusCorrected = true;
            }
          }
          // *** END FIX ***

          // Check if streak was broken or reset (existing logic)
          // This might reset trophies again if the streak drops to 0, which is fine.
          if (newStreak == 0 ||
              (previousStreak != null &&
                  newStreak != null &&
                  newStreak < previousStreak &&
                  previousStreak >= 5)) {
            print(
                "Streak broken or reset detected! Resetting trophies via _resetTrophyStatus.");
            // This reset will override any corrections made above if the condition is met
            if (mounted) {
              await _resetTrophyStatus();
              trophyStatusCorrected =
                  false; // Reset handled it, no need for separate save
            } else {
              print("Widget unmounted before streak break reset could run.");
            }
          }

          fetchedStreak = newStreak; // Update local fetchedStreak variable
          print('Streak value assigned: $fetchedStreak');
        } else {
          final streakApiError =
              'Streak API Error: ${streakJsonData?['message'] ?? 'Unknown error'}';
          print(streakApiError);
          if (fetchError == null) fetchError = streakApiError;
        }
      } else {
        final streakHttpError =
            'Failed to load streak data: ${streakResponse.statusCode} ${streakResponse.reasonPhrase}';
        print(streakHttpError);
        if (fetchError == null) fetchError = streakHttpError;
      }
    } on TimeoutException catch (e) {
      fetchError = 'Error fetching data: Request timed out. $e';
      print(fetchError);
    } catch (e) {
      fetchError = 'Error fetching data: $e';
      print(fetchError);
    }

    // Update state only if mounted
    if (mounted) {
      // Assign fetched values to state variables
      _chartData = fetchedChartData ?? _chartData;
      _bmi = fetchedBmi ?? _bmi;
      _bmr = fetchedBmr ?? _bmr;
      _tdee = fetchedTdee ?? _tdee;
      // The _has...Trophy flags were potentially modified directly above
      _streak = fetchedStreak; // Assign the potentially new streak value

      // *** FIX: Save corrected trophy status if needed ***
      if (trophyStatusCorrected) {
        print("Saving corrected trophy status to storage...");
        await _saveTrophyStatus(); // Persist the corrected state
      }

      // Handle fetch error display (optional)
      if (fetchError != null) {
        print("Fetch error occurred: $fetchError");
        // Optional: Show Snackbar
        // ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(fetchError!), duration: Duration(seconds: 3),));
      }

      // Final setState is called in _fetchData after this function returns
    } else {
      print("Widget unmounted after fetch completion, state not updated.");
    }
  } // End of _fetchChartData

  // Improved _getYValues with better error handling and type safety
  List<double> _getYValues(String title) {
    if (_chartData == null) {
      print("Chart data is null when getting Y values for '$title'.");
      return []; // Return empty list if chart data isn't loaded
    }
    try {
      // Find the entry for the given title
      final dataEntry = _chartData!.firstWhere(
        (data) => data['title'] == title,
        orElse: () {
          print("Could not find chart data entry for title '$title'.");
          return <String, dynamic>{}; // Return empty map if not found
        },
      );

      // Check if the entry was found and has 'y_vals'
      if (dataEntry.isEmpty || dataEntry['y_vals'] == null) {
        // Allow returning empty list if y_vals is explicitly empty or null
        if (dataEntry.containsKey('y_vals') &&
            dataEntry['y_vals'] is List &&
            (dataEntry['y_vals'] as List).isEmpty) {
          print(
              "Empty 'y_vals' list found for title '$title'. Returning empty list.");
          return [];
        }
        print(
            "No 'y_vals' key found or data entry is empty for title '$title'.");
        return [];
      }

      // Safely cast and convert y_vals to List<double>
      final yValsDynamic = dataEntry['y_vals'];
      if (yValsDynamic is List) {
        // Handle empty list case explicitly
        if (yValsDynamic.isEmpty) {
          print("Processing empty y Values list for '$title'.");
          return [];
        }

        List<double> result = yValsDynamic
            .map((value) {
              if (value is num) {
                return value.toDouble();
              } else if (value is String) {
                return double.tryParse(
                    value); // Attempt to parse if it's a string
              }
              print(
                  "Invalid type found in y_vals for '$title': ${value.runtimeType}"); // Log invalid type
              return null; // Return null for other types or unparseable strings
            })
            .where((value) => value != null) // Filter out nulls
            .toList()
            .cast<double>(); // Cast to double list

        // print("Successfully processed y Values for '$title': ${result.length} values");
        return result;
      } else {
        print(
            "'y_vals' for title '$title' is not a List. Found type: ${yValsDynamic.runtimeType}");
        return [];
      }
    } catch (e, stackTrace) {
      print("Error processing y Values for title '$title': $e");
      print(stackTrace); // Print stack trace for detailed debugging
      return []; // Return empty list on any other error
    }
  }

  // *** MODIFIED: Updated logic for Rewards Button Text (REMOVED storage writes) ***
  String _getRewardsButtonText() {
    if (_streak == null) {
      return 'Loading streak...';
    }

    // Prioritize claims: Check highest potential trophy first
    // This function ONLY determines the text, it doesn't perform the claim/save action.
    if (_streak! >= 15 && !_hasGoldTrophy) {
      // await storage.write(key: 'bronzeTrophy', value: "false"); // REMOVED - Error: await in non-async. Logic belongs in _claimReward.
      // await storage.write(key: 'silverTrophy', value: "false"); // REMOVED - Error: await in non-async. Logic belongs in _claimReward.
      // await storage.write(key: 'goldTrophy', value: "true");  // REMOVED - Error: await in non-async. Logic belongs in _claimReward.
      return 'Claim Gold Trophy!';
    } else if (_streak! >= 10 && !_hasSilverTrophy) {
      // await storage.write(key: 'bronzeTrophy', value: "false"); // REMOVED - Error: await in non-async. Logic belongs in _claimReward.
      // await storage.write(key: 'goldTrophy', value: "false"); // REMOVED - Error: await in non-async. Logic belongs in _claimReward.
      // await storage.write(key: 'silverTrophy', value: "true"); // REMOVED - Error: await in non-async. Logic belongs in _claimReward.
      return 'Claim Silver Trophy!';
    } else if (_streak! >= 5 && !_hasBronzeTrophy) {
      // await storage.write(key: 'bronzeTrophy', value: "true");  // REMOVED - Error: await in non-async. Logic belongs in _claimReward.
      // await storage.write(key: 'goldTrophy', value: "false"); // REMOVED - Error: await in non-async. Logic belongs in _claimReward.
      // await storage.write(key: 'silverTrophy', value: "false"); // REMOVED - Error: await in non-async. Logic belongs in _claimReward.
      return 'Claim Bronze Trophy!';
    }
    // If no claims available, show progress or maintenance message
    else if (_streak! >= 15) {
      // Gold achieved
      return 'Keep up the great work!';
    } else if (_streak! >= 10) {
      // Silver achieved
      return 'Keep going! ${15 - _streak!} more days to Gold!';
    } else if (_streak! >= 5) {
      // Bronze achieved
      return 'Nice start! ${10 - _streak!} more days to Silver!';
    } else {
      // Below Bronze threshold
      return '${5 - _streak!} more days to unlock Bronze!';
    }
  }

  // *** MODIFIED: Claim logic remains similar, ensures claiming highest available ***
  void _claimReward() {
    if (_streak == null) return;

    bool trophyUpdated = false;
    // Claim logic: Only update if the condition is met AND the trophy isn't already held.
    // Check in order of highest trophy first.
    if (_streak! >= 15 && !_hasGoldTrophy) {
      if (mounted) {
        setState(() {
          _hasGoldTrophy = true;
          // If the design implies only the highest trophy is kept, reset others here:
          // _hasSilverTrophy = false;
          // _hasBronzeTrophy = false;
          trophyUpdated = true;
          print("Claimed Gold Trophy");
        });
      }
    } else if (_streak! >= 10 && !_hasSilverTrophy) {
      if (mounted) {
        setState(() {
          _hasSilverTrophy = true;
          // If the design implies only the highest trophy is kept, reset others here:
          // _hasBronzeTrophy = false;
          trophyUpdated = true;
          print("Claimed Silver Trophy");
        });
      }
    } else if (_streak! >= 5 && !_hasBronzeTrophy) {
      if (mounted) {
        setState(() {
          _hasBronzeTrophy = true;
          trophyUpdated = true;
          print("Claimed Bronze Trophy");
        });
      }
    }

    // Save status only if a trophy state was changed
    if (trophyUpdated) {
      _saveTrophyStatus();
    } else {
      print("Claim button pressed, but no new trophy earned or already held.");
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;

    // Get Y values safely AFTER checking _isLoading and ensuring _chartData is populated
    final List<double> caloriesYValues =
        _isLoading || _chartData == null ? [] : _getYValues('Calories');
    final List<double> proteinYValues = _isLoading || _chartData == null
        ? []
        : _getYValues('Proteins'); // Match title used in API/getYValues
    final List<double> waterYValues =
        _isLoading || _chartData == null ? [] : _getYValues('Water Intake');

    // *** Determine if the claim button should be enabled ***
    final bool canClaimReward = _streak != null &&
        ((_streak! >= 5 && !_hasBronzeTrophy) ||
            (_streak! >= 10 && !_hasSilverTrophy) ||
            (_streak! >= 15 && !_hasGoldTrophy));

    return Scaffold(
      backgroundColor: Colors.white, // Assuming brightWhite is Colors.white
      appBar: AppBar(
        leading: IconButton(
            icon: const Icon(Icons.arrow_back,
                color: Colors.white), // Use brightWhite if defined
            onPressed: () => Navigator.pop(context)),
        title: Text('Activity Overview',
            style: jerseyStyle(22, Colors.white)), // Use brightWhite if defined
        backgroundColor: darkMaroon,
        elevation: 0,
        iconTheme:
            IconThemeData(color: brightWhite), // Use brightWhite if defined
      ),
      body: _isLoading // Use the loading flag
          ? const Center(child: CircularProgressIndicator(color: darkMaroon))
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  // Ensure all content is inside this Column
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Graph Sections
                    buildGraphSection('Calories', Icons.local_fire_department,
                        _selectedSpotIndexCalories, (index) {
                      if (!mounted) return;
                      setState(() {
                        _selectedSpotIndexCalories = index;
                      });
                    }, screenHeight, caloriesYValues), // Pass double list
                    const SizedBox(height: 32),
                    buildGraphSection('Protein', Icons.restaurant,
                        _selectedSpotIndexProtein, // Use 'Protein' for title display
                        (index) {
                      if (!mounted) return;
                      setState(() {
                        _selectedSpotIndexProtein = index;
                      });
                    }, screenHeight, proteinYValues), // Pass double list
                    const SizedBox(height: 32),
                    buildGraphSection('Water', Icons.water_drop,
                        _selectedSpotIndexWater, // Use 'Water' for title display
                        (index) {
                      if (!mounted) return;
                      setState(() {
                        _selectedSpotIndexWater = index;
                      });
                    }, screenHeight, waterYValues), // Pass double list
                    const SizedBox(height: 32),

                    // BMI/BMR/TDEE Section
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 24),
                      decoration: BoxDecoration(
                        color: darkMaroon,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.3),
                            spreadRadius: 1,
                            blurRadius: 4,
                            offset: const Offset(0, 2), // Use const
                          ),
                        ],
                      ),
                      child: IntrinsicHeight(
                        // Ensures dividers stretch
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment
                              .stretch, // Make columns fill height
                          children: [
                            Expanded(
                              child: buildInfoColumn(
                                  'BMI',
                                  _bmi?.toStringAsFixed(1) ?? '--',
                                  'Body Mass Index',
                                  'A measure of body fat based on height and weight.'),
                            ),
                            verticalDivider(),
                            Expanded(
                              child: buildInfoColumn(
                                  'BMR',
                                  _bmr?.toStringAsFixed(0) ?? '--',
                                  'Basal Metabolic Rate',
                                  'The number of calories your body burns at rest.'),
                            ),
                            verticalDivider(),
                            Expanded(
                              child: buildInfoColumn(
                                  'TDEE',
                                  _tdee?.toStringAsFixed(0) ?? '--',
                                  'Total Daily Energy Expenditure',
                                  'Estimated calories burned per day including activity.'),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // *** MODIFIED: Streak Section - Added Trophy Icon Display ***
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 24),
                      decoration: BoxDecoration(
                        color: darkMaroon,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.3),
                            spreadRadius: 1,
                            blurRadius: 4,
                            offset: const Offset(0, 2), // Use const
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('Current Streak',
                                  style: jerseyStyle(
                                      20, Colors.white)), // Use brightWhite
                              const SizedBox(width: 8),
                              const Icon(
                                  Icons.local_fire_department, // Use const
                                  color: Colors.orangeAccent,
                                  size: 22),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            // Wrap Text and Trophy in a Row
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                // Use 'Loading...' or '0 Days' if streak is null
                                _streak != null ? '${_streak!} Days' : '0 Days',
                                style: jerseyStyle(
                                    28, Colors.white), // Use brightWhite
                              ),
                              const SizedBox(width: 10), // Space before trophy
                              // --- Trophy Icon Display Logic ---
                              // Shows the HIGHEST *EARNED* trophy next to the streak.
                              if (_hasGoldTrophy)
                                Image.asset('assets/images/gold.png',
                                    width: 50, height: 50)
                              else if (_hasSilverTrophy)
                                Image.asset('assets/images/silver.png',
                                    width: 50, height: 50)
                              else if (_hasBronzeTrophy)
                                Image.asset('assets/images/bronze.png',
                                    width: 50, height: 50)
                              else
                                const SizedBox(
                                    width: 50,
                                    height:
                                        50), // Placeholder for alignment if no trophy
                              // --- End Trophy Icon Display ---
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // *** MODIFIED: Rewards Button - Simplified Child, Updated onPressed ***
                    SizedBox(
                      height: 60, // Adjusted height slightly
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              brightWhite, // Use brightWhite if defined
                          foregroundColor: darkMaroon,
                          textStyle: const TextStyle(fontSize: 18), // Use const
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 15), // Adjust padding
                          // Disable button visually if no reward can be claimed
                          disabledBackgroundColor: brightWhite
                              .withOpacity(0.7), // Use brightWhite if defined
                          disabledForegroundColor: darkMaroon.withOpacity(0.7),
                        ),
                        // Enable button ONLY if a reward CAN be claimed
                        onPressed: canClaimReward ? _claimReward : null,
                        // Child is now just the text indicating the action or status
                        child: Text(
                          _getRewardsButtonText(), // This now correctly returns the text without side-effects
                          style: jerseyStyle(
                              18, darkMaroon), // Main button text style
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ),
                    // Added a bit more space at the bottom
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
    );
  } // End of build method

  Widget buildGraphSection(String title, IconData icon, int? selectedIndex,
      Function(int?) onTouch, double screenHeight, List<double> yValues) {
    // Accept List<double>
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(title, style: jerseyStyle(24, darkMaroon)),
            const SizedBox(width: 8),
            Icon(icon, color: darkMaroon, size: 28),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: screenHeight * 0.25,
          // Add a check for empty yValues to avoid errors in mainData
          child: yValues.isEmpty
              ? Center(
                  child: Text('No data available for $title',
                      style: jerseyStyle(16, Colors.grey)))
              : LineChart(
                  mainData(title, selectedIndex, onTouch,
                      yValues), // Pass double list
                ),
        ),
      ],
    );
  }

  LineChartData mainData(String graphType, int? selectedSpotIndex,
      Function(int?) updateSelectedIndex, List<double> yValues) {
    // Accept List<double>

    // Ensure yValues isn't empty before generating spots
    List<FlSpot> spots = yValues.isNotEmpty
        ? List.generate(
            yValues.length, (index) => FlSpot(index.toDouble(), yValues[index]))
        : []; // Start with empty list if yValues is empty

    // Handle case where spots list might be empty
    if (spots.isEmpty) {
      // Default to 7 days of zero data *if* yValues was originally empty
      spots = List.generate(7, (index) => FlSpot(index.toDouble(), 0));
    }

    final int numberOfDays = spots.length;
    final DateFormat dayFormatter =
        DateFormat('EEE'); // Formatter for day names ('Mon', 'Tue', etc.)
    final now = DateTime.now();

    List<String> dayLabels = List.generate(numberOfDays, (index) {
      // Check if it's the last index (most recent day)
      if (numberOfDays > 0 && index == numberOfDays - 1) {
        return 'Today'; // Use 'Today' for the last label
      } else {
        // Calculate date relative to the most recent data point (which is 'Today')
        final pastDate = now.subtract(Duration(days: numberOfDays - 1 - index));
        return dayFormatter.format(pastDate);
      }
    });
    // Handle the case where numberOfDays might be 0 if spots defaulted empty somehow differently
    if (numberOfDays == 0) {
      dayLabels = []; // Ensure labels list is also empty
    }

    // Calculate maxYValue safely, providing a default if spots is empty
    double maxYValue = spots.isNotEmpty
        ? spots.map((spot) => spot.y).reduce((a, b) => a > b ? a : b)
        : 0.0; // Default to 0 if no data

    // Set a minimum sensible max Y value if all data is 0 or negative, or if empty
    if (maxYValue <= 0) {
      // Adjust default max based on graph type for better scale
      if (graphType == 'Water') {
        // Using display title 'Water'
        maxYValue = 1000.0; // Default max water
      } else if (graphType == 'Protein') {
        // Using display title 'Protein'
        maxYValue = 50.0; // Default max protein
      } else {
        // Calories or other
        maxYValue = 1000.0; // Default max calories
      }
    }

    double interval;
    // Simplified interval calculation slightly, ensuring positive interval
    // Use the graphType (which matches API title) passed to mainData for logic
    if (graphType == 'Water') {
      interval = (maxYValue / 4).ceilToDouble();
      if (interval < 100 && maxYValue >= 100) interval = 100;
    } else if (graphType == 'Protein') {
      interval = (maxYValue / 4).ceilToDouble();
      if (interval < 5 && maxYValue >= 5) interval = 5;
    } else {
      // Calories etc.
      interval = (maxYValue / 4).ceilToDouble();
      if (interval < 50 && maxYValue >= 50) interval = 50;
    }

    // Ensure interval is always positive and non-zero, provide minimum based on type if needed
    if (interval <= 0) {
      if (graphType == 'Water')
        interval = 100.0;
      else if (graphType == 'Protein')
        interval = 5.0;
      else
        interval = 50.0; // Default for calories/other
    }
    // Further clamp to ensure it's at least 1
    interval = interval.clamp(1.0, double.infinity);

    // Add more top padding, ensure it's based on calculated maxY or the default
    final double chartMaxY = (maxYValue * 1.20).ceilToDouble().clamp(
        interval, double.infinity); // Ensure max Y is at least one interval

    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: interval, // Already ensured > 0
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: Colors.grey.withOpacity(0.3),
            strokeWidth: 1,
          );
        },
      ),
      borderData: FlBorderData(
        show: true,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade400, width: 1),
          left: BorderSide(color: Colors.grey.shade400, width: 1),
        ),
      ),
      titlesData: FlTitlesData(
        show: true,
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(
            showTitles: false,
            reservedSize: 20, // Padding on the right
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 50, // Space for labels
            interval: interval, // Use calculated interval
            getTitlesWidget: (value, meta) {
              // Show 0, max, and interval multiples clearly
              if (value == 0 ||
                  value == meta.max ||
                  (value > 0 && value < meta.max && value % interval == 0)) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Text(
                    value.toInt().toString(), // Format as integer
                    style: jerseyStyle(14, darkMaroon),
                    textAlign: TextAlign.right,
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: 1, // Show title for every spot/day
            reservedSize: 40, // Space below chart
            getTitlesWidget: (value, meta) {
              int index = value.toInt();
              // Check bounds carefully
              if (index >= 0 && index < dayLabels.length) {
                final bool isSelected = selectedSpotIndex == index;
                final String labelText = dayLabels[index];
                return Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(
                    labelText,
                    style: jerseyStyle(
                      isSelected ? 18 : 16,
                      isSelected
                          ? lightMaroon
                              .withOpacity(1.0) // Use lightMaroon if defined
                          : darkMaroon.withOpacity(1.0),
                    ).copyWith(
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal),
                    overflow:
                        TextOverflow.visible, // Allow slight overflow if needed
                  ),
                );
              } else {
                // Avoid errors if index is out of bounds (e.g., during animation)
                return const SizedBox.shrink();
              }
            },
          ),
        ),
      ),
      extraLinesData: const ExtraLinesData(extraLinesOnTop: false), // Use const
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          barWidth: 3,
          isStrokeCapRound: true,
          color: lightMaroon, // Use lightMaroon if defined
          dotData: FlDotData(
            show: true,
            getDotPainter: (spot, percent, bar, index) => FlDotCirclePainter(
              radius: selectedSpotIndex == index ? 7 : 4,
              color: selectedSpotIndex == index
                  ? Colors.orangeAccent
                  : lightMaroon.withOpacity(0.8), // Use lightMaroon if defined
              strokeWidth: 0,
            ),
          ),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              // Can be const if colors are const
              colors: [
                darkMaroon.withOpacity(0.3),
                darkMaroon.withOpacity(0.0),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ],
      lineTouchData: LineTouchData(
        enabled: true,
        handleBuiltInTouches: false, // We handle it in touchCallback
        touchCallback: (FlTouchEvent event, LineTouchResponse? touchResponse) {
          // *** FIXED: Use defined event types FlTapUpEvent, FlPanEndEvent, FlLongPressEnd ***
          if (event is FlTapUpEvent ||
              event is FlPanEndEvent ||
              event is FlLongPressEnd) {
            if (selectedSpotIndex != null && mounted) {
              updateSelectedIndex(
                  null); // Reset selection when touch interaction ends
            }
            // Don't return here, let the rest of the logic run in case the end event
            // still has valid touchResponse data for the last point.
            // return; // Removed return
          }

          // If the event is NOT an end event, and interaction is finished, OR if response is invalid/empty
          if (!event.isInterestedForInteractions ||
              touchResponse == null ||
              touchResponse.lineBarSpots == null ||
              touchResponse.lineBarSpots!.isEmpty) {
            // Reset selection if the touch is no longer valid or hits nothing
            // Only reset if it's not one of the handled 'end' events above to avoid double-resetting.
            if (!(event is FlTapUpEvent ||
                event is FlPanEndEvent ||
                event is FlLongPressEnd)) {
              if (selectedSpotIndex != null && mounted) {
                updateSelectedIndex(null);
              }
            }
            return; // Exit if no valid interaction/spot
          }

          // If we have a valid touchResponse with spots:
          final int touchedIndex = touchResponse.lineBarSpots!.first.spotIndex;
          // Update selection if the touched spot is different from the current one
          if (selectedSpotIndex != touchedIndex) {
            if (mounted) updateSelectedIndex(touchedIndex);
          }
          // If the same spot is touched again (e.g., during a drag), do nothing to keep it selected.
        },
        getTouchedSpotIndicator: (barData, indicators) {
          return indicators.map((int index) {
            return TouchedSpotIndicatorData(
              FlLine(
                  color: Colors.orangeAccent.withOpacity(0.7), strokeWidth: 2),
              FlDotData(
                getDotPainter: (spot, percent, bar, index) =>
                    FlDotCirclePainter(
                  radius: 8,
                  color: Colors.orangeAccent,
                  strokeColor:
                      Colors.white, // Assuming brightWhite is Colors.white
                  strokeWidth: 1,
                ),
              ),
            );
          }).toList();
        },
        touchTooltipData: LineTouchTooltipData(
          tooltipRoundedRadius: 8,
          tooltipPadding: const EdgeInsets.symmetric(
              horizontal: 12, vertical: 8), // Use const
          // tooltipBgColor: darkMaroon.withOpacity(0.8), // Tooltip background
          getTooltipItems: (touchedSpots) {
            return touchedSpots.map((touchedSpot) {
              // Format based on graph type (using display title)
              final String text;
              if (graphType == 'Water') {
                text = '${touchedSpot.y.toInt()} ml';
              } else if (graphType == 'Protein') {
                text =
                    '${touchedSpot.y.toStringAsFixed(1)} g'; // Protein often has decimals
              } else {
                // Calories
                text = '${touchedSpot.y.toInt()} kcal';
              }
              return LineTooltipItem(
                text,
                jerseyStyle(16, Colors.white), // Use brightWhite if defined
                textAlign: TextAlign.center,
              );
            }).toList();
          },
        ),
      ),
      minY: 0,
      maxY: chartMaxY, // Use the calculated max Y
    );
  }

  // Reusable widget for BMI/BMR/TDEE columns
  Widget buildInfoColumn(
      String label, String value, String fullForm, String description) {
    return InkWell(
      onTap: () => showInfoDialog(fullForm, description),
      borderRadius:
          BorderRadius.circular(8), // Match container radius if needed
      child: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: 4, vertical: 12), // Use const
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center, // Center content vertically
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment:
                  CrossAxisAlignment.center, // Align icon and text
              children: [
                Flexible(
                    // Allow label text to wrap if needed
                    child: Text(
                  label,
                  style: jerseyStyle(
                      18, Colors.white), // Use brightWhite if defined
                  overflow: TextOverflow
                      .ellipsis, // Prevent long labels breaking layout
                  textAlign: TextAlign.center, // Center label text
                )),
                const SizedBox(width: 4),
                const Icon(Icons.info_outline,
                    color: Colors.white70, size: 16), // Use const
              ],
            ),
            const SizedBox(height: 10), // Use const
            Text(value,
                style:
                    jerseyStyle(22, Colors.white) // Use brightWhite if defined
                        .copyWith(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  // Reusable vertical divider
  Widget verticalDivider() {
    return Container(
      width: 1,
      color: Colors.white.withOpacity(0.5), // Use brightWhite if defined
      margin: const EdgeInsets.symmetric(vertical: 16), // Use const
    );
  }

  // Method to show info dialog
  void showInfoDialog(String title, String description) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title, style: jerseyStyle(20, darkMaroon)),
        content: Text(description,
            style: const TextStyle(fontSize: 16)), // Use const
        actions: [
          TextButton(
            child: Text("Close",
                style: TextStyle(color: darkMaroon, fontSize: 16)),
            onPressed: () => Navigator.pop(context),
          ),
        ],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      ),
    );
  }
}

// Assuming style.dart defines these:
// const Color darkMaroon = Color(0xFF800000); // Example color
// const Color lightMaroon = Color(0xFFA03030); // Example color
// const Color brightWhite = Colors.white; // Example color
// TextStyle jerseyStyle(double size, Color color) => TextStyle(
//     fontSize: size, color: color, fontFamily: 'Jersey'); // Example style
