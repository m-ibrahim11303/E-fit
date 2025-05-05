import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:login_signup_1/bootup/forget_password/forgot_password_page_1.dart';
import 'package:login_signup_1/bootup/forget_password/forgot_password_page_3.dart';
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
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  final storage = const FlutterSecureStorage();
  bool _isLoadingContinue = false;
  bool _isLoadingResend = false;

  @override
  void initState() {
    super.initState();
    _codeControllers[0].text = '';
    _codeControllers[1].text = '';
    _codeControllers[2].text = '';
    _codeControllers[3].text = '';
    _codeControllers[4].text = '';
    _codeControllers[5].text = '';
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
        style: jerseyStyle(24, darkMaroon),
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
          // maybe change here
          if (value.length == 1 && index < 6) {
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
      _isLoadingResend = true;
    });

    final userData = {
      'email': widget.email,
    };

      final response = await http.post(
        Uri.parse(
            'https://e-fit-backend.onrender.com/forget-password/send-code'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(userData),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        _showResultPopup('Code resent successfully!', true);
        setState(() {
          _isLoadingResend = false;
        });
      } else {
        _showResultPopup(
            'Failed to resend code: Server error ${response.statusCode}',
            false);
        setState(() {
          _isLoadingResend = false;
        });
      }
  }

  Future<void> _verifyCodeAndNavigate() async {
    String codeString =
        _codeControllers.map((controller) => controller.text).join();
    if (codeString.length != 6 || !RegExp(r'^\d{6}$').hasMatch(codeString)) {
      _showResultPopup('Please enter a valid 6-digit code', false);
      return;
    }
    String codeInt = codeString.toString();
    String code = codeInt.toString();

    setState(() {
      _isLoadingContinue = true;
    });

    final userData = {
      'email': widget.email,
      'code': code,
    };

    final response = await http.post(
      Uri.parse(
          'https://e-fit-backend.onrender.com/forget-password/verify-code'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(userData),
    );

    if (response.statusCode == 200) {
      slideTo(context, ForgotPasswordPage3(email: widget.email, code: code));
    } else {
      _showResultPopup(
          'Verification failed: Invalid response from server', false);
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
                    style: jerseyStyle(34, Colors.white),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Please enter the 6 digit code sent to\n${widget.email}',
                    style: jerseyStyle(18, Colors.white),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                        6, (index) => _buildCodeInputField(index)),
                  ),
                  const SizedBox(height: 20),
                  TextButton(
                    onPressed: _isLoadingResend
                        ? null
                        : _resendCode,
                    child: _isLoadingResend
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
                            'Resend Code',
                            style: jerseyStyle(18, brightWhite),
                          ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: brightWhite,
                      fixedSize: const Size(200, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: _isLoadingContinue
                        ? null
                        : _verifyCodeAndNavigate,
                    child: _isLoadingContinue
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(darkMaroon),
                            ),
                          )
                        : Text(
                            'Continue',
                            style: jerseyStyle(20, darkMaroon),
                          ),
                  ),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: () {
                      slideTo(context, const ForgotPasswordPage1());
                    },
                    child: Text(
                      'Change Email',
                      style: jerseyStyle(18, brightWhite),
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
