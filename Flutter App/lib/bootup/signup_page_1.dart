import 'package:flutter/material.dart';
import 'package:login_signup_1/bootup/signup_page_3.dart';
import 'package:login_signup_1/bootup/login_page_1.dart';
import 'package:login_signup_1/bootup/login_signup_page_1.dart';
import 'package:login_signup_1/style.dart'; // Assuming this file exists and defines styles/colors like jerseyStyle, lightMaroon, hintMaroon, errorRed, darkMaroon, brightWhite and the slideTo function

// FullNameInputWidget remains the same as before
class FullNameInputWidget extends StatefulWidget {
  final TextEditingController controller;
  final Function(bool isValid) onValidChanged;

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
    widget.controller.addListener(_validate);
    // Initial validation call in case the controller already has text
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _validate();
      }
    });
  }

  String? _validateName(String value) {
    if (value.isEmpty) {
      return 'Name cannot be empty';
    }
    if (value.length < 2) {
      return 'Name must be at least 2 characters';
    }
    return null;
  }

  void _validate() {
    // Ensure validation logic only runs if the widget is still mounted
    if (!mounted) return;

    final value = widget.controller.text;
    final newErrorMessage = _validateName(value);
    final bool newValidity = newErrorMessage == null;
    final bool validityChanged = (_errorMessage == null) != newValidity;

    if (newErrorMessage != _errorMessage) {
      setState(() {
        _errorMessage = newErrorMessage;
      });
    }

    // Only call the callback if the validity state actually changed
    if (validityChanged) {
      widget.onValidChanged(newValidity);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_validate);
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
                  controller: widget.controller,
                  keyboardType: TextInputType.name,
                  textCapitalization: TextCapitalization.words,
                  style: jerseyStyle(24, lightMaroon),
                  decoration: InputDecoration(
                    hintText: 'Full Name',
                    hintStyle: jerseyStyle(20, hintMaroon),
                    border: InputBorder.none,
                    prefixIconConstraints: const BoxConstraints(
                      minWidth: 24,
                      minHeight: 24,
                    ),
                    prefixIcon: Padding(
                      padding: const EdgeInsets.only(right: 8.0, left: 5.0),
                      child: Image.asset(
                        'assets/images/profile_icon.png', // Ensure this asset exists
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
                              'assets/images/tick_icon.png', // Ensure this asset exists
                              height: 40,
                              width: 40,
                              fit: BoxFit.contain,
                            ),
                          )
                        : null,
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
                    color: errorRed,
                    fontSize: 14,
                    height: 1.0, // Reduces spacing around text
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                )
              : null, // Use null instead of SizedBox to truly take no space
        ),
      ],
    );
  }
}

// EmailInputWidget remains the same as before
class EmailInputWidget extends StatefulWidget {
  final TextEditingController controller;
  final Function(bool isValid) onValidChanged;

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
    // Initial validation call in case the controller already has text
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _validate();
      }
    });
  }

  String? _validateEmail(String value) {
    if (value.isEmpty) {
      return 'Email cannot be empty';
    }
    // Basic email regex, consider a more robust one if needed
    final emailRegex =
        RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  void _validate() {
    // Ensure validation logic only runs if the widget is still mounted
    if (!mounted) return;

    final value = widget.controller.text;
    final newErrorMessage = _validateEmail(value);
    final bool newValidity = newErrorMessage == null;
    // Check if the actual validity state (valid/invalid) changed
    final bool validityChanged = (_errorMessage == null) != newValidity;

    if (newErrorMessage != _errorMessage) {
      setState(() {
        _errorMessage = newErrorMessage;
      });
    }

    // Only call the callback if the validity state actually changed
    if (validityChanged) {
      widget.onValidChanged(newValidity);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_validate);
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
                  controller: widget.controller,
                  keyboardType: TextInputType.emailAddress,
                  style: jerseyStyle(24, lightMaroon),
                  decoration: InputDecoration(
                    hintText: 'Email',
                    hintStyle: jerseyStyle(20, hintMaroon),
                    border: InputBorder.none,
                    prefixIconConstraints: const BoxConstraints(
                      minWidth: 24,
                      minHeight: 24,
                    ),
                    prefixIcon: Padding(
                      padding: const EdgeInsets.only(right: 8.0, left: 5.0),
                      child: Image.asset(
                        'assets/images/mail_icon.png', // Ensure this asset exists
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
                              'assets/images/tick_icon.png', // Ensure this asset exists
                              height: 40,
                              width: 40,
                              fit: BoxFit.contain,
                            ),
                          )
                        : null,
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
                    color: errorRed,
                    fontSize: 14,
                    height: 1.0, // Reduces spacing around text
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                )
              : null, // Use null instead of SizedBox to truly take no space
        ),
      ],
    );
  }
}

