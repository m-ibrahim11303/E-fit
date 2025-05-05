import 'package:flutter/material.dart';
import 'analytics_test.dart';
import 'workout_history_screen.dart';
import 'diet_history_screen.dart';

const Color primaryColor = Color(0xFF562634);

class AnalyticsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double horizontalPadding = 40.0;
    double buttonSpacing = 20.0;
    double availableWidth = screenWidth - horizontalPadding - buttonSpacing;
    double historyButtonWidth = availableWidth / 2;
    double historyButtonHeight = historyButtonWidth * 0.8;

    double largeButtonWidth = screenWidth * 0.7;
    double largeButtonHeight = largeButtonWidth * 0.4;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Analytics'),
        backgroundColor: primaryColor,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20,
        ),
      ),
      body: Container(
        color: Colors.grey[100],
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
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
              Expanded(
                child: Center(
                  child: _CustomButton(
                    icon: Icons.bar_chart,
                    label: 'Detailed\nAnalytics',
                    color: primaryColor,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ActivityGraphScreen()),
                      );
                    },
                    buttonSize: Size(largeButtonWidth, largeButtonHeight),
                  ),
                ),
              ),
            ],
          ),
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