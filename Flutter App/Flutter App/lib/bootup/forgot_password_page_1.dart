import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:login_signup_1/bootup/signup_page_1.dart';
import 'package:login_signup_1/bootup/login_page_1.dart';
import 'package:login_signup_1/bootup/forgot_password_page_2.dart';
import 'package:login_signup_1/style.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ForgotPasswordPage1 extends StatefulWidget {
  const ForgotPasswordPage1({Key? key}) : super(key: key);

  @override
  _ForgotPasswordPage1State createState() => _ForgotPasswordPage1State();
}

class _ForgotPasswordPage1State extends State<ForgotPasswordPage1> {
  final List<TextEditingController> _codeControllers =
      List.generate(4, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(4, (_) => FocusNode());
  final TextEditingController emailController = TextEditingController();
  final storage = const FlutterSecureStorage();
  bool _isLoading = false; // Added to track loading state

  @override
  void initState() {
    super.initState();
    _codeControllers[0].text = '';
    _codeControllers[1].text = '';
    _codeControllers[2].text = '';
    _codeControllers[3].text = '';
  }

  @override
  void dispose() {
    emailController.dispose();
    for (var controller in _codeControllers) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  Widget _buildCodeInputField(int index) {
    return Container(
      width: 50,
      height: 50,
      margin: const EdgeInsets.symmetric(horizontal: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextField(
        controller: _codeControllers[index],
        focusNode: _focusNodes[index],
        textAlign: TextAlign.center,
        style: jerseyStyle(24, Colors.black),
        keyboardType: TextInputType.number,
        maxLength: 1,
        decoration: const InputDecoration(
          counterText: '',
          border: InputBorder.none,
        ),
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
        ],
        onChanged: (value) {
          if (value.length == 1 && index < 3) {
            _focusNodes[index].unfocus();
            FocusScope.of(context).requestFocus(_focusNodes[index + 1]);
          } else if (value.isEmpty && index > 0) {
            _focusNodes[index].unfocus();
            FocusScope.of(context).requestFocus(_focusNodes[index - 1]);
          }
        },
      ),
    );
  }

  Future<void> _showResultPopup(String message, bool isSuccess) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isSuccess ? 'Success' : 'Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _resendCode() async {
    if (emailController.text.isEmpty) {
      _showResultPopup('Please enter your email', false);
      return;
    }

    final userData = {
      'email': emailController.text,
    };

    try {
      final response = await http.post(
        Uri.parse('http://10.130.93.109:3000/resend-code'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(userData),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        _showResultPopup('Code resent successfully!', true);
      } else {
        _showResultPopup(
            'Failed to resend code: Server error ${response.statusCode}',
            false);
      }
    } catch (e) {
      _showResultPopup('Failed to resend code: $e', false);
    }
  }

  Future<void> _verifyCodeAndNavigate() async {
    if (emailController.text.isEmpty) {
      _showResultPopup('Please enter your email', false);
      return;
    }

    setState(() {
      _isLoading = true; // Show loading circle
    });

    final userData = {
      'email': emailController.text,
    };

    try {
      final response = await http.post(
        Uri.parse('http://10.130.93.109:3000/forgot-password/send-code'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(userData),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);

        if (responseData['email'] != null && responseData['success'] == true) {
          await storage.write(key: 'email', value: emailController.text);
          slideTo(context, ForgotPasswordPage2(email: emailController.text));
        } else {
          await _showResultPopup(
            'Email not sent. Please try again.',
            false,
          );
          slideTo(context, ForgotPasswordPage2(email: emailController.text));
        }
      } else {
        await _showResultPopup(
          'Verification failed: Email not sent.',
          false,
        );
        slideTo(context, ForgotPasswordPage2(email: emailController.text));
      }
    } catch (e) {
      await _showResultPopup(
        'An error occurred: Unable to reach the server or send OTP.',
        false,
      );
      slideTo(context, ForgotPasswordPage2(email: emailController.text));
    } finally {
      setState(() {
        _isLoading = false; // Hide loading circle
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
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: jerseyStyle(20, Colors.black),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: jerseyStyle(20, Colors.grey),
          border: InputBorder.none,
          suffixIcon: suffixIcon,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                    style: jerseyStyle(32, Colors.white),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Please enter your email',
                    style: jerseyStyle(16, Colors.white),
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
                      backgroundColor: Colors.white,
                      fixedSize: const Size(200, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: _isLoading
                        ? null
                        : _verifyCodeAndNavigate, // Disable button when loading
                    child: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.black),
                            ),
                          )
                        : Text(
                            'Continue',
                            style: jerseyStyle(20, Colors.black),
                          ),
                  ),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: () {
                      slideTo(context, const LoginPage1());
                    },
                    child: Text(
                      'Go back to login',
                      style: jerseyStyle(16, Colors.white),
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
