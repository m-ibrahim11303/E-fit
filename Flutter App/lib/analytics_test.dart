import 'dart:convert';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

TextStyle jerseyStyle(double fontSize, [Color color = Colors.white]) {
  return TextStyle(
    fontFamily: 'Jersey 25',
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
  int? _selectedSpotIndexSteps;
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

    try {
      // Fetch chart data
      final chartResponse = await http.get(
        Uri.parse(
            'https://e-fit-backend.onrender.com/analytics/charts?email=$email'),
      );

      // Fetch streak data
      final streakResponse = await http.get(
        Uri.parse(
            'https://e-fit-backend.onrender.com/user/streaks?email=$email'),
      );

      if (chartResponse.statusCode == 200) {
        final chartJsonData = jsonDecode(chartResponse.body);
        if (chartJsonData['success'] == true) {
          setState(() {
            _chartData = List<Map<String, dynamic>>.from(chartJsonData['data']);
            _bmi = (chartJsonData['bmi'] as num?)?.toDouble();
            _bmr = (chartJsonData['bmr'] as num?)?.toDouble();
            _tdee = (chartJsonData['tdee'] as num?)?.toDouble();
          });
        }
      }

      if (streakResponse.statusCode == 200) {
        final streakJsonData = jsonDecode(streakResponse.body);
        print(streakJsonData);
        if (streakJsonData['success'] == true) {
          setState(() {
            _streak = (streakJsonData['streak'] as num?)?.toInt();
          });
        }
      }
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: _chartData == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    color: const Color(0xFF800000),
                    child: SafeArea(
                      bottom: false,
                      child: Container(
                        height: 44,
                        color: const Color(0xFF800000),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                        left: 10, right: 40, top: 20, bottom: 20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        buildGraphSection('Steps', Icons.directions_walk,
                            _selectedSpotIndexSteps, (index) {
                          setState(() {
                            _selectedSpotIndexSteps = index;
                          });
                        }, screenHeight, []),
                        const SizedBox(height: 32),
                        buildGraphSection(
                            'Calories',
                            Icons.local_fire_department,
                            _selectedSpotIndexCalories, (index) {
                          setState(() {
                            _selectedSpotIndexCalories = index;
                          });
                        },
                            screenHeight,
                            _chartData?.firstWhere((data) =>
                                    data['title'] == 'Calories')['y_vals'] ??
                                []),
                        const SizedBox(height: 32),
                        buildGraphSection(
                            'Protein', Icons.biotech, _selectedSpotIndexProtein,
                            (index) {
                          setState(() {
                            _selectedSpotIndexProtein = index;
                          });
                        },
                            screenHeight,
                            _chartData?.firstWhere((data) =>
                                    data['title'] == 'Proteins')['y_vals'] ??
                                []),
                        const SizedBox(height: 32),
                        buildGraphSection(
                            'Water', Icons.water_drop, _selectedSpotIndexWater,
                            (index) {
                          setState(() {
                            _selectedSpotIndexWater = index;
                          });
                        },
                            screenHeight,
                            _chartData?.firstWhere((data) =>
                                    data['title'] ==
                                    'Water Intake')['y_vals'] ??
                                []),
                        const SizedBox(height: 32),
                        Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 24),
                            margin: const EdgeInsets.only(bottom: 32),
                            decoration: BoxDecoration(
                              color: const Color(0xFF800000),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: IntrinsicHeight(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  buildInfoColumn(
                                      'BMI',
                                      _bmi?.toStringAsFixed(1) ?? 'N/A',
                                      'Body Mass Index',
                                      'A measure of body fat based on height and weight.'),
                                  verticalDivider(),
                                  buildInfoColumn(
                                      'BMR',
                                      _bmr?.toStringAsFixed(0) ?? 'N/A',
                                      'Basal Metabolic Rate',
                                      'The number of calories your body burns at rest.'),
                                  verticalDivider(),
                                  buildInfoColumn(
                                      'TDEE',
                                      _tdee?.toStringAsFixed(0) ?? 'N/A',
                                      'Total Daily Energy Expenditure',
                                      'Estimated calories burned per day including activity.'),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 24),
                            margin: const EdgeInsets.only(bottom: 32),
                            decoration: BoxDecoration(
                              color: const Color(0xFF800000),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text('Streak',
                                        style: jerseyStyle(20, Colors.white)),
                                    const SizedBox(width: 4),
                                    const Icon(Icons.local_fire_department,
                                        color: Colors.white, size: 18),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _streak?.toString() ?? 'N/A',
                                  style: jerseyStyle(24, Colors.white),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
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
          height: screenHeight / 4,
          child: AspectRatio(
            aspectRatio: 1.5,
            child: LineChart(mainData(title, selectedIndex, onTouch, yValues)),
          ),
        ),
      ],
    );
  }

  LineChartData mainData(String graphType, int? selectedSpotIndex,
      Function(int?) updateSelectedIndex, List<dynamic> yValues) {
    List<String> days = ['Sat', 'Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Today'];

    List<FlSpot> spots = yValues.isNotEmpty
        ? List.generate(yValues.length,
            (index) => FlSpot(index.toDouble(), yValues[index].toDouble()))
        : [
            const FlSpot(0, 0),
            const FlSpot(1, 0),
            const FlSpot(2, 0),
            const FlSpot(3, 0),
            const FlSpot(4, 0),
            const FlSpot(5, 0),
            const FlSpot(6, 0),
          ];

    return LineChartData(
      gridData: FlGridData(show: false),
      borderData: FlBorderData(
        show: true,
        border: const Border(
          bottom: BorderSide(color: Colors.black, width: 2),
          left: BorderSide(color: Colors.black, width: 2),
        ),
      ),
      titlesData: FlTitlesData(
        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 50,
            interval: graphType == 'Water'
                ? 200
                : (graphType == 'Protein' ? 10 : 100),
            getTitlesWidget: (value, meta) {
              if (value %
                      (graphType == 'Water'
                          ? 200
                          : (graphType == 'Protein' ? 10 : 100)) ==
                  0) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Text(
                    value.toInt().toString(),
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
            interval: 1,
            reservedSize: 40,
            getTitlesWidget: (value, meta) {
              if (value.toInt() >= 0 && value.toInt() < days.length) {
                return Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(
                    days[value.toInt()],
                    style: jerseyStyle(18, const Color(0xFF800000)),
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
          isCurved: false,
          barWidth: 2,
          isStrokeCapRound: true,
          color: const Color(0xff4B1D2F),
          dotData: FlDotData(
            show: true,
            getDotPainter: (spot, percent, bar, index) => FlDotCirclePainter(
              radius: 6,
              color: const Color(0xff4B1D2F),
              strokeWidth: 0,
            ),
          ),
          belowBarData: BarAreaData(show: false),
        ),
      ],
      lineTouchData: LineTouchData(
        enabled: true,
        handleBuiltInTouches: true,
        touchCallback: (FlTouchEvent event, LineTouchResponse? touchResponse) {
          if (!event.isInterestedForInteractions ||
              touchResponse == null ||
              touchResponse.lineBarSpots == null) {
            if (selectedSpotIndex != null && event is FlTapUpEvent) {
              updateSelectedIndex(null);
            }
            return;
          }
          if (event is FlTapUpEvent) {
            final spotIndex = touchResponse.lineBarSpots!.first.spotIndex;
            updateSelectedIndex(spotIndex);
          }
        },
        getTouchedSpotIndicator: (barData, indicators) =>
            indicators.map((index) {
          return TouchedSpotIndicatorData(
            FlLine(color: Colors.transparent),
            FlDotData(show: false),
          );
        }).toList(),
        touchTooltipData: LineTouchTooltipData(
          fitInsideHorizontally: true,
          tooltipRoundedRadius: 4,
          getTooltipItems: (touchedSpots) {
            if (selectedSpotIndex != null) {
              final selectedSpot = spots[selectedSpotIndex!];
              return [
                LineTooltipItem(
                  selectedSpot.y.toInt().toString(),
                  jerseyStyle(14, const Color(0xFF800000)),
                ),
              ];
            }
            return touchedSpots.map((touchedSpot) {
              return LineTooltipItem(
                touchedSpot.y.toInt().toString(),
                jerseyStyle(14, const Color(0xFF800000)),
              );
            }).toList();
          },
        ),
      ),
    );
  }

  Widget buildInfoColumn(
      String label, String value, String fullForm, String description) {
    return GestureDetector(
      onTap: () => showInfoDialog(fullForm, description),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Text(label, style: jerseyStyle(20, Colors.white)),
                const SizedBox(width: 4),
                const Icon(Icons.info_outline, color: Colors.white, size: 18),
              ],
            ),
            const SizedBox(height: 8),
            Text(value, style: jerseyStyle(24, Colors.white)),
          ],
        ),
      ),
    );
  }

  Widget verticalDivider() {
    return Container(
      width: 1,
      color: Colors.white,
      margin: const EdgeInsets.symmetric(vertical: 8),
    );
  }

  void showInfoDialog(String title, String description) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title, style: jerseyStyle(20, const Color(0xFF800000))),
        content: Text(description),
        actions: [
          TextButton(
            child: const Text("Close"),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}
