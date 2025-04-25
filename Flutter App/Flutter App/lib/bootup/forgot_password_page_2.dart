import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:login_signup_1/bootup/signup_page_1.dart';
import 'package:login_signup_1/bootup/signup_page_3.dart';
import 'package:login_signup_1/bootup/forgot_password_page_1.dart';
import 'package:login_signup_1/bootup/forgot_password_page_3.dart';
import 'package:login_signup_1/style.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ForgotPasswordPage2 extends StatefulWidget {
  final String email;

  const ForgotPasswordPage2({
    Key? key,
    required this.email,
  }) : super(key: key);

  @override
  _ForgotPasswordPage2State createState() => _ForgotPasswordPage2State();
}

class _ForgotPasswordPage2State extends State<ForgotPasswordPage2> {
  final List<TextEditingController> _codeControllers =
      List.generate(4, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(4, (_) => FocusNode());
  final storage = const FlutterSecureStorage();
  bool _isLoadingContinue = false; // Track loading state for Continue button
  bool _isLoadingResend = false; // Track loading state for Resend Code button

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
    setState(() {
      _isLoadingResend = true; // Show loading for Resend Code
    });

    final userData = {
      'email': widget.email,
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
    } finally {
      setState(() {
        _isLoadingResend = false; // Hide loading for Resend Code
      });
    }
  }

  Future<void> _verifyCodeAndNavigate() async {
    String codeString =
        _codeControllers.map((controller) => controller.text).join();
    if (codeString.length != 4 || !RegExp(r'^\d{4}$').hasMatch(codeString)) {
      _showResultPopup('Please enter a valid 4-digit code', false);
      return;
    }
    int code = int.parse(codeString);

    setState(() {
      _isLoadingContinue = true; // Show loading for Continue
    });

    final userData = {
      'email': widget.email,
      'code': code,
    };

    try {
      final response = await http.post(
        Uri.parse('http://10.130.93.109:3000/user/verify'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(userData),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);

        if (responseData['email'] != null || responseData['success'] == true) {
          slideTo(context, ForgotPasswordPage3());
        } else {
          await _showResultPopup(
            'Verification failed: Invalid response from server',
            false,
          );
          slideTo(context, ForgotPasswordPage3());
        }
      } else {
        await _showResultPopup(
          'Verification failed: Invalid response from server',
          false,
        );
        slideTo(context, ForgotPasswordPage3());
      }
    } catch (e) {
      await _showResultPopup(
        'Verification failed: Invalid response from server',
        false,
      );
      slideTo(context, ForgotPasswordPage3());
    } finally {
      setState(() {
        _isLoadingContinue = false; // Hide loading for Continue
      });
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
                    onPressed: _isLoadingResend
                        ? null
                        : _resendCode, // Disable when loading
                    child: _isLoadingResend
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(
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
                    onPressed: _isLoadingContinue
                        ? null
                        : _verifyCodeAndNavigate, // Disable when loading
                    child: _isLoadingContinue
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
                      slideTo(context, const ForgotPasswordPage1());
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
