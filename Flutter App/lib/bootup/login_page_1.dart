import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:login_signup_1/bootup/forget_password/forgot_password_page_1.dart';
import 'login_signup_page_1.dart';
import 'package:login_signup_1/bootup/signup_page_1.dart';
import 'package:login_signup_1/home_page.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:login_signup_1/style.dart';

final FlutterSecureStorage storage = FlutterSecureStorage();

class EmailInputWidget extends StatefulWidget {
  final TextEditingController controller;
  final Function(bool) onValid;

  const EmailInputWidget(
      {Key? key, required this.controller, required this.onValid})
      : super(key: key);

  static String? validateEmailStatic(String value) {
    if (value.isEmpty) {
      return 'Email cannot be empty';
    }
    final emailRegex =
        RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    return null; 
  }

  @override
  _EmailInputWidgetState createState() => _EmailInputWidgetState();
}

class _EmailInputWidgetState extends State<EmailInputWidget> {
  String? _errorMessage;

  String? validateEmail(String value) {
    return EmailInputWidget.validateEmailStatic(value);
  }

  void _checkEmail(String value) {
    final newErrorMessage = validateEmail(value);
    if (newErrorMessage != _errorMessage) {
      bool wasValid = _errorMessage == null;
      setState(() {
        _errorMessage = newErrorMessage;
      });
      bool isValid = _errorMessage == null;
      if (isValid != wasValid) {
        widget.onValid(isValid);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _errorMessage = validateEmail(widget.controller.text);
    widget.controller.addListener(() {
      _checkEmail(widget.controller.text);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onValid(_errorMessage == null);
    });
  }

  @override
  void dispose() {
    super
        .dispose(); 
  }

  @override
  Widget build(BuildContext context) {
    final Color textColor = _errorMessage == null ? darkMaroon : lightMaroon;
    final bool isValid =
        _errorMessage == null && widget.controller.text.isNotEmpty;

    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start, 
      children: [
        Container(
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: darkMaroon, width: 1),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  key: Key('email_input_field'),
                  controller: widget.controller,
                  keyboardType: TextInputType.emailAddress,
                  style: jerseyStyle(20, textColor),
                  decoration: InputDecoration(
                    hintText: 'Email',
                    hintStyle: jerseyStyle(20, hintMaroon),
                    border: InputBorder
                        .none, 
                    prefixIcon: Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Image.asset(
                        'assets/images/mail_icon.png',
                        height: 30,
                        width: 30,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.alternate_email,
                                color: hintMaroon), 
                      ),
                    ),
                    suffixIcon: isValid
                        ? Padding(
                            padding: const EdgeInsets.only(right: 10.0),
                            child: Image.asset(
                              'assets/images/tick_icon.png',
                              height: 40,
                              width: 40,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(Icons.check_circle_outline,
                                      color: goodGreen), 
                            ),
                          )
                        : null, 
                  ),
                ),
              ),
            ],
          ),
        ),
        if (_errorMessage != null)
          Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Text(
              _errorMessage!,
              style:
                  jerseyStyle(14, errorRed), 
            ),
          ),
      ],
    );
  }
}

class PasswordInputWidget extends StatefulWidget {
  final TextEditingController controller;
  final Function(bool) onValid;

  const PasswordInputWidget(
      {Key? key, required this.controller, required this.onValid})
      : super(key: key);

  static String? validatePasswordStatic(String value) {
    if (value.isEmpty) {
      return 'Password cannot be empty';
    } else if (value.length < 6) {
      return 'Password must be at least 6 characters';
    } else {
      return null; 
    }
  }

  @override
  _PasswordInputWidgetState createState() => _PasswordInputWidgetState();
}

class _PasswordInputWidgetState extends State<PasswordInputWidget> {
  bool _obscureText = true;
  String? _errorMessage;

  void _toggleVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  void _validatePassword(String value) {
    final newErrorMessage = PasswordInputWidget.validatePasswordStatic(value);

    if (_errorMessage != newErrorMessage) {
      bool wasValid = _errorMessage == null;
      setState(() {
        _errorMessage = newErrorMessage;
      });
      bool isValid = _errorMessage == null;
      if (isValid != wasValid) {
        widget.onValid(isValid);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _errorMessage =
        PasswordInputWidget.validatePasswordStatic(widget.controller.text);
    widget.controller.addListener(() {
      _validatePassword(widget.controller.text);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onValid(_errorMessage == null);
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color textColor = _errorMessage == null ? darkMaroon : lightMaroon;

    return Column(
      children: [
        Container(
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: darkMaroon, width: 1),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  key: Key('password_input_field'),
                  controller: widget.controller,
                  obscureText: _obscureText,
                  decoration: InputDecoration(
                    hintText: 'Password',
                    hintStyle: jerseyStyle(
                        20, hintMaroon), 
                    border: InputBorder.none, 
                    prefixIcon: Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Image.asset(
                        'assets/images/lock_icon.png',
                        height: 30,
                        width: 30,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.lock,
                                color: hintMaroon), 
                      ),
                    ),
                    suffixIcon: GestureDetector(
                      onTap: _toggleVisibility,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 15.0),
                        child: Image.asset(
                          _obscureText
                              ? 'assets/images/no_see_icon.png'
                              : 'assets/images/see_icon.png',
                          height: 25,
                          width: 25,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) => Icon(
                              _obscureText
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: hintMaroon), 
                        ),
                      ),
                    ),
                  ),
                  style: jerseyStyle(
                      24, textColor), 
                ),
              ),
            ],
          ),
        ),
        if (_errorMessage != null)
          Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                _errorMessage!,
                style: jerseyStyle(14, errorRed),
              ),
            ),
          ),
      ],
    );
  }
}

