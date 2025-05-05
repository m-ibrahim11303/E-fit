import 'package:flutter/material.dart';
import 'package:login_signup_1/bootup/login_page_1.dart';
import 'package:login_signup_1/bootup/signup_page_1.dart';
import 'package:login_signup_1/style.dart';

class LoginSignupPage1 extends StatelessWidget {
  const LoginSignupPage1({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
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
              Container(
                width: double.infinity,
                padding: const EdgeInsets.only(left: 20.0, top: 100),
                child: Text(
                  'E-Fit',
                  style: jerseyStyle(96, brightWhite),
                  textAlign: TextAlign.left,
                ),
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Personalized Fitness',
                      style: jerseyStyle(34, brightWhite),
                      textAlign: TextAlign.left,
                    ),
                    Text(
                      'Ace your fitness like you ace your finals (or at least try).',
                      style: jerseyStyle(18, brightWhite),
                      textAlign: TextAlign.left,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              Center(
                child: ElevatedButton(
                  key: const Key('log_in_button'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: brightWhite,
                    fixedSize: const Size(350, 59),
                    elevation: 0,
                  ),
                  onPressed: () {
                    slideTo(context, LoginPage1());
                  },
                  child: Text(
                    'Log in',
                    style: jerseyStyle(24, darkMaroon),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  key: const Key('sign_up_button'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: darkMaroon,
                    fixedSize: const Size(350, 59),
                    elevation: 0,
                    side: const BorderSide(
                      color: brightWhite,
                      width: 2,
                    ),
                  ),
                  onPressed: () {
                    slideTo(context, SignupPage1());
                  },
                  child: Text(
                    'Sign up',
                    style: jerseyStyle(24, brightWhite),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
              ),
              const SizedBox(height: 20),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
