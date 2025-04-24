import 'package:flutter/material.dart';
// Ensure these imports point to the correct files in your project structure
import 'package:login_signup_1/bootup/signup_page_3.dart';
import 'package:login_signup_1/bootup/login_page_1.dart';
import 'package:login_signup_1/bootup/login_signup_page_1.dart';

// Define jerseyStyle globally
TextStyle jerseyStyle(double fontSize, [Color color = Colors.white]) {
  return TextStyle(
    fontFamily: 'Jersey 25',
    fontSize: fontSize,
    color: color,
  );
}

// --- FullNameInputWidget ---
class FullNameInputWidget extends StatefulWidget {
  final TextEditingController controller;
  final Function(bool isValid) onValidChanged; // Callback for validity

  const FullNameInputWidget({
    Key? key,
    required this.controller,
    required this.onValidChanged,
  }) : super(key: key);

  @override
  _FullNameInputWidgetState createState() => _FullNameInputWidgetState();
}

class _FullNameInputWidgetState extends State<FullNameInputWidget> {
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // Add listener to report changes
    widget.controller.addListener(_validate);
    // Report initial state (usually invalid as it's empty)
    _validate();
  }

  String? _validateName(String value) {
    if (value.isEmpty) {
      return 'Name cannot be empty';
    }
    if (value.length < 2) {
      return 'Name must be at least 2 characters';
    }
    return null; // Valid
  }

  void _validate() {
    final value = widget.controller.text;
    final newErrorMessage = _validateName(value);
    if (mounted && newErrorMessage != _errorMessage) {
      setState(() {
        _errorMessage = newErrorMessage;
      });
      widget.onValidChanged(_errorMessage == null); // Report validity
    } else if (!mounted && newErrorMessage != _errorMessage) {
      // If not mounted but state changes (less likely with listener but possible)
      // just report the validity change
      widget.onValidChanged(newErrorMessage == null);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_validate); // Clean up listener
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Use ValueListenableBuilder or similar if direct controller listening causes issues
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          // Changed border to bottom only for consistency if desired, or keep Border.all
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Colors.black, width: 1),
            ),
          ),
          // decoration: BoxDecoration(
          //   border: Border.all(color: Colors.black, width: 1),
          // ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: widget.controller, // Use passed controller
                  keyboardType: TextInputType.name, // More specific type
                  textCapitalization:
                      TextCapitalization.words, // Capitalize names
                  style: jerseyStyle(24, Color(0xFF9B5D6C)), // Consistent style
                  decoration: InputDecoration(
                    hintText: 'Full Name',
                    hintStyle: jerseyStyle(20, Color(0x9938000A)),
                    border: InputBorder.none,
                    prefixIconConstraints: const BoxConstraints(
                      minWidth: 24, // Adjusted constraints
                      minHeight: 24,
                    ),
                    prefixIcon: Padding(
                      padding: const EdgeInsets.only(
                          right: 8.0, left: 5.0), // Adjust padding
                      child: Image.asset(
                        'assets/images/profile_icon.png',
                        height: 30,
                        width: 30,
                        fit: BoxFit.contain,
                      ),
                    ),
                    suffixIconConstraints: const BoxConstraints(
                      minWidth: 24, // Adjusted constraints
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
                  // Use listener instead of onChanged for debouncing if needed, but listener is fine here
                  // onChanged: (value) => _validate(), // Can use onChanged directly too
                ),
              ),
            ],
          ),
        ),
        // Error Message Area
        Container(
          height:
              20, // Reserve space for error message to prevent layout shifts
          padding: const EdgeInsets.only(top: 4.0),
          child: _errorMessage != null
              ? Text(
                  _errorMessage!,
                  style: const TextStyle(
                    color: Colors.red,
                    fontSize: 14,
                    height: 1.0, // Prevent extra vertical space
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                )
              : null, // Render nothing if no error
        ),
      ],
    );
  }
}

// --- EmailInputWidget ---
class EmailInputWidget extends StatefulWidget {
  final TextEditingController controller;
  final Function(bool isValid) onValidChanged; // Callback for validity

  const EmailInputWidget({
    Key? key,
    required this.controller,
    required this.onValidChanged,
  }) : super(key: key);

  @override
  _EmailInputWidgetState createState() => _EmailInputWidgetState();
}