class LoginPage1 extends StatefulWidget {
  const LoginPage1({Key? key}) : super(key: key);

  @override
  _LoginPage1State createState() => _LoginPage1State();
}

class _LoginPage1State extends State<LoginPage1> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isEmailValid = false;
  bool _isPasswordValid = false;
  bool _isLoading = false; 

  @override
  void initState() {
    super.initState();
    _isEmailValid =
        EmailInputWidget.validateEmailStatic(_emailController.text) == null;
    _isPasswordValid =
        PasswordInputWidget.validatePasswordStatic(_passwordController.text) ==
            null;
  }

  String _hashPassword(String password) {
    var bytes = utf8.encode(password); 
    var digest = sha256.convert(bytes); 
    return digest.toString(); 
  }

  Future<void> _login() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    String email = _emailController.text;
    String password = _passwordController.text;
    String hashedPassword = _hashPassword(password);

    final Uri loginUrl = Uri.parse(
        'https://e-fit-backend.onrender.com/user/login?email=$email&password=$hashedPassword');

    try {
      final response = await http.get(
        loginUrl,
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 15)); 

      if (!mounted) return;

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final sessionCookie = jsonResponse['sessionCookie'] as String?;

        if (sessionCookie != null && sessionCookie.isNotEmpty) {
          await storage.write(key: 'email', value: email);
          await storage.write(key: 'sessionCookie', value: sessionCookie);
          _showSuccessDialog('Logged in successfully');
        } else {
          final message = jsonResponse['message'] as String? ??
              'Email or password is incorrect';
          _showErrorDialog(message);
        }
      } else {
        String errorMessage =
            'Login failed (${response.statusCode}). Please try again.';
        try {
          final errorResponse = jsonDecode(response.body);
          if (errorResponse['message'] != null &&
              errorResponse['message'] is String) {
            errorMessage = errorResponse['message'];
          }
        } catch (e) {
          print("Could not parse error response body: ${response.body}");
        }
        _showErrorDialog(errorMessage);
      }
    } catch (e) {
      if (!mounted) return;
      _showErrorDialog('An error occurred: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showErrorDialog(String message) {
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false, 
      builder: (context) => AlertDialog(
        title: Text('Error', style: jerseyStyle(24, errorRed)),
        content: Text(message, style: jerseyStyle(20, darkMaroon)),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); 
            },
            child: Text('OK', style: jerseyStyle(20, darkMaroon)),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog(String message) {
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text('Success', style: jerseyStyle(24, darkMaroon)),
        content: Text(message, style: jerseyStyle(20, darkMaroon)),
        actions: [
          TextButton(
            key: Key('ok_button'),
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => HomeScreen()),
              );
            },
            child: Text('OK', style: jerseyStyle(20, darkMaroon)),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isButtonEnabled = _isEmailValid && _isPasswordValid && !_isLoading;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.transparent,
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        child: Container(
          constraints: BoxConstraints(
            minHeight: screenHeight,
          ),
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/background_login_page_1.png'),
              fit: BoxFit.cover,
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconButton(
                    icon: Image.asset(
                      'assets/images/app_navigation_left_icon.png',
                      width: 50,
                      height: 50,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => const Icon(
                          Icons.arrow_back,
                          color: brightWhite,
                          size: 30),
                    ),
                    onPressed: _isLoading
                        ? null
                        : () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const LoginSignupPage1(),
                              ),
                            );
                          },
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Welcome \nBack',
                    style: jerseyStyle(64, brightWhite).copyWith(height: 0.8),
                  ),
                  const SizedBox(height: 310),
                  EmailInputWidget(
                    controller: _emailController,
                    onValid: (isValid) {
                      if (_isEmailValid != isValid) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (mounted) {
                            setState(() {
                              _isEmailValid = isValid;
                            });
                          }
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 20),
                  PasswordInputWidget(
                    controller: _passwordController,
                    onValid: (isValid) {
                      if (_isPasswordValid != isValid) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (mounted) {
                            setState(() {
                              _isPasswordValid = isValid;
                            });
                          }
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: _isLoading
                          ? null
                          : () {
                              slideTo(context, ForgotPasswordPage1());
                            },
                      style: TextButton.styleFrom(
                          padding: EdgeInsets.zero),
                      child: Text(
                        'Forgot password?',
                        style: jerseyStyle(24, lightMaroon),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: ElevatedButton(
                      key: Key('log_in_button'),
                      onPressed: isButtonEnabled ? _login : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            darkMaroon,
                        disabledBackgroundColor: darkMaroon
                            .withOpacity(0.5),
                        fixedSize: const Size(350, 59), 
                        elevation: 0, 
                        side: BorderSide(
                          color: isButtonEnabled
                              ? brightWhite
                              : brightWhite.withOpacity(0.5),
                          width: 2,
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 3,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(brightWhite),
                              ),
                            )
                          : Text(
                              'Log in',
                              style: jerseyStyle(
                                  24,
                                  isButtonEnabled
                                      ? brightWhite
                                      : brightWhite.withOpacity(0.7)),
                            ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 40.0),
                          child: Divider(
                              color: hintMaroon, thickness: 1, endIndent: 10),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text('or', style: jerseyStyle(24, hintMaroon)),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(right: 40.0),
                          child: Divider(
                              color: hintMaroon, thickness: 1, indent: 10),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: buildStyledButton(
                      context: context,
                      buttonText: 'Sign up',
                      buttonColor: brightWhite,
                      textColor:
                          lightMaroon,
                      borderColor:
                          lightMaroon,
                      onPressed:
                          _isLoading
                              ? null
                              : () {
                                  slideTo(context, const SignupPage1());
                                },
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
