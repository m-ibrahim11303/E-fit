import 'dart:convert';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// Assuming jerseyStyle is defined elsewhere or here:
TextStyle jerseyStyle(double fontSize, [Color color = Colors.white]) {
  return TextStyle(
    fontFamily: 'Jersey 25', // Make sure this font is added to pubspec.yaml
    fontSize: fontSize,
    color: color,
  );
}

void main() {
  runApp(const MaterialApp(home: ActivityGraphScreen()));
}

class ActivityGraphScreen extends StatefulWidget {
  const ActivityGraphScreen({super.key});

  @override
  _ActivityGraphScreenState createState() => _ActivityGraphScreenState();
}

class _ActivityGraphScreenState extends State<ActivityGraphScreen> {
  // Remove the selected index for steps
  // int? _selectedSpotIndexSteps;
  int? _selectedSpotIndexCalories;
  int? _selectedSpotIndexProtein;
  int? _selectedSpotIndexWater;
  List<Map<String, dynamic>>? _chartData;
  double? _bmi;
  double? _bmr;
  double? _tdee;
  int? _streak;
  final FlutterSecureStorage storage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _fetchChartData();
  }

  Future<void> _fetchChartData() async {
    final email = await storage.read(key: 'email') ?? '';
    if (email.isEmpty) {
      print('Email not found in storage.');
      // Optionally set state to show an error message to the user
      if (mounted) {
        setState(() {
          // Handle the case where email is not found, e.g., show error
        });
      }
      return;
    }

    try {
      // Fetch chart data
      final chartResponse = await http.get(
        Uri.parse(
            'https://e-fit-backend.onrender.com/analytics/charts?email=$email'),
        headers: {'Content-Type': 'application/json'}, // Good practice
      ).timeout(const Duration(seconds: 20)); // Add timeout

      // Fetch streak data
      final streakResponse = await http.get(
        Uri.parse(
            'https://e-fit-backend.onrender.com/user/streaks?email=$email'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 15));

      Map<String, dynamic>? chartJsonData;
      Map<String, dynamic>? streakJsonData;
      String? chartError;
      String? streakError;

      if (chartResponse.statusCode == 200) {
        chartJsonData = jsonDecode(chartResponse.body);
      } else {
        chartError = 'Failed to load chart data: ${chartResponse.statusCode}';
        print(chartError);
      }

      if (streakResponse.statusCode == 200) {
        streakJsonData = jsonDecode(streakResponse.body);
        print('Streak Response: $streakJsonData'); // Log streak response
      } else {
        streakError =
            'Failed to load streak data: ${streakResponse.statusCode}';
        print(streakError);
      }

      // Check mount status before setting state
      if (!mounted) return;

      setState(() {
        if (chartJsonData != null && chartJsonData['success'] == true) {
          _chartData =
              List<Map<String, dynamic>>.from(chartJsonData['data'] ?? []);
          // Safely parse numeric values
          _bmi = (chartJsonData['bmi'] as num?)?.toDouble();
          _bmr = (chartJsonData['bmr'] as num?)?.toDouble();
          _tdee = (chartJsonData['tdee'] as num?)?.toDouble();
        } else if (chartError != null) {
          // Optionally display chartError to the user
          print('Chart Data Error: ${chartJsonData?['message'] ?? chartError}');
        }

        if (streakJsonData != null && streakJsonData['success'] == true) {
          _streak = (streakJsonData['streak'] as num?)?.toInt();
          print('Streak value set: $_streak');
        } else if (streakError != null) {
          // Optionally display streakError to the user
          print(
              'Streak Data Error: ${streakJsonData?['message'] ?? streakError}');
        }
      });
    } catch (e) {
      print('Error fetching data: $e');
      if (mounted) {
        setState(() {
          // Handle general fetch error, e.g., show error message
        });
      }
    }
  }

  // Helper to safely get yValues for a given title
  List<dynamic> _getYValues(String title) {
    try {
      return _chartData
              ?.firstWhere((data) => data['title'] == title)['y_vals'] ??
          [];
    } catch (e) {
      print("Could not find yValues for title '$title': $e");
      return []; // Return empty list if title not found or error occurs
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;

    // Define the data sources safely using the helper
    final List<dynamic> caloriesYValues = _getYValues('Calories');
    final List<dynamic> proteinYValues =
        _getYValues('Proteins'); // Check title match
    final List<dynamic> waterYValues =
        _getYValues('Water Intake'); // Check title match

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        // Add an AppBar for better structure
        title: Text('Activity Overview', style: jerseyStyle(22, Colors.white)),
        backgroundColor: const Color(0xFF800000),
        elevation: 0, // Remove shadow if desired
        iconTheme: IconThemeData(
            color: Colors.white), // Ensure back button is white if needed
      ),
      body: _chartData == null
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF800000)))
          : SingleChildScrollView(
              child: Padding(
                // Apply padding once around the content
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment
                      .stretch, // Stretch children horizontally
                  children: [
                    // --- REMOVED Steps Graph Section ---
                    // buildGraphSection('Steps', Icons.directions_walk,
                    //     _selectedSpotIndexSteps, (index) {
                    //   if (!mounted) return;
                    //   setState(() {
                    //     _selectedSpotIndexSteps = index;
                    //   });
                    // }, screenHeight, []), // Assuming steps data might come later or not needed
                    // const SizedBox(height: 32),
                    // --- END REMOVED Steps Graph Section ---

                    buildGraphSection('Calories', Icons.local_fire_department,
                        _selectedSpotIndexCalories, (index) {
                      if (!mounted) return;
                      setState(() {
                        _selectedSpotIndexCalories = index;
                      });
                    }, screenHeight, caloriesYValues), // Use safe variable
                    const SizedBox(height: 32),
                    buildGraphSection(
                        'Protein',
                        Icons.restaurant, // Changed icon
                        _selectedSpotIndexProtein, (index) {
                      if (!mounted) return;
                      setState(() {
                        _selectedSpotIndexProtein = index;
                      });
                    }, screenHeight, proteinYValues), // Use safe variable
                    const SizedBox(height: 32),
                    buildGraphSection(
                        'Water', Icons.water_drop, _selectedSpotIndexWater,
                        (index) {
                      if (!mounted) return;
                      setState(() {
                        _selectedSpotIndexWater = index;
                      });
                    }, screenHeight, waterYValues), // Use safe variable
                    const SizedBox(height: 32),

                    // --- BMI/BMR/TDEE Section ---
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 24),
                      decoration: BoxDecoration(
                        color: const Color(0xFF800000),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          // Optional subtle shadow
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.3),
                            spreadRadius: 1,
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: IntrinsicHeight(
                        child: Row(
                          mainAxisAlignment:
                              MainAxisAlignment.spaceEvenly, // Distribute space
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              // Use Expanded for equal width
                              child: buildInfoColumn(
                                  'BMI',
                                  _bmi?.toStringAsFixed(1) ??
                                      '--', // Placeholder
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

                    // --- Streak Section ---
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 24),
                      decoration: BoxDecoration(
                        color: const Color(0xFF800000),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.3),
                            spreadRadius: 1,
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('Current Streak', // More descriptive
                                  style: jerseyStyle(20, Colors.white)),
                              const SizedBox(width: 8), // Increased spacing
                              Icon(
                                  Icons
                                      .local_fire_department, // Consistent icon
                                  color: Colors.orangeAccent,
                                  size: 22), // Different color for emphasis
                            ],
                          ),
                          const SizedBox(height: 12), // Increased spacing
                          Text(
                            _streak != null
                                ? '${_streak!} Days'
                                : '0 Days', // Show '0 Days' if null or 0
                            style: jerseyStyle(
                                28, Colors.white), // Slightly larger font
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                        height: 20), // Add some padding at the bottom
                  ],
                ),
              ),
            ),
    );
  }

  Widget buildGraphSection(String title, IconData icon, int? selectedIndex,
      Function(int?) onTouch, double screenHeight, List<dynamic> yValues) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(title, style: jerseyStyle(24, const Color(0xFF800000))),
            const SizedBox(width: 8),
            Icon(icon, color: const Color(0xFF800000), size: 28),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          // Adjust height dynamically or use a fixed aspect ratio
          height: screenHeight * 0.25, // Use a portion of screen height
          // Consider using AspectRatio if you want consistent proportions
          // aspectRatio: 1.7, // Example aspect ratio
          child: LineChart(
            mainData(title, selectedIndex, onTouch, yValues),
            // swapAnimationDuration: Duration(milliseconds: 150), // Optional animation
            // swapAnimationCurve: Curves.linear, // Optional animation
          ),
        ),
      ],
    );
  }

  LineChartData mainData(String graphType, int? selectedSpotIndex,
      Function(int?) updateSelectedIndex, List<dynamic> yValues) {
    // Ensure yValues only contains numbers and handle potential errors
    List<double> numericYValues = yValues
        .map((value) =>
            (value as num?)?.toDouble()) // Safely cast to num then double
        .where((value) => value != null) // Filter out nulls
        .toList()
        .cast<double>(); // Cast the result to List<double>

    List<FlSpot> spots = numericYValues.isNotEmpty
        ? List.generate(numericYValues.length,
            (index) => FlSpot(index.toDouble(), numericYValues[index]))
        // Provide default spots if data is empty after filtering
        : List.generate(
            7, (index) => FlSpot(index.toDouble(), 0)); // Default 7 days with 0

    // Dynamically determine the number of days based on spots
    final int numberOfDays = spots.length;
    // Generate day labels dynamically, ensuring 'Today' is last
    List<String> days = List.generate(numberOfDays, (index) {
      if (index == numberOfDays - 1) return 'Today';
      // Simple labels like 'Day 1', 'Day 2' or calculate actual past days
      // Example for last 7 days ending today (needs date logic):
      // DateTime date = DateTime.now().subtract(Duration(days: numberOfDays - 1 - index));
      // return DateFormat('E').format(date); // Requires 'intl' package
      return 'D${numberOfDays - index}'; // Simple labels like D7, D6, ..., D1, Today
    });
    if (numberOfDays != 7) {
      print(
          "Warning: Chart data does not contain exactly 7 points. X-axis labels might be adjusted.");
      // Adjust 'days' array generation if not always 7 days
      // Example: Use only indices if not 7 days
      // days = List.generate(numberOfDays, (index) => index == numberOfDays - 1 ? 'Today' : index.toString());
    }

    // --- Dynamic Y-Axis Interval Calculation (Example) ---
    double maxYValue = spots.isNotEmpty
        ? spots.map((spot) => spot.y).reduce((a, b) => a > b ? a : b)
        : 100.0; // Default max if no data
    if (maxYValue == 0)
      maxYValue = 100.0; // Avoid division by zero if all values are 0

    double interval;
    // Adjust interval logic based on graphType and maxYValue
    if (graphType == 'Water Intake') {
      interval = (maxYValue / 4).ceilToDouble(); // Aim for ~4-5 labels
      if (interval < 100) interval = 100; // Minimum interval
      interval = (interval / 100).round() * 100; // Round to nearest 100
    } else if (graphType == 'Proteins') {
      interval = (maxYValue / 4).ceilToDouble();
      if (interval < 5) interval = 5;
      interval = (interval / 5).round() * 5; // Round to nearest 5
    } else {
      // Calories or other types
      interval = (maxYValue / 4).ceilToDouble();
      if (interval < 50) interval = 50;
      interval = (interval / 50).round() * 50; // Round to nearest 50
    }
    if (interval == 0) interval = 1; // Ensure interval is never zero

    return LineChartData(
      gridData: FlGridData(
        show: true, // Show grid lines for better readability
        drawVerticalLine: false, // Hide vertical lines
        horizontalInterval: interval, // Use calculated interval
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: Colors.grey.withOpacity(0.3), // Lighter grid lines
            strokeWidth: 1,
          );
        },
      ),
      borderData: FlBorderData(
        // Subtle border
        show: true,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade400, width: 1),
          left: BorderSide(color: Colors.grey.shade400, width: 1),
        ),
      ),
      titlesData: FlTitlesData(
        show: true,
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles:
            const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 50, // Adjust space based on max label width
            interval: interval, // Use calculated interval
            getTitlesWidget: (value, meta) {
              // Ensure only labels at interval steps are shown
              if (value == meta.min ||
                  value == meta.max ||
                  value % interval == 0) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Text(
                    value.toInt().toString(), // Format as integer
                    style: jerseyStyle(14, const Color(0xFF800000)),
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
            interval: 1, // Show label for every spot
            reservedSize: 40,
            getTitlesWidget: (value, meta) {
              int index = value.toInt();
              if (index >= 0 && index < days.length) {
                final bool isSelected = selectedSpotIndex == index;
                return Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(
                    days[index],
                    style: jerseyStyle(
                      isSelected ? 20 : 18, // Highlight selected day
                      isSelected
                          ? const Color(0xFF4B1D2F)
                          : const Color(0xFF800000), // Darker color if selected
                    ).copyWith(
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal),
                  ),
                );
              } else {
                return const SizedBox.shrink();
              }
            },
          ),
        ),
      ),
      extraLinesData: ExtraLinesData(extraLinesOnTop: false),
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true, // Smoother curve
          barWidth: 3, // Slightly thicker line
          isStrokeCapRound: true,
          color: const Color(0xff4B1D2F), // Primary line color
          dotData: FlDotData(
            show: true,
            getDotPainter: (spot, percent, bar, index) => FlDotCirclePainter(
              radius:
                  selectedSpotIndex == index ? 8 : 5, // Larger dot if selected
              color: selectedSpotIndex == index
                  ? Colors.orangeAccent
                  : const Color(0xff4B1D2F), // Highlight color
              strokeWidth: 0,
            ),
          ),
          belowBarData: BarAreaData(
            // Add subtle gradient below line
            show: true,
            gradient: LinearGradient(
              colors: [
                const Color(0xff4B1D2F).withOpacity(0.3),
                const Color(0xff4B1D2F).withOpacity(0.0),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ],
      lineTouchData: LineTouchData(
        enabled: true,
        handleBuiltInTouches:
            false, // Disable default popup, handle via callback
        touchCallback: (FlTouchEvent event, LineTouchResponse? touchResponse) {
          if (event is FlPointerHoverEvent || event is FlTapDownEvent) {
            if (touchResponse?.lineBarSpots?.isNotEmpty ?? false) {
              final spotIndex = touchResponse!.lineBarSpots!.first.spotIndex;
              // Update immediately on hover/down for responsiveness
              if (selectedSpotIndex != spotIndex) {
                updateSelectedIndex(spotIndex);
              }
            } else {
              // If not touching a spot, clear selection
              if (selectedSpotIndex != null) {
                updateSelectedIndex(null);
              }
            }
          } else if (event is FlTapUpEvent || event is FlPointerExitEvent) {
            // Optionally clear selection on tap up or pointer exit if desired
            // if (selectedSpotIndex != null) {
            //   updateSelectedIndex(null);
            // }
          }
        },
        getTouchedSpotIndicator: (barData, indicators) {
          // Custom indicator (optional)
          return indicators.map((index) {
            return TouchedSpotIndicatorData(
              FlLine(
                  color: Colors.orangeAccent.withOpacity(0.5),
                  strokeWidth: 1), // Vertical line
              FlDotData(
                getDotPainter: (spot, percent, bar, index) =>
                    FlDotCirclePainter(
                  radius: 8, // Indicator dot size
                  color: Colors.orangeAccent,
                ),
              ),
            );
          }).toList();
        },
        touchTooltipData: LineTouchTooltipData(
          // tooltipBgColor:
          //     const Color(0xFF800000).withOpacity(0.8), // Tooltip background
          tooltipRoundedRadius: 8,
          tooltipPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          getTooltipItems: (touchedSpots) {
            return touchedSpots.map((touchedSpot) {
              final String text =
                  touchedSpot.y.toStringAsFixed(0); // Format value
              return LineTooltipItem(
                text,
                jerseyStyle(16, Colors.white), // Tooltip text style
              );
            }).toList();
          },
        ),
      ),
      // Use maxY based on calculated max value plus some padding
      minY: 0, // Always start Y axis at 0
      maxY: (maxYValue * 1.1).ceilToDouble(), // Add 10% padding to max Y
    );
  }

  Widget buildInfoColumn(
      String label, String value, String fullForm, String description) {
    return InkWell(
      // Use InkWell for tap feedback
      onTap: () => showInfoDialog(fullForm, description),
      borderRadius: BorderRadius.circular(8), // Match tap area to visual shape
      child: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: 8, vertical: 12), // Adjust padding
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center, // Center row content
              children: [
                Text(label, style: jerseyStyle(20, Colors.white)),
                const SizedBox(width: 6),
                const Icon(Icons.info_outline,
                    color: Colors.white70, size: 18), // Slightly faded icon
              ],
            ),
            const SizedBox(height: 10),
            Text(value,
                style: jerseyStyle(24, Colors.white)
                    .copyWith(fontWeight: FontWeight.bold)), // Bold value
          ],
        ),
      ),
    );
  }

  Widget verticalDivider() {
    return Container(
      width: 1,
      color: Colors.white.withOpacity(0.5), // Make divider less prominent
      margin:
          const EdgeInsets.symmetric(vertical: 16), // Adjust vertical margin
    );
  }

  void showInfoDialog(String title, String description) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title, style: jerseyStyle(20, const Color(0xFF800000))),
        content: Text(description, style: TextStyle(fontSize: 16)),
        actions: [
          TextButton(
            child: Text("Close",
                style: TextStyle(color: Color(0xFF800000), fontSize: 16)),
            onPressed: () => Navigator.pop(context),
          ),
        ],
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15)), // Rounded corners
      ),
    );
  }
}