class _EmailInputWidgetState extends State<EmailInputWidget> {
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_validate);
    _validate(); // Report initial state
  }

  String? _validateEmail(String value) {
    if (value.isEmpty) {
      return 'Email cannot be empty';
    }
    final emailRegex =
        RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    return null; // Valid
  }

  void _validate() {
    final value = widget.controller.text;
    final newErrorMessage = _validateEmail(value);
    if (mounted && newErrorMessage != _errorMessage) {
      setState(() {
        _errorMessage = newErrorMessage;
      });
      widget.onValidChanged(_errorMessage == null); // Report validity
    } else if (!mounted && newErrorMessage != _errorMessage) {
      widget.onValidChanged(newErrorMessage == null);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_validate); // Clean up listener
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
          // decoration: BoxDecoration(
          //   border: Border.all(color: Colors.black, width: 1),
          // ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: widget.controller, // Use passed controller
                  keyboardType: TextInputType.emailAddress,
                  style: jerseyStyle(24, Color(0xFF9B5D6C)), // Consistent style
                  decoration: InputDecoration(
                    hintText: 'Email',
                    hintStyle: jerseyStyle(20, Color(0x9938000A)),
                    border: InputBorder.none,
                    prefixIconConstraints: const BoxConstraints(
                      minWidth: 24, // Adjusted constraints
                      minHeight: 24,
                    ),
                    prefixIcon: Padding(
                      padding: const EdgeInsets.only(
                          right: 8.0, left: 5.0), // Adjust padding
                      child: Image.asset(
                        'assets/images/mail_icon.png',
                        height: 30,
                        width: 30,
                        fit: BoxFit.contain,
                      ),
                    ),
                    suffixIconConstraints: const BoxConstraints(
                      minWidth: 24, // Adjusted constraints
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
                  // onChanged: (value) => _validate(), // Can use onChanged directly too
                ),
              ),
            ],
          ),
        ),
        // Error Message Area
        Container(
          height: 20, // Reserve space for error message
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

// --- PasswordInputWidget ---
class PasswordInputWidget extends StatefulWidget {
  final TextEditingController passwordController;
  final Function(bool isValid) onValidChanged; // Callback for validity

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
  bool _withinMaxLength = true; // Assume true initially until text exceeds
  bool _isValid = false; // Track overall validity

  @override
  void initState() {
    super.initState();
    widget.passwordController.addListener(_validatePassword);
    _validatePassword(); // Report initial state
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
        widget.onValidChanged(_isValid); // Report validity change
      }
    } else if (!mounted && validityChanged) {
      widget
          .onValidChanged(newIsValid); // Report validity change if not mounted
    } else if (mounted && validityChanged) {
      // If only validity changed but not the individual flags (e.g. going from 7 to 8 chars)
      _isValid = newIsValid;
      widget.onValidChanged(_isValid);
    }
  }

  Widget _buildValidationItem(String text, bool isValid) {
    return Row(
      mainAxisSize: MainAxisSize.min, // Take only needed space
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
          // decoration: BoxDecoration(
          //   border: Border.all(color: Colors.black, width: 1),
          // ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: widget.passwordController,
                  obscureText: _obscureText,
                  keyboardType:
                      TextInputType.visiblePassword, // Appropriate type
                  style: jerseyStyle(24, Color(0xFF9B5D6C)), // Consistent style
                  decoration: InputDecoration(
                    hintText: 'Password',
                    hintStyle: jerseyStyle(20, Color(0x9938000A)),
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
                  // onChanged: (value) => _validatePassword(), // Listener handles this
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        // Use Wrap for better responsiveness if needed, Column is fine for fixed width
        Padding(
          padding:
              const EdgeInsets.only(left: 5.0), // Indent validation slightly
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildValidationItem('At least 8 characters', _hasMinLength),
              _buildValidationItem(
                  'Contains numbers (0-9)', _hasNumbers), // More specific text
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
  final TextEditingController passwordController; // Original password
  final TextEditingController
      confirmPasswordController; // Controller for this field
  final Function(bool isValid) onValidChanged; // Callback for validity

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
    // Listen to both controllers
    widget.passwordController.addListener(_validateConfirmPassword);
    widget.confirmPasswordController.addListener(_validateConfirmPassword);
    _validateConfirmPassword(); // Report initial state
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
      // Only show error if original password has been touched
      // Or always show if empty:
      // newErrorMessage = 'Please confirm your password';
      newErrorMessage =
          null; // Or 'Confirm password cannot be empty' if needed immediately
    } else if (confirmPassword.isNotEmpty &&
        confirmPassword != originalPassword) {
      newErrorMessage = 'Passwords do not match';
    } else {
      newErrorMessage = null; // Valid or original is empty
    }

    // Only update state and report if error message *changes*
    if (mounted && newErrorMessage != _errorMessage) {
      setState(() {
        _errorMessage = newErrorMessage;
      });
      // Valid only if not empty and matches (or if original is also empty)
      bool isValid = confirmPassword.isNotEmpty && newErrorMessage == null;
      widget.onValidChanged(isValid);
    } else if (!mounted && newErrorMessage != _errorMessage) {
      bool isValid = confirmPassword.isNotEmpty && newErrorMessage == null;
      widget.onValidChanged(isValid);
    }
  }

  @override
  void dispose() {
    // Remove listeners
    widget.passwordController.removeListener(_validateConfirmPassword);
    widget.confirmPasswordController.removeListener(_validateConfirmPassword);
    // Don't dispose the confirmPasswordController here, it's managed by the parent (_SignupPage1State)
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
          // decoration: BoxDecoration(
          //   border: Border.all(color: Colors.black, width: 1),
          // ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: widget
                      .confirmPasswordController, // Use dedicated controller
                  obscureText: _obscureText,
                  keyboardType: TextInputType.visiblePassword,
                  style: jerseyStyle(24, Color(0xFF9B5D6C)), // Consistent style
                  decoration: InputDecoration(
                    hintText: 'Confirm Password',
                    hintStyle: jerseyStyle(20, Color(0x9938000A)),
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
                    // Combine Tick and Visibility Toggle
                    suffixIcon: Row(
                      mainAxisSize:
                          MainAxisSize.min, // Prevent row taking full width
                      children: [
                        // Show tick only if valid and not empty
                        if (_errorMessage == null &&
                            widget.confirmPasswordController.text.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(
                                right: 5.0), // Space before eye
                            child: Image.asset(
                              'assets/images/tick_icon.png',
                              height: 40,
                              width: 40,
                              fit: BoxFit.contain,
                            ),
                          ),
                        // Visibility Toggle
                        GestureDetector(
                          onTap: _toggleVisibility,
                          child: Padding(
                            padding: const EdgeInsets.only(
                                right: 15.0), // Outer padding
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
                  // onChanged: (value) => _validateConfirmPassword(), // Listener handles this
                ),
              ),
            ],
          ),
        ),
        // Error Message Area
        Container(
          height: 20, // Reserve space for error message
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

// --- SignupPage1 (StatefulWidget) ---
class SignupPage1 extends StatefulWidget {
  const SignupPage1({Key? key}) : super(key: key);

  @override
  _SignupPage1State createState() => _SignupPage1State();
}

class _SignupPage1State extends State<SignupPage1> {
  // Controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController(); // Add controller

  // Validity Flags
  bool _isNameValid = false;
  bool _isEmailValid = false;
  bool _isPasswordValid = false;
  bool _isConfirmPasswordValid = false;

  // Getter for overall form validity
  bool get _isFormValid =>
      _isNameValid &&
      _isEmailValid &&
      _isPasswordValid &&
      _isConfirmPasswordValid;

  @override
  void dispose() {
    // Dispose all controllers
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // --- Callback Methods ---
  void _updateNameValidity(bool isValid) {
    if (mounted && _isNameValid != isValid) {
      setState(() {
        _isNameValid = isValid;
      });
    }
  }

  void _updateEmailValidity(bool isValid) {
    if (mounted && _isEmailValid != isValid) {
      setState(() {
        _isEmailValid = isValid;
      });
    }
  }

  void _updatePasswordValidity(bool isValid) {
    if (mounted && _isPasswordValid != isValid) {
      setState(() {
        _isPasswordValid = isValid;
        // Re-validate confirm password whenever password changes validity
        // This is handled by the listener in ConfirmPasswordInputWidget already
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

  // --- Navigation ---
  void _navigateToSignupPage3() {
    // Double-check validity before navigating (optional safety)
    if (!_isFormValid) return;

    String email = _emailController.text;
    String password = _passwordController.text;
    String name = _nameController.text;

    // Ensure context is still valid before navigating
    if (!mounted) return;

    Navigator.push(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 500),
        pageBuilder: (context, animation, secondaryAnimation) => SignUpPage3(
          // Pass the validated data
          email: email,
          password: password, // Pass the original password
          name: name,
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          final tween = Tween(begin: begin, end: end)
              .chain(CurveTween(curve: Curves.easeOut)); // Smoother curve
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
      // resizeToAvoidBottomInset: false, // Consider if needed based on background behavior
      body: SafeArea(
        child: Stack(
          children: [
            // Background
            Positioned.fill(
              child: Image.asset(
                'assets/images/background_signup_page_1.png',
                fit: BoxFit.cover,
              ),
            ),
            // Scrollable Form Content
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Back Button
                    IconButton(
                      icon: Image.asset(
                        'assets/images/app_navigation_left_icon.png',
                        width: 50,
                        height: 50,
                        fit: BoxFit.contain,
                      ),
                      onPressed: () {
                        // Go back to the previous screen (likely LoginSignupPage1)
                        if (Navigator.canPop(context)) {
                          Navigator.pop(context);
                        } else {
                          // Fallback if cannot pop (e.g., started directly on this page)
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const LoginSignupPage1()));
                        }
                        // Navigator.pushReplacement( // Use Replacement to avoid stacking signup pages
                        //   context,
                        //   MaterialPageRoute(
                        //     builder: (context) => const LoginSignupPage1(),
                        //   ),
                        // );
                      },
                    ),
                    const SizedBox(height: 24),
                    // Title
                    Text(
                      'Create \nAccount',
                      style: jerseyStyle(64).copyWith(height: 0.8),
                    ),
                    // Spacing before form fields - Adjust as needed
                    const SizedBox(
                        height: 100), // Reduced space maybe? Adjust visually

                    // --- Form Fields ---
                    FullNameInputWidget(
                      controller: _nameController,
                      onValidChanged: _updateNameValidity,
                    ),
                    // const SizedBox(height: 5), // Reduced space between fields
                    EmailInputWidget(
                      controller: _emailController,
                      onValidChanged: _updateEmailValidity,
                    ),
                    // const SizedBox(height: 5),
                    PasswordInputWidget(
                      passwordController: _passwordController,
                      onValidChanged: _updatePasswordValidity,
                    ),
                    // const SizedBox(height: 5),
                    ConfirmPasswordInputWidget(
                      passwordController:
                          _passwordController, // Pass original password controller
                      confirmPasswordController:
                          _confirmPasswordController, // Pass confirm controller
                      onValidChanged: _updateConfirmPasswordValidity,
                    ),
                    const SizedBox(height: 24), // Space before button

                    // --- Sign Up Button ---
                    Center(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF562634),
                          disabledBackgroundColor: const Color(0xFF562634)
                              .withOpacity(0.5), // Style for disabled state
                          foregroundColor: Colors.white, // Text color
                          disabledForegroundColor:
                              Colors.white.withOpacity(0.7),
                          fixedSize: const Size(350, 59),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            // Keep consistent style
                            borderRadius: BorderRadius.circular(8),
                            side: BorderSide(
                              color: _isFormValid
                                  ? Colors.white // Border when enabled
                                  : Colors.white.withOpacity(
                                      0.5), // Faded border when disabled
                              width: 2,
                            ),
                          ),
                        ),
                        // Enable button only when the form is valid
                        onPressed: _isFormValid ? _navigateToSignupPage3 : null,
                        child: Text(
                          'Sign up',
                          style: jerseyStyle(
                              24,
                              Colors
                                  .white), // Text color doesn't need disabled state if using foregroundColor
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // --- OR Divider ---
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Padding(
                            padding:
                                const EdgeInsets.only(left: 40.0, right: 10.0),
                            child: Divider(
                              color: Color(0x9938000A),
                              thickness: 1,
                            ),
                          ),
                        ),
                        Text(
                          'or',
                          style: jerseyStyle(24, Color(0x9938000A)),
                        ),
                        Expanded(
                          child: Padding(
                            padding:
                                const EdgeInsets.only(left: 10.0, right: 40.0),
                            child: Divider(
                              color: Color(0x9938000A),
                              thickness: 1,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // --- Log In Button ---
                    Center(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Color(0xFF9B5D6C), // Text color
                          fixedSize: const Size(350, 59),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: const BorderSide(
                              color: Color(0xFF9B5D6C),
                              width: 2,
                            ),
                          ),
                        ),
                        onPressed: () {
                          if (!mounted) return;
                          // Navigate to Login Page
                          // Use pushReplacement if coming from Login/Signup choice page
                          Navigator.pushReplacement(
                            context,
                            PageRouteBuilder(
                              transitionDuration:
                                  const Duration(milliseconds: 500),
                              // Slide from left (opposite of sign up)
                              pageBuilder:
                                  (context, animation, secondaryAnimation) =>
                                      const LoginPage1(),
                              transitionsBuilder: (context, animation,
                                  secondaryAnimation, child) {
                                const begin = Offset(-1.0, 0.0); // From Left
                                const end = Offset.zero;
                                final tween = Tween(begin: begin, end: end)
                                    .chain(CurveTween(curve: Curves.easeOut));
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
                    const SizedBox(height: 40), // Padding at the bottom
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
    home: SignupPage1(),
  ));
}
