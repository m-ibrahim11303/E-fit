import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:login_signup_1/bootup/login_page_1.dart';
import 'package:login_signup_1/bootup/forget_password/forgot_password_page_2.dart';
import 'package:login_signup_1/style.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ForgotPasswordPage1 extends StatefulWidget {
  const ForgotPasswordPage1({Key? key}) : super(key: key);

  @override
  _ForgotPasswordPage1State createState() => _ForgotPasswordPage1State();
}

class _ForgotPasswordPage1State extends State<ForgotPasswordPage1> {
  final TextEditingController emailController = TextEditingController();
  final storage = const FlutterSecureStorage();
  bool _isLoading = false;

  Future<void> _showResultPopup(
      BuildContext context, String message, bool isSuccess) async {
    final Color titleColor = isSuccess ? darkMaroon : errorRed;
    final String titleText = isSuccess ? 'Success' : 'Error';

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          titleText,
          style: jerseyStyle(24, titleColor),
        ),
        content: Text(
          message,
          style: jerseyStyle(20, darkMaroon),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'OK',
              style: jerseyStyle(20, darkMaroon),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _verifyCodeAndNavigate() async {
    if (emailController.text.isEmpty) {
      _showResultPopup(context, 'Please enter your email', false);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final userData = {
      'email': emailController.text,
    };

    final response = await http.post(
      Uri.parse('https://e-fit-backend.onrender.com/forget-password/send-code'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(userData),
    );

    if (response.statusCode == 200) {
      slideTo(context, ForgotPasswordPage2(email: emailController.text));
      setState(() {
        _isLoading = false;
      });
    } else {
      await _showResultPopup(
        context,
        'Verification failed: Email not sent.',
        false,
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    TextInputType keyboardType = TextInputType.text,
    Widget? suffixIcon,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      decoration: BoxDecoration(
        border: Border.all(color: brightWhite),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: jerseyStyle(24, brightWhite),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: jerseyStyle(24, brightWhite),
          border: InputBorder.none,
          suffixIcon: suffixIcon,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/background_signup_page_2.png',
              fit: BoxFit.cover,
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 450),
                  Text(
                    'Verify your identity',
                    style: jerseyStyle(34, brightWhite),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Please enter your email',
                    style: jerseyStyle(18, brightWhite),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  _buildTextField(
                    controller: emailController,
                    hintText: 'Email',
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: brightWhite,
                      fixedSize: const Size(350, 59),
                      elevation: 0, 
                      side: BorderSide(
                        color: darkMaroon,
                        width: 2.0,
                      ),
                    ),
                    onPressed: _isLoading
                        ? null
                        : _verifyCodeAndNavigate,
                    child: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(brightWhite),
                            ),
                          )
                        : Text(
                            'Continue',
                            style: jerseyStyle(24, darkMaroon),
                          ),
                  ),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: () {
                      slideTo(context, const LoginPage1());
                    },
                    child: Text(
                      'Go back to login',
                      style: jerseyStyle(18, Colors.white),
                    ),
                  ),
                  const Spacer(flex: 3),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
