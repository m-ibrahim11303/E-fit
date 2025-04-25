import 'package:flutter/material.dart';
import 'bootup_page_2.dart';
import 'dart:math';

class BootupPage1 extends StatelessWidget {
  const BootupPage1({super.key});

  @override
  Widget build(BuildContext context) {
    // Helper method to create a TextStyle with the "Jersey 25" font.
    TextStyle jerseyStyle(double fontSize, [Color color = Colors.white]) {
      return TextStyle(
        fontFamily: 'Jersey 25',
        fontSize: fontSize,
        color: color,
      );
    }

    final List<String> motivationalQuotes = [
      "Push yourself, because no one else is going to do it for you.",
      "Success starts with self-discipline.",
      "Your body can stand almost anything. It’s your mind that you have to convince.",
      "Don’t limit your challenges. Challenge your limits.",
      "Train insane or remain the same.",
    ];

    final String selectedQuote =
        motivationalQuotes[Random().nextInt(motivationalQuotes.length)];

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/background.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'U-Fit',
                  style: jerseyStyle(96),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  selectedQuote,
                  style: jerseyStyle(20),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 100),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        transitionDuration: const Duration(milliseconds: 500),
                        pageBuilder: (context, animation, secondaryAnimation) =>
                            const BootupPage2(),
                        transitionsBuilder:
                            (context, animation, secondaryAnimation, child) {
                          const begin = Offset(1.0, 0.0);
                          const end = Offset.zero;
                          final tween = Tween(begin: begin, end: end);
                          final offsetAnimation = animation.drive(tween);

                          return SlideTransition(
                            position: offsetAnimation,
                            child: child,
                          );
                        },
                      ),
                    );
                  },
                  child: Text(
                    'Get Started',
                    style: jerseyStyle(
                      40,
                      const Color(0xFF562634),
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
