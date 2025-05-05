// bootup_page_4.dart
import 'package:flutter/material.dart';
import 'login_signup_page_1.dart';
import 'package:login_signup_1/style.dart';

class BootupPage4 extends StatelessWidget {
  const BootupPage4({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/background_bootup_page_4.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const Spacer(flex: 5),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  children: [
                    // Wrap Text with DefaultTextStyle
                    DefaultTextStyle(
                      style: jerseyStyle(48, Color(0xFFFFFFFF)),
                      child: Text(
                        'Discussion Forum',
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 10),
                    DefaultTextStyle(
                      style: jerseyStyle(24, Color(0xFFFFFFFF)),
                      child: Text(
                        'A community space for you to share experiences, ask questions, and engage with others.',
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
              const SizedBox.shrink(),
              const SizedBox(height: 10),
              const SizedBox(height: 20),
              ElevatedButton(
                key: const Key('bootupPage4NextButton'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFFFFFFF),
                  shape: const CircleBorder(),
                  padding: const EdgeInsets.all(24.0),
                ),
                onPressed: () {
                  slideTo(context, const LoginSignupPage1(),
                      useFadeSlide: true);
                },
                child: Image.asset(
                  'assets/images/bootup_right_arrow_icon.png',
                  width: 32,
                  height: 32,
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
