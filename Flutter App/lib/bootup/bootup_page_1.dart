// bootup_page_1.dart

import 'package:flutter/material.dart';
import 'bootup_page_2.dart';
import 'package:login_signup_1/style.dart';
import 'dart:math';

class BootupPage1 extends StatelessWidget {
  const BootupPage1({super.key});

  @override
  Widget build(BuildContext context) {
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
      backgroundColor: Colors.transparent,
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
                // Wrap Text with DefaultTextStyle to ensure it receives the style in the test
                DefaultTextStyle(
                  style: jerseyStyle(96),
                  child: Text(
                    'U-Fit',
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 16),
                DefaultTextStyle(
                  style: jerseyStyle(20),
                  child: Text(
                    selectedQuote,
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 100),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: brightWhite,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    slideTo(context, const BootupPage2(), useFadeSlide: true);
                  },
                  child: Text(
                    'Get Started',
                    style: jerseyStyle(
                      40,
                      darkMaroon,
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