// PasswordInputWidget remains the same as before
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
  bool _withinMaxLength = true; // Assume true initially for empty string
  bool _isValid = false; // Track overall validity

  @override
  void initState() {
    super.initState();
    widget.passwordController.addListener(_validatePassword);
    // Initial validation call in case the controller already has text (e.g., autofill)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _validatePassword();
      }
    });
  }

  void _toggleVisibility() {
    // Check mounted before calling setState
    if (mounted) {
      setState(() {
        _obscureText = !_obscureText;
      });
    }
  }

  void _validatePassword() {
    // Ensure validation logic only runs if the widget is still mounted
    if (!mounted) return;

    final value = widget.passwordController.text;

    // Calculate new states for criteria
    final newHasMinLength = value.length >= 8;
    final newHasNumbers = RegExp(r'[0-9]').hasMatch(value);
    final newHasLowerCase = RegExp(r'[a-z]').hasMatch(value);
    final newHasUpperCase = RegExp(r'[A-Z]').hasMatch(value);
    final newWithinMaxLength = value.length <= 30;

    // Calculate new overall validity
    final newIsValid = newHasMinLength &&
        newHasNumbers &&
        newHasLowerCase &&
        newHasUpperCase &&
        newWithinMaxLength;

    // Check if any visual criteria state changed
    bool criteriaStateChanged = newHasMinLength != _hasMinLength ||
        newHasNumbers != _hasNumbers ||
        newHasLowerCase != _hasLowerCase ||
        newHasUpperCase != _hasUpperCase ||
        newWithinMaxLength != _withinMaxLength;

    // Check if the overall validity actually changed
    bool validityChanged = newIsValid != _isValid;

    // Update UI state only if criteria changed
    if (criteriaStateChanged) {
      setState(() {
        _hasMinLength = newHasMinLength;
        _hasNumbers = newHasNumbers;
        _hasLowerCase = newHasLowerCase;
        _hasUpperCase = newHasUpperCase;
        _withinMaxLength = newWithinMaxLength;
      });
    }

    // Update internal validity state and notify parent *only* if validity changed
    if (validityChanged) {
      _isValid = newIsValid; // Update internal state tracker
      widget.onValidChanged(_isValid);
    }
  }

  Widget _buildValidationItem(String text, bool isValid) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          isValid
              ? 'assets/images/green_check_icon.png' // Ensure this asset exists
              : 'assets/images/red_cross_icon.png', // Ensure this asset exists
          height: 16,
          width: 16,
          fit: BoxFit.contain,
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: jerseyStyle(
              16, hintMaroon), // Assuming jerseyStyle handles size/color
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
                  style: jerseyStyle(24, lightMaroon),
                  decoration: InputDecoration(
                    hintText: 'Password',
                    hintStyle: jerseyStyle(20, hintMaroon),
                    border: InputBorder.none,
                    prefixIconConstraints: const BoxConstraints(
                      minWidth: 24,
                      minHeight: 24,
                    ),
                    prefixIcon: Padding(
                      padding: const EdgeInsets.only(right: 8.0, left: 5.0),
                      child: Image.asset(
                        'assets/images/lock_icon.png', // Ensure this asset exists
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
                              ? 'assets/images/no_see_icon.png' // Ensure this asset exists
                              : 'assets/images/see_icon.png', // Ensure this asset exists
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

// ConfirmPasswordInputWidget remains the same as before
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
  bool _isValid = false; // Track internal validity state

  @override
  void initState() {
    super.initState();
    // Listen to both controllers
    widget.passwordController.addListener(_validateConfirmPassword);
    widget.confirmPasswordController.addListener(_validateConfirmPassword);
    // Initial validation call
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _validateConfirmPassword();
      }
    });
  }

  void _toggleVisibility() {
    if (mounted) {
      setState(() {
        _obscureText = !_obscureText;
      });
    }
  }

  void _validateConfirmPassword() {
    // Ensure validation logic only runs if the widget is still mounted
    if (!mounted) return;

    final originalPassword = widget.passwordController.text;
    final confirmPassword = widget.confirmPasswordController.text;
    String? newErrorMessage;

    // Determine error message
    if (confirmPassword.isNotEmpty && confirmPassword != originalPassword) {
      newErrorMessage = 'Passwords do not match';
    } else {
      newErrorMessage = null; // No error if empty or matches
    }

    // Determine validity: must not be empty and must match (no error)
    final bool newValidity =
        confirmPassword.isNotEmpty && newErrorMessage == null;

    // Check if error message needs UI update
    if (newErrorMessage != _errorMessage) {
      setState(() {
        _errorMessage = newErrorMessage;
      });
    }

    // Check if validity state changed and notify parent if it did
    if (newValidity != _isValid) {
      _isValid = newValidity; // Update internal tracker
      widget.onValidChanged(_isValid);
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
                  style: jerseyStyle(24, lightMaroon),
                  decoration: InputDecoration(
                    hintText: 'Confirm Password',
                    hintStyle: jerseyStyle(20, hintMaroon),
                    border: InputBorder.none,
                    prefixIconConstraints: const BoxConstraints(
                      minWidth: 24,
                      minHeight: 24,
                    ),
                    prefixIcon: Padding(
                      padding: const EdgeInsets.only(right: 8.0, left: 5.0),
                      child: Image.asset(
                        'assets/images/lock_icon.png', // Ensure this asset exists
                        height: 30,
                        width: 30,
                        fit: BoxFit.contain,
                      ),
                    ),
                    suffixIconConstraints: const BoxConstraints(
                      minWidth: 24,
                      minHeight: 24,
                    ),
                    // Combine tick and visibility toggle in a Row
                    suffixIcon: Row(
                      mainAxisSize: MainAxisSize.min, // Use minimum space
                      children: [
                        // Show tick only if valid (no error message and not empty)
                        if (_errorMessage == null &&
                            widget.confirmPasswordController.text.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(right: 5.0),
                            child: Image.asset(
                              'assets/images/tick_icon.png', // Ensure this asset exists
                              height: 40,
                              width: 40,
                              fit: BoxFit.contain,
                            ),
                          ),
                        // Visibility toggle
                        GestureDetector(
                          onTap: _toggleVisibility,
                          child: Padding(
                            padding: const EdgeInsets.only(right: 15.0),
                            child: Image.asset(
                              _obscureText
                                  ? 'assets/images/no_see_icon.png' // Ensure this asset exists
                                  : 'assets/images/see_icon.png', // Ensure this asset exists
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
                    color: errorRed,
                    fontSize: 14,
                    height: 1.0, // Reduces spacing around text
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                )
              : null, // Use null instead of SizedBox
        ),
      ],
    );
  }
}

class SignupPage1 extends StatefulWidget {
  const SignupPage1({Key? key}) : super(key: key);

  @override
  _SignupPage1State createState() => _SignupPage1State();
}

class _SignupPage1State extends State<SignupPage1> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  // Track the validity state from child widgets
  bool _isNameValid = false;
  bool _isEmailValid = false;
  bool _isPasswordValid = false;
  bool _isConfirmPasswordValid = false;

  // Compute overall form validity based on individual field validity
  bool get _isFormValid =>
      _isNameValid &&
      _isEmailValid &&
      _isPasswordValid &&
      _isConfirmPasswordValid;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // Callbacks to update state based on child widget validity changes
  // Use mounted check before calling setState
  void _updateNameValidity(bool isValid) {
    if (mounted && _isNameValid != isValid) {
      setState(() {
        _isNameValid = isValid;
      });
    } else if (!mounted && _isNameValid != isValid) {
      _isNameValid = isValid;
    }
  }

  void _updateEmailValidity(bool isValid) {
    if (mounted && _isEmailValid != isValid) {
      setState(() {
        _isEmailValid = isValid;
      });
    } else if (!mounted && _isEmailValid != isValid) {
      _isEmailValid = isValid;
    }
  }

  void _updatePasswordValidity(bool isValid) {
    if (mounted && _isPasswordValid != isValid) {
      setState(() {
        _isPasswordValid = isValid;
      });
    } else if (!mounted && _isPasswordValid != isValid) {
      _isPasswordValid = isValid;
    }
  }

  void _updateConfirmPasswordValidity(bool isValid) {
    if (mounted && _isConfirmPasswordValid != isValid) {
      setState(() {
        _isConfirmPasswordValid = isValid;
      });
    } else if (!mounted && _isConfirmPasswordValid != isValid) {
      _isConfirmPasswordValid = isValid;
    }
  }

  void _navigateToSignupPage3() {
    // Double check form validity before navigation
    if (!_isFormValid) return;
    // Check mounted before accessing context for navigation
    if (!mounted) return;

    String email = _emailController.text;
    String password = _passwordController.text;
    String name = _nameController.text;

    // Assuming slideTo is a helper function for navigation defined in style.dart
    slideTo(context, SignUpPage3(email: email, password: password, name: name));
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    // Removed the outer Stack. The Scaffold now directly contains the SingleChildScrollView.
    return Scaffold(
      // Set a background color for the Scaffold area outside the scroll view / safe area,
      // though the Container's background should cover most cases.
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        // Make the entire body scrollable
        child: Container(
          // This container holds the background and content
          constraints: BoxConstraints(
            // Ensures the container is at least screen height, making the background cover it.
            minHeight: screenHeight,
          ),
          decoration: const BoxDecoration(
            image: DecorationImage(
              // The background image is now part of this scrollable container
              image: AssetImage(
                  'assets/images/background_signup_page_1.png'), // Ensure this asset exists
              fit: BoxFit.cover, // Cover the entire container area
              // Optional: Align the image if needed, e.g., Alignment.topCenter
              // alignment: Alignment.topCenter,
            ),
          ),
          // SafeArea is placed inside the container to pad the actual content column
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16.0), // Horizontal padding for content
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                // Ensures Column takes minimum vertical space needed by children inside SingleChildScrollView
                mainAxisSize: MainAxisSize.min,
                children: [
                  // --- Content Widgets Start ---
                  Padding(
                    padding: const EdgeInsets.only(
                        top: 16.0), // Top padding for back button
                    child: IconButton(
                      icon: Image.asset(
                        'assets/images/app_navigation_left_icon.png', // Ensure this asset exists
                        width: 30,
                        height: 30,
                        fit: BoxFit.contain,
                      ),
                      iconSize: 30,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () {
                        if (Navigator.canPop(context)) {
                          Navigator.pop(context);
                        } else {
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const LoginSignupPage1()));
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Create \nAccount',
                    style: jerseyStyle(64).copyWith(height: 0.8),
                  ),
                  const SizedBox(height: 60), // Adjusted spacing
                  FullNameInputWidget(
                    controller: _nameController,
                    onValidChanged: _updateNameValidity,
                  ),
                  const SizedBox(height: 16),
                  EmailInputWidget(
                    controller: _emailController,
                    onValidChanged: _updateEmailValidity,
                  ),
                  const SizedBox(height: 16),
                  PasswordInputWidget(
                    passwordController: _passwordController,
                    onValidChanged: _updatePasswordValidity,
                  ),
                  const SizedBox(height: 16),
                  ConfirmPasswordInputWidget(
                    passwordController: _passwordController,
                    confirmPasswordController: _confirmPasswordController,
                    onValidChanged: _updateConfirmPasswordValidity,
                  ),
                  const SizedBox(height: 40),
                  Center(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: darkMaroon,
                        disabledBackgroundColor: darkMaroon.withOpacity(0.5),
                        foregroundColor: brightWhite,
                        disabledForegroundColor: brightWhite.withOpacity(0.7),
                        minimumSize: const Size(double.infinity, 59),
                        padding: EdgeInsets.zero,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(
                            color: _isFormValid
                                ? brightWhite
                                : brightWhite.withOpacity(0.5),
                            width: 2,
                          ),
                        ),
                      ).copyWith(
                        elevation: MaterialStateProperty.all(0),
                      ),
                      onPressed: _isFormValid ? _navigateToSignupPage3 : null,
                      child: Text(
                        'Sign up',
                        style: jerseyStyle(24, Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Padding(
                          padding:
                              const EdgeInsets.only(left: 40.0, right: 10.0),
                          child: Divider(
                            color: hintMaroon,
                            thickness: 1,
                          ),
                        ),
                      ),
                      Text(
                        'or',
                        style: jerseyStyle(24, hintMaroon),
                      ),
                      Expanded(
                        child: Padding(
                          padding:
                              const EdgeInsets.only(left: 10.0, right: 40.0),
                          child: Divider(
                            color: hintMaroon,
                            thickness: 1,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Center(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: brightWhite,
                        foregroundColor: lightMaroon,
                        minimumSize: const Size(double.infinity, 59),
                        padding: EdgeInsets.zero,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: const BorderSide(
                            color: lightMaroon,
                            width: 2,
                          ),
                        ),
                      ).copyWith(
                        elevation: MaterialStateProperty.all(0),
                      ),
                      onPressed: () {
                        if (!mounted) return;
                        slideTo(context, LoginPage1());
                      },
                      child: Text(
                        'Log in',
                        style: jerseyStyle(24, lightMaroon),
                      ),
                    ),
                  ),
                  // Added SizedBox at the end inside the Column to ensure some padding at the bottom when scrolled fully.
                  const SizedBox(height: 5),
                  // --- Content Widgets End ---
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Mock style.dart content if it's not provided, otherwise remove this section
// Ensure you have the actual style.dart file with correct definitions

/*
// class MockStyle {
//   static const Color lightMaroon = Color(0xFFa80040); // Example color
//   static const Color hintMaroon = Color(0xFF8a405a); // Example color
//   static const Color errorRed = Colors.red;
//   static const Color darkMaroon = Color(0xFF6a002a); // Example color
//   static const Color brightWhite = Colors.white;

//   static TextStyle jerseyStyle(double size, [Color? color]) {
//     // Assuming 'Jersey10-Regular' is added to pubspec.yaml and assets
//     return TextStyle(
//       fontFamily: 'Jersey10', // Use actual font name if different
//       fontSize: size,
//       color: color ?? lightMaroon, // Default color if not provided
//     );
//   }

//   // Mock slideTo function for navigation
//   static void slideTo(BuildContext context, Widget page) {
//      Navigator.push(
//       context,
//       PageRouteBuilder(
//         transitionDuration: const Duration(milliseconds: 500),
//         pageBuilder: (context, animation, secondaryAnimation) => page,
//         transitionsBuilder: (context, animation, secondaryAnimation, child) {
//           const begin = Offset(1.0, 0.0); // Slide from right
//           const end = Offset.zero;
//           final tween = Tween(begin: begin, end: end)
//               .chain(CurveTween(curve: Curves.easeOut));
//           final offsetAnimation = animation.drive(tween);
//           return SlideTransition(
//             position: offsetAnimation,
//             child: child,
//           );
//         },
//       ),
//     );
//   }
// }

// // Use the mock definitions if style.dart is missing
// final Color lightMaroon = MockStyle.lightMaroon;
// final Color hintMaroon = MockStyle.hintMaroon;
// final Color errorRed = MockStyle.errorRed;
// final Color darkMaroon = MockStyle.darkMaroon;
// final Color brightWhite = MockStyle.brightWhite;
// TextStyle jerseyStyle(double size, [Color? color]) => MockStyle.jerseyStyle(size, color);
// void slideTo(BuildContext context, Widget page) => MockStyle.slideTo(context, page);
*/
