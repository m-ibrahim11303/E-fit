import 'package:flutter/material.dart';
import 'package:login_signup_1/bootup/login_page_1.dart';
import 'package:login_signup_1/bootup/signup_page_1.dart';
import 'bootup_page_4.dart';


class LoginSignupPage1 extends StatelessWidget {
  const LoginSignupPage1({super.key});

  TextStyle jerseyStyle(double fontSize, [Color color = Colors.white]) {
    return TextStyle(
      fontFamily: 'Jersey 25',
      fontSize: fontSize,
      color: color,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image:
                AssetImage('assets/images/background_login_signup_page_1.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // "U-Fit" text aligned to the left
              Container(
                width: double.infinity,
                padding: const EdgeInsets.only(left: 20.0, top: 100),
                child: Text(
                  'U-Fit',
                  style: jerseyStyle(96),
                  textAlign: TextAlign.left,
                ),
              ),
              const SizedBox(height: 240),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Personalized Fitness',
                      style: jerseyStyle(34),
                      textAlign: TextAlign.left,
                    ),
                    Text(
                      'Tag-line Lorem ipsum dolor sit amet, consectetur adipiscing elit',
                      style: jerseyStyle(18),
                      textAlign: TextAlign.left,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white, // White background
                    fixedSize: const Size(350, 59), // Width 323, Height 59
                    elevation: 0, // Remove shadow if needed
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        transitionDuration: const Duration(milliseconds: 500),
                        pageBuilder: (context, animation, secondaryAnimation) =>
                            const LoginPage1(),
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
                    'Log in',
                    style: jerseyStyle(24, const Color(0xFF562634)),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF562634),
                    fixedSize: const Size(350, 59),
                    elevation: 0,
                    side: const BorderSide(
                      color: Colors.white,
                      width: 2,
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        transitionDuration: const Duration(milliseconds: 500),
                        pageBuilder: (context, animation, secondaryAnimation) =>
                            const SignupPage1(),
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
                    'Sign up',
                    style: jerseyStyle(24),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Text(
                  'Log in with social media',
                  style: jerseyStyle(20, const Color(0x90FFFFFF)),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 20),
              // Row for the social media buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: () {
                      // Handle Google login
                    },
                    icon: Image.asset(
                      'assets/images/google_icon.png',
                      width: 50, // Set desired width
                      height: 50, // Set desired height
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(width: 20),
                  IconButton(
                    onPressed: () {
                      // Handle Facebook login
                    },
                    icon: Image.asset(
                      'assets/images/facebook_icon.png',
                      width: 50,
                      height: 50,
                      fit: BoxFit.contain,
                    ),
                  ),
                ],
              ),

              // const SizedBox(height: 70),
            ],
          ),
        ),
      ),
    );
  }
}
