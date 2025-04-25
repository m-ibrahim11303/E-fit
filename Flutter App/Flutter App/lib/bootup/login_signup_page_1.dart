import 'package:flutter/material.dart';
import 'package:login_signup_1/bootup/login_page_1.dart';
import 'package:login_signup_1/bootup/signup_page_1.dart';
import 'package:login_signup_1/style.dart';

class LoginSignupPage1 extends StatelessWidget {
  const LoginSignupPage1({super.key});

  // TextStyle jerseyStyle(double fontSize, [Color color = Colors.white]) {
  //   return TextStyle(
  //     fontFamily: 'Jersey 25',
  //     fontSize: fontSize,
  //     color: color,
  //   );
  // }

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
              // "E-Fit" text aligned to the left at the top
              Container(
                width: double.infinity,
                padding: const EdgeInsets.only(left: 20.0, top: 100),
                child: Text(
                  'E-Fit',
                  style: jerseyStyle(96),
                  textAlign: TextAlign.left,
                ),
              ),
              // Spacer pushes the remaining content to the bottom
              const Spacer(),
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
                    backgroundColor: Colors.white,
                    fixedSize: const Size(350, 59),
                    elevation: 0,
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
                
              ),
              const SizedBox(height: 20),
              // Removed the Row containing Google and Facebook icons
              const SizedBox(height: 20), // Maintain bottom padding
            ],
          ),
        ),
      ),
    );
  }
}
