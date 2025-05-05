// bootup_page_3.dart
import 'package:flutter/material.dart';
import 'bootup_page_4.dart';
import 'package:login_signup_1/style.dart';

class BootupPage3 extends StatelessWidget {
  const BootupPage3({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/background_bootup_page_3.png'),
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
                        'Track Your Movement',
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 10),
                    DefaultTextStyle(
                      style: jerseyStyle(24, Color(0xFFFFFFFF)),
                      child: Text(
                        'Track your workouts & physical activity and get custom AI recommendations based on your personal goals',
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
                key: const Key('bootupPage3NextButton'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFFFFFFF),
                  shape: const CircleBorder(),
                  padding: const EdgeInsets.all(24.0),
                ),
                onPressed: () {
                  slideTo(context, const BootupPage4(), useFadeSlide: true);
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
