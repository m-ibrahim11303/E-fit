import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:login_signup_1/bootup/signup_page_2.dart';
import 'package:login_signup_1/bootup/login_page_1.dart';
import 'package:login_signup_1/bootup/login_signup_page_1.dart';
import 'package:login_signup_1/style.dart';
import 'package:login_signup_1/home_page.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// --- PasswordInputWidget ---
class PasswordInputWidget extends StatefulWidget {
  final TextEditingController passwordController;
  final Function(bool isValid) onValidChanged;

  const PasswordInputWidget({
    Key? key,
    required this.passwordController,
    required this.onValidChanged,
  }) : super(key: key);

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
  bool _isValid = false;

  @override
  void initState() {
    super.initState();
    widget.passwordController.addListener(_validatePassword);
    _validatePassword();
  }

  void _toggleVisibility() {
    if (mounted) {
      setState(() {
        _obscureText = !_obscureText;
      });
    }
  }

  void _validatePassword() {
    final value = widget.passwordController.text;
    final newHasMinLength = value.length >= 8;
    final newHasNumbers = RegExp(r'[0-9]').hasMatch(value);
    final newHasLowerCase = RegExp(r'[a-z]').hasMatch(value);
    final newHasUpperCase = RegExp(r'[A-Z]').hasMatch(value);
    final newWithinMaxLength = value.length <= 30;

    final newIsValid = newHasMinLength &&
        newHasNumbers &&
        newHasLowerCase &&
        newHasUpperCase &&
        newWithinMaxLength;

    bool stateChanged = newHasMinLength != _hasMinLength ||
        newHasNumbers != _hasNumbers ||
        newHasLowerCase != _hasLowerCase ||
        newHasUpperCase != _hasUpperCase ||
        newWithinMaxLength != _withinMaxLength;

    bool validityChanged = newIsValid != _isValid;

    if (mounted && stateChanged) {
      setState(() {
        _hasMinLength = newHasMinLength;
        _hasNumbers = newHasNumbers;
        _hasLowerCase = newHasLowerCase;
        _hasUpperCase = newHasUpperCase;
        _withinMaxLength = newWithinMaxLength;
        _isValid = newIsValid;
      });
      if (validityChanged) {
        widget.onValidChanged(_isValid);
      }
    } else if (!mounted && validityChanged) {
      widget.onValidChanged(newIsValid);
    } else if (mounted && validityChanged) {
      _isValid = newIsValid;
      widget.onValidChanged(_isValid);
    }
  }

  Widget _buildValidationItem(String text, bool isValid) {
    return Row(
      mainAxisSize: MainAxisSize.min,
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
          style: jerseyStyle(16, const Color(0x9938000A)),
        ),
      ],
    );
  }

  @override
  void dispose() {
    widget.passwordController.removeListener(_validatePassword);
    super.dispose();
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
                  controller: widget.passwordController,
                  obscureText: _obscureText,
                  keyboardType: TextInputType.visiblePassword,
                  style: jerseyStyle(24, const Color(0xFF9B5D6C)),
                  decoration: InputDecoration(
                    hintText: 'New password',
                    hintStyle: jerseyStyle(20, const Color(0x9938000A)),
                    border: InputBorder.none,
                    prefixIconConstraints: const BoxConstraints(
                      minWidth: 24,
                      minHeight: 24,
                    ),
                    prefixIcon: Padding(
                      padding: const EdgeInsets.only(right: 8.0, left: 5.0),
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
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.only(left: 5.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildValidationItem('At least 8 characters', _hasMinLength),
              _buildValidationItem('Contains numbers (0-9)', _hasNumbers),
              _buildValidationItem('Contains lowercase (a-z)', _hasLowerCase),
              _buildValidationItem('Contains uppercase (A-Z)', _hasUpperCase),
              _buildValidationItem('Maximum 30 characters', _withinMaxLength),
            ],
          ),
        ),
      ],
    );
  }
}

// --- ConfirmPasswordInputWidget ---
class ConfirmPasswordInputWidget extends StatefulWidget {
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final Function(bool isValid) onValidChanged;

  const ConfirmPasswordInputWidget({
    Key? key,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.onValidChanged,
  }) : super(key: key);

  @override
  _ConfirmPasswordInputWidgetState createState() =>
      _ConfirmPasswordInputWidgetState();
}

