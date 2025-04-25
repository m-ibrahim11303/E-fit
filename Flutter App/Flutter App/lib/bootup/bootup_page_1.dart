import 'package:flutter/material.dart';
import 'package:login_signup_1/style.dart';
import 'bootup_page_2.dart';

class BootupPage1 extends StatelessWidget {
  const BootupPage1({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // Background image from assets/images/background.png
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
                // Heading: "U-Fit"
                Text(
                  'U-Fit',
                  style: jerseyStyle(96),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                // Tagline
                Text(
                  'Tag-line Lorem ipsum dolor sit amet, consectetur adipiscing elit',
                  style: jerseyStyle(20),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 100),
                // "Get Started" button
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
                    // Slide-left transition to bootup_page_2.dart
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
