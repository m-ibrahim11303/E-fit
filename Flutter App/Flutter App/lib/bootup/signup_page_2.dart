import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:login_signup_1/bootup/signup_page_1.dart';
import 'package:login_signup_1/bootup/signup_page_3.dart';
import 'package:login_signup_1/style.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SignUpPage2 extends StatefulWidget {
  final String email;
  final String name;
  final String password;

  const SignUpPage2({
    Key? key,
    required this.email,
    required this.password,
    required this.name,
  }) : super(key: key);

  @override
  _SignUpPage2State createState() => _SignUpPage2State();
}

class _SignUpPage2State extends State<SignUpPage2> {
  final List<TextEditingController> _codeControllers =
      List.generate(4, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(4, (_) => FocusNode());
  final storage = const FlutterSecureStorage();

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
    // Prepare the data for the resend code POST request
    final userData = {
      'email': widget.email,
    };

    try {
      // Make POST request to resend code
      final response = await http.post(
        // Uri.parse('https://e-fit-backend.onrender.com/resend-code'),
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
    // Combine the 4 digits into a single integer
    String codeString =
        _codeControllers.map((controller) => controller.text).join();
    if (codeString.length != 4 || !RegExp(r'^\d{4}$').hasMatch(codeString)) {
      _showResultPopup('Please enter a valid 4-digit code', false);
      return;
    }
    int code = int.parse(codeString);

    // Prepare the data for the POST request
    final userData = {
      'email': widget.email,
      'code': code,
    };

    try {
      // Make POST request to verify the code
      final response = await http.post(
        // Uri.parse('https://e-fit-backend.onrender.com/user/verify'),
        Uri.parse('http://10.130.93.109:3000/user/verify'), // For Android emulator
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(userData),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Parse the response
        final responseData = jsonDecode(response.body);

        // Check if response contains email or success indicator
        if (responseData['email'] != null || responseData['success'] == true) {
          // Store email in secure storage
          await storage.write(key: 'email', value: widget.email);

          // Navigate to SignUpPage3

          slideTo(
              context,
              SignUpPage3(
                email: widget.email,
                password: widget.password,
                name: widget.name,
              ));
        } else {
          await _showResultPopup(
            'Verification failed: Invalid response from server',
            false,
          );
          slideTo(
              context,
              SignUpPage3(
                email: widget.email,
                password: widget.password,
                name: widget.name,
              ));
        }
      } else {
        await _showResultPopup(
          'Verification failed: Invalid response from server',
          false,
        );
        slideTo(
            context,
            SignUpPage3(
              email: widget.email,
              password: widget.password,
              name: widget.name,
            ));
      }
    } catch (e) {
      await _showResultPopup(
        'Verification failed: Invalid response from server',
        false,
      );
      slideTo(
          context,
          SignUpPage3(
            email: widget.email,
            password: widget.password,
            name: widget.name,
          ));
    }
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
                    'Verify your email',
                    style: jerseyStyle(32, Colors.white),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Please enter the 4 digit code sent to\n${widget.email}',
                    style: jerseyStyle(16, Colors.white),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                        4, (index) => _buildCodeInputField(index)),
                  ),
                  const SizedBox(height: 20),
                  TextButton(
                    onPressed: _resendCode, // Updated to handle resend code
                    child: Text(
                      'Resend Code',
                      style: jerseyStyle(16, Colors.white),
                    ),
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
                    onPressed: _verifyCodeAndNavigate,
                    child: Text(
                      'Continue',
                      style: jerseyStyle(20, Colors.black),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          transitionDuration: const Duration(milliseconds: 500),
                          pageBuilder:
                              (context, animation, secondaryAnimation) =>
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
                      'Change Email',
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
