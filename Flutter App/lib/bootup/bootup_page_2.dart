// bootup_page_2.dart
import 'package:flutter/material.dart';
import 'bootup_page_3.dart';
import 'package:login_signup_1/style.dart';

class BootupPage2 extends StatelessWidget {
  const BootupPage2({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/background_bootup_page_2.png'),
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
                      style: jerseyStyle(48, brightWhite),
                      child: Text(
                        'Track Your Diet',
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 10),
                    DefaultTextStyle(
                      style: jerseyStyle(24, brightWhite),
                      child: Text(
                        'Track your meals and get custom AI advice',
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
              const SizedBox.shrink(),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding:
                        const EdgeInsets.only(top: 40.0, right: 50, bottom: 5),
                    child: Container(
                      width: 35,
                      height: 5,
                      decoration: ShapeDecoration(
                        color: lightMaroon,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4.0),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                key: const Key('bootupPage2NextButton'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  shape: const CircleBorder(),
                  padding: const EdgeInsets.all(24.0),
                ),
                onPressed: () {
                  slideTo(context, const BootupPage3(), useFadeSlide: true);
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
