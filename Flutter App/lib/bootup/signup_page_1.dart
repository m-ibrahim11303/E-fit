import 'package:flutter/material.dart';
import 'package:login_signup_1/bootup/signup_page_2.dart';
import 'package:login_signup_1/bootup/login_page_1.dart';
import 'login_signup_page_1.dart';

// Define jerseyStyle globally
TextStyle jerseyStyle(double fontSize, [Color color = Colors.white]) {
  return TextStyle(
    fontFamily: 'Jersey 25',
    fontSize: fontSize,
    color: color,
  );
}

// FullNameInputWidget
class FullNameInputWidget extends StatefulWidget {
  final TextEditingController controller; // Added controller
  const FullNameInputWidget({Key? key, required this.controller})
      : super(key: key);

  @override
  _FullNameInputWidgetState createState() => _FullNameInputWidgetState();
}

class _FullNameInputWidgetState extends State<FullNameInputWidget> {
  String? _errorMessage;

  String? validateName(String value) {
    if (value.isEmpty) {
      return 'Name cannot be empty';
    }
    if (value.length < 2) {
      return 'Name must be at least 2 characters';
    }
    return null;
  }

  void _checkName(String value) {
    setState(() {
      _errorMessage = validateName(value);
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black, width: 1),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: widget.controller, // Use passed controller
                  keyboardType: TextInputType.text,
                  style: _errorMessage == null
                      ? jerseyStyle(24, Color(0xFF9B5D6C))
                      : jerseyStyle(20, Color(0x9938000A)),
                  decoration: InputDecoration(
                    hintText: 'Full Name',
                    hintStyle: jerseyStyle(20, Color(0x9938000A)),
                    border: InputBorder.none,
                    prefixIconConstraints: const BoxConstraints(
                      minWidth: 24,
                      minHeight: 24,
                    ),
                    prefixIcon: Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Image.asset(
                        'assets/images/profile_icon.png',
                        height: 30,
                        width: 30,
                        fit: BoxFit.contain,
                      ),
                    ),
                    suffixIconConstraints: const BoxConstraints(
                      minWidth: 24,
                      minHeight: 24,
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
                  onChanged: _checkName,
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
                height: 1.0,
              ),
            ),
          ),
      ],
    );
  }
}

// EmailInputWidget
class EmailInputWidget extends StatefulWidget {
  final TextEditingController controller; // Added controller
  const EmailInputWidget({Key? key, required this.controller})
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
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black, width: 1),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: widget.controller, // Use passed controller
                  keyboardType: TextInputType.emailAddress,
                  style: _errorMessage == null
                      ? jerseyStyle(24, Color(0xFF9B5D6C))
                      : jerseyStyle(20, Color(0x9938000A)),
                  decoration: InputDecoration(
                    hintText: 'Email',
                    hintStyle: jerseyStyle(20, Color(0x9938000A)),
                    border: InputBorder.none,
                    prefixIconConstraints: const BoxConstraints(
                      minWidth: 24,
                      minHeight: 24,
                    ),
                    prefixIcon: Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Image.asset(
                        'assets/images/mail_icon.png',
                        height: 30,
                        width: 30,
                        fit: BoxFit.contain,
                      ),
                    ),
                    suffixIconConstraints: const BoxConstraints(
                      minWidth: 24,
                      minHeight: 24,
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
                height: 1.0,
              ),
            ),
          ),
      ],
    );
  }
}

// PasswordInputWidget (unchanged except for existing controller)
class PasswordInputWidget extends StatefulWidget {
  final TextEditingController passwordController;
  const PasswordInputWidget({Key? key, required this.passwordController})
      : super(key: key);

  @override
  _PasswordInputWidgetState createState() => _PasswordInputWidgetState();
}

class _PasswordInputWidgetState extends State<PasswordInputWidget> {
  bool _obscureText = true;
  bool _hasMinLength = false;
  bool _hasNumbers = false;
  bool _hasLowerCase = false;
  bool _hasUpperCase = false;
  bool _withinMaxLength = true;

  void _toggleVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  void _validatePassword(String value) {
    setState(() {
      _hasMinLength = value.length >= 8;
      _hasNumbers = RegExp(r'[0-9]').hasMatch(value);
      _hasLowerCase = RegExp(r'[a-z]').hasMatch(value);
      _hasUpperCase = RegExp(r'[A-Z]').hasMatch(value);
      _withinMaxLength = value.length <= 30;
    });
  }