class _ConfirmPasswordInputWidgetState
    extends State<ConfirmPasswordInputWidget> {
  bool _obscureText = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    widget.passwordController.addListener(_validateConfirmPassword);
    widget.confirmPasswordController.addListener(_validateConfirmPassword);
    _validateConfirmPassword();
  }

  void _toggleVisibility() {
    if (mounted) {
      setState(() {
        _obscureText = !_obscureText;
      });
    }
  }

  void _validateConfirmPassword() {
    final originalPassword = widget.passwordController.text;
    final confirmPassword = widget.confirmPasswordController.text;
    String? newErrorMessage;

    if (confirmPassword.isEmpty && originalPassword.isNotEmpty) {
      newErrorMessage = null;
    } else if (confirmPassword.isNotEmpty &&
        confirmPassword != originalPassword) {
      newErrorMessage = 'Passwords do not match';
    } else {
      newErrorMessage = null;
    }

    if (mounted && newErrorMessage != _errorMessage) {
      setState(() {
        _errorMessage = newErrorMessage;
      });
      bool isValid = confirmPassword.isNotEmpty && newErrorMessage == null;
      widget.onValidChanged(isValid);
    } else if (!mounted && newErrorMessage != _errorMessage) {
      bool isValid = confirmPassword.isNotEmpty && newErrorMessage == null;
      widget.onValidChanged(isValid);
    }
  }

  @override
  void dispose() {
    widget.passwordController.removeListener(_validateConfirmPassword);
    widget.confirmPasswordController.removeListener(_validateConfirmPassword);
    super.dispose();
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
                  controller: widget.confirmPasswordController,
                  obscureText: _obscureText,
                  keyboardType: TextInputType.visiblePassword,
                  style: jerseyStyle(24, const Color(0xFF9B5D6C)),
                  decoration: InputDecoration(
                    hintText: 'Confirm Password',
                    hintStyle: jerseyStyle(20, const Color(0x9938000A)),
                    border: InputBorder.none,
                    prefixIconConstraints: const BoxConstraints(
                      minWidth: 24,
                      minHeight: 24,
                    ),
                    prefixIcon: Padding(
                      padding: const EdgeInsets.only(right: 8.0, left: 5.0),
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
                            widget.confirmPasswordController.text.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(right: 5.0),
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
                ),
              ),
            ],
          ),
        ),
        Container(
          height: 20,
          padding: const EdgeInsets.only(top: 4.0),
          child: _errorMessage != null
              ? Text(
                  _errorMessage!,
                  style: const TextStyle(
                    color: Colors.red,
                    fontSize: 14,
                    height: 1.0,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                )
              : null,
        ),
      ],
    );
  }
}

// --- ForgotPasswordPage3 ---
class ForgotPasswordPage3 extends StatefulWidget {
  const ForgotPasswordPage3({Key? key}) : super(key: key);

  @override
  _ForgotPasswordPage3State createState() => _ForgotPasswordPage3State();
}

class _ForgotPasswordPage3State extends State<ForgotPasswordPage3> {
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final storage = const FlutterSecureStorage();

  bool _isNewPasswordValid = false;
  bool _isConfirmPasswordValid = false;

  bool get _isFormValid => _isNewPasswordValid && _isConfirmPasswordValid;

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _updatePasswordValidity(bool isValid) {
    if (mounted && _isNewPasswordValid != isValid) {
      setState(() {
        _isNewPasswordValid = isValid;
      });
    }
  }

  void _updateConfirmPasswordValidity(bool isValid) {
    if (mounted && _isConfirmPasswordValid != isValid) {
      setState(() {
        _isConfirmPasswordValid = isValid;
      });
    }
  }

  Future<void> _updatePassword() async {
    if (!_isFormValid) return;

    final email = await storage.read(key: 'email');
    if (email == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: Email not found')),
      );
      return;
    }

    final userData = {
      'email': email,
      'newPassword': _newPasswordController.text,
    };

    try {
      final response = await http.post(
        Uri.parse('http://10.130.93.109:3000/forgot-password/update-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(userData),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password updated successfully')),
        );
        if (mounted) {
          slideTo(context, HomeScreen());
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text('Failed to update password: ${response.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
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
                        if (Navigator.canPop(context)) {
                          Navigator.pop(context);
                        } else {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const LoginSignupPage1(),
                            ),
                          );
                        }
                      },
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Update\nPassword',
                      style: jerseyStyle(64).copyWith(height: 0.8),
                    ),
                    const SizedBox(height: 100),
                    PasswordInputWidget(
                      passwordController: _newPasswordController,
                      onValidChanged: _updatePasswordValidity,
                    ),
                    ConfirmPasswordInputWidget(
                      passwordController: _newPasswordController,
                      confirmPasswordController: _confirmPasswordController,
                      onValidChanged: _updateConfirmPasswordValidity,
                    ),
                    const SizedBox(height: 24),
                    Center(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF562634),
                          disabledBackgroundColor:
                              const Color(0xFF562634).withOpacity(0.5),
                          foregroundColor: Colors.white,
                          disabledForegroundColor:
                              Colors.white.withOpacity(0.7),
                          fixedSize: const Size(350, 59),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: BorderSide(
                              color: _isFormValid
                                  ? Colors.white
                                  : Colors.white.withOpacity(0.5),
                              width: 2,
                            ),
                          ),
                        ),
                        onPressed: _isFormValid ? _updatePassword : null,
                        child: Text(
                          'Update password',
                          style: jerseyStyle(24, Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
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

// --- Main Function (for testing standalone) ---
void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: const ForgotPasswordPage3(),
  ));
}
