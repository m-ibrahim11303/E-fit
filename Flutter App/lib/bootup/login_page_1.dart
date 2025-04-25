import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:login_signup_1/bootup/signup_page_2.dart';
import 'package:login_signup_1/bootup/login_page_1.dart';
import 'package:login_signup_1/bootup/forget_password/forgot_password_email.dart';
import 'login_signup_page_1.dart';
import 'package:login_signup_1/bootup/signup_page_1.dart';
import 'bootup_page_4.dart';
import 'package:login_signup_1/home_page.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// Global secure storage instance
final FlutterSecureStorage storage = FlutterSecureStorage();

TextStyle jerseyStyle(double fontSize, [Color color = Colors.white]) {
  return TextStyle(
    fontFamily: 'Jersey 25',
    fontSize: fontSize,
    color: color,
  );
}

class EmailInputWidget extends StatefulWidget {
  final TextEditingController controller;
  final Function(bool) onValid;

  const EmailInputWidget(
      {Key? key, required this.controller, required this.onValid})
      : super(key: key);

  @override
  _EmailInputWidgetState createState() => _EmailInputWidgetState();
}

class _EmailInputWidgetState extends State<EmailInputWidget> {
  String? _errorMessage;

  String? validateEmail(String value) {
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

  void _checkEmail(String value) {
    setState(() {
      _errorMessage = validateEmail(value);
      widget.onValid(_errorMessage == null);
    });
  }

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(() {
      _checkEmail(widget.controller.text);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Colors.black, width: 1),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: widget.controller,
                  keyboardType: TextInputType.emailAddress,
                  style: _errorMessage == null
                      ? jerseyStyle(24, Color(0xFF9B5D6C))
                      : jerseyStyle(20, Color(0x9938000A)),
                  decoration: InputDecoration(
                    hintText: 'Email',
                    hintStyle: jerseyStyle(20, Color(0x9938000A)),
                    border: InputBorder.none,
                    prefixIcon: Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Image.asset(
                        'assets/images/mail_icon.png',
                        height: 30,
                        width: 30,
                        fit: BoxFit.contain,
                      ),
                    ),
                    suffixIcon: _errorMessage == null &&
                            widget.controller.text.isNotEmpty
                        ? Padding(
                            padding: const EdgeInsets.only(right: 10.0),
                            child: Image.asset(
                              'assets/images/tick_icon.png',
                              height: 40,
                              width: 40,
                              fit: BoxFit.contain,
                            ),
                          )
                        : null,
                  ),
                  onChanged: _checkEmail,
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
              style: TextStyle(
                color: Colors.red,
                fontSize: 14,
              ),
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
    setState(() {
      if (value.isEmpty) {
        _errorMessage = 'Password cannot be empty';
      } else if (value.length < 6) {
        _errorMessage = 'Password must be at least 6 characters';
      } else {
        _errorMessage = null;
      }
      widget.onValid(_errorMessage == null);
    });
  }

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(() {
      _validatePassword(widget.controller.text);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Colors.black, width: 1),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: widget.controller,
                  obscureText: _obscureText,
                  decoration: InputDecoration(
                    hintText: 'Password',
                    hintStyle: jerseyStyle(20, Color(0x9938000A)),
                    border: InputBorder.none,
                    prefixIcon: Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Image.asset(
                        'assets/images/lock_icon.png',
                        height: 30,
                        width: 30,
                        fit: BoxFit.contain,
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
                        ),
                      ),
                    ),
                  ),
                  style: jerseyStyle(24, Color(0xFF9B5D6C)),
                  onChanged: _validatePassword,
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
              style: TextStyle(
                color: Colors.red,
                fontSize: 14,
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

  String _hashPassword(String password) {
    var bytes = utf8.encode(password);
    var digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<void> _login() async {
    String email = _emailController.text;
    String hashedPassword = _hashPassword(_passwordController.text);

    try {
      final response = await http.get(
        Uri.parse(
            'https://e-fit-backend.onrender.com/user/login?email=$email&password=$hashedPassword'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final sessionCookie = jsonResponse['sessionCookie'];

        if (sessionCookie == null) {
          _showErrorDialog('Email or password is incorrect');
        } else {
          // Store email in secure storage
          await storage.write(key: 'email', value: email);
          _showSuccessDialog('Logged in successfully');
        }
      } else {
        _showErrorDialog('Login failed. Please try again.');
      }
    } catch (e) {
      _showErrorDialog('An error occurred: $e');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Error', style: jerseyStyle(24)),
        content: Text(message, style: jerseyStyle(20)),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('OK', style: jerseyStyle(20, Color(0xFF9B5D6C))),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Success', style: jerseyStyle(24)),
        content: Text(message, style: jerseyStyle(20)),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close the dialog
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => HomeScreen()),
              ); // Navigate to HomeScreen
            },
            child: Text('OK', style: jerseyStyle(20, Color(0xFF9B5D6C))),
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
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                'assets/images/background_login_page_1.png',
                fit: BoxFit.cover,
              ),
            ),
            SingleChildScrollView(
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
                      ),
                      onPressed: () {
                        Navigator.push(
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
                      style: jerseyStyle(64).copyWith(height: 0.8),
                    ),
                    const SizedBox(height: 310),
                    EmailInputWidget(
                      controller: _emailController,
                      onValid: (isValid) {
                        setState(() {
                          _isEmailValid = isValid;
                        });
                      },
                    ),
                    const SizedBox(height: 20),
                    PasswordInputWidget(
                      controller: _passwordController,
                      onValid: (isValid) {
                        setState(() {
                          _isPasswordValid = isValid;
                        });
                      },
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ForgotPasswordEmail(),
                            ),
                          );
                        },
                        child: Text(
                          'Forgot password?',
                          style: jerseyStyle(24, Color(0xFF9B5D6C)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: ElevatedButton(
                        onPressed:
                            _isEmailValid && _isPasswordValid ? _login : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF562634),
                          fixedSize: const Size(350, 59),
                          elevation: 0,
                          side: const BorderSide(
                            color: Colors.white,
                            width: 2,
                          ),
                        ),
                        child: Text(
                          'Log in',
                          style: jerseyStyle(24, Colors.white),
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
                              color: Color(0x9938000A),
                              thickness: 1,
                              endIndent: 10,
                            ),
                          ),
                        ),
                        Text(
                          'or',
                          style: jerseyStyle(24, Color(0x9938000A)),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(right: 40.0),
                            child: Divider(
                              color: Color(0x9938000A),
                              thickness: 1,
                              indent: 10,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          fixedSize: const Size(350, 59),
                          elevation: 0,
                          side: const BorderSide(
                            color: Color(0xFF9B5D6C),
                            width: 2,
                          ),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            PageRouteBuilder(
                              transitionDuration:
                                  const Duration(milliseconds: 500),
                              pageBuilder:
                                  (context, animation, secondaryAnimation) =>
                                      const SignupPage1(),
                              transitionsBuilder: (context, animation,
                                  secondaryAnimation, child) {
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
                          'Sign up',
                          style: jerseyStyle(24, Color(0xFF9B5D6C)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(home: LoginPage1()));
}