  Widget _buildValidationItem(String text, bool isValid) {
    return Row(
      children: [
        Image.asset(
          isValid
              ? 'assets/images/green_check_icon.png'
              : 'assets/images/red_cross_icon.png',
          height: 16,
          width: 16,
          fit: BoxFit.contain,
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: jerseyStyle(16, Color(0x9938000A)),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black, width: 1),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: widget.passwordController,
                  obscureText: _obscureText,
                  decoration: InputDecoration(
                    hintText: 'Password',
                    hintStyle: jerseyStyle(20, Color(0x9938000A)),
                    border: InputBorder.none,
                    prefixIconConstraints: const BoxConstraints(
                      minWidth: 24,
                      minHeight: 24,
                    ),
                    prefixIcon: Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Image.asset(
                        'assets/images/lock_icon.png',
                        height: 30,
                        width: 30,
                        fit: BoxFit.contain,
                      ),
                    ),
                    suffixIconConstraints: const BoxConstraints(
                      minWidth: 24,
                      minHeight: 24,
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
        const SizedBox(height: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildValidationItem('At least 8 characters', _hasMinLength),
            _buildValidationItem('Contains numbers', _hasNumbers),
            _buildValidationItem('Contains lowercase', _hasLowerCase),
            _buildValidationItem('Contains uppercase', _hasUpperCase),
            _buildValidationItem('Maximum 30 characters', _withinMaxLength),
          ],
        ),
      ],
    );
  }
}

// ConfirmPasswordInputWidget (unchanged)
class ConfirmPasswordInputWidget extends StatefulWidget {
  final TextEditingController passwordController;
  const ConfirmPasswordInputWidget({Key? key, required this.passwordController})
      : super(key: key);

  @override
  _ConfirmPasswordInputWidgetState createState() =>
      _ConfirmPasswordInputWidgetState();
}

class _ConfirmPasswordInputWidgetState
    extends State<ConfirmPasswordInputWidget> {
  bool _obscureText = true;
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  String? _errorMessage;

  void _toggleVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  void _validateConfirmPassword(String value) {
    setState(() {
      if (value != widget.passwordController.text) {
        _errorMessage = 'Passwords do not match';
      } else if (value.isEmpty) {
        _errorMessage = 'Please confirm your password';
      } else {
        _errorMessage = null;
      }
    });
  }

  @override
  void dispose() {
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black, width: 1),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _confirmPasswordController,
                  obscureText: _obscureText,
                  decoration: InputDecoration(
                    hintText: 'Confirm Password',
                    hintStyle: jerseyStyle(20, Color(0x9938000A)),
                    border: InputBorder.none,
                    prefixIconConstraints: const BoxConstraints(
                      minWidth: 24,
                      minHeight: 24,
                    ),
                    prefixIcon: Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Image.asset(
                        'assets/images/lock_icon.png',
                        height: 30,
                        width: 30,
                        fit: BoxFit.contain,
                      ),
                    ),
                    suffixIconConstraints: const BoxConstraints(
                      minWidth: 24,
                      minHeight: 24,
                    ),
                    suffixIcon: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_errorMessage == null &&
                            _confirmPasswordController.text.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(right: 10.0),
                            child: Image.asset(
                              'assets/images/tick_icon.png',
                              height: 40,
                              width: 40,
                              fit: BoxFit.contain,
                            ),
                          ),
                        GestureDetector(
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
                      ],
                    ),
                  ),
                  style: jerseyStyle(24, Color(0xFF9B5D6C)),
                  onChanged: _validateConfirmPassword,
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
                height: 1.0,
              ),
            ),
          ),
      ],
    );
  }
}

// SignupPage1 (modified to StatefulWidget)
class SignupPage1 extends StatefulWidget {
  const SignupPage1({Key? key}) : super(key: key);

  @override
  _SignupPage1State createState() => _SignupPage1State();
}

class _SignupPage1State extends State<SignupPage1> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _navigateToSignupPage2() {
    String email = _emailController.text;
    String password = _passwordController.text;
    String name = _nameController.text;

    Navigator.push(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 500),
        pageBuilder: (context, animation, secondaryAnimation) =>
            SignUpPage2(email: email, password: password, name: name),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                'assets/images/background_signup_page_1.png',
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
                      'Create \nAccount',
                      style: jerseyStyle(64).copyWith(height: 0.8),
                    ),
                    const SizedBox(height: 200),
                    FullNameInputWidget(controller: _nameController),
                    const SizedBox(height: 20),
                    EmailInputWidget(controller: _emailController),
                    const SizedBox(height: 20),
                    PasswordInputWidget(
                        passwordController: _passwordController),
                    const SizedBox(height: 20),
                    ConfirmPasswordInputWidget(
                        passwordController: _passwordController),
                    const SizedBox(height: 16),
                    Center(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF562634),
                          fixedSize: const Size(350, 59),
                          elevation: 0,
                          side: const BorderSide(
                            color: Colors.white,
                            width: 2,
                          ),
                        ),
                        onPressed: _navigateToSignupPage2,
                        child: Text(
                          'Sign up',
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
                                      const LoginPage1(),
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
                          'Log in',
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
  runApp(MaterialApp(
    home: SignupPage1(),
  ));
}
