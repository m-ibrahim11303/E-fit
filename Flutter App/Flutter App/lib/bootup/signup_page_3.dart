import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:login_signup_1/home_page.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:crypto/crypto.dart';
import 'package:login_signup_1/style.dart';

String name_ = "";
String password_ = "";
String email_ = "";

final FlutterSecureStorage storage = FlutterSecureStorage();

class SignUpPage3 extends StatefulWidget {
  final String email;
  final String password;
  final String name;

  const SignUpPage3({
    Key? key,
    required this.email,
    required this.password,
    required this.name,
  }) : super(key: key);

  @override
  _SignUpPage3State createState() => _SignUpPage3State();
}

class _SignUpPage3State extends State<SignUpPage3> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  DateTime? _selectedDate;
  String? _selectedGender;
  bool _isLoading = false; // Added to track loading state

  final List<String> _genders = ['Male', 'Female', 'Other'];

  @override
  void initState() {
    super.initState();

    name_ = widget.name;
    email_ = widget.email;
    password_ = widget.password;

    String first_name = '';
    String other_names = '';

    List<String> parts = name_.trim().split(RegExp(r'\s+'));
    if (parts.length > 1) {
      first_name = parts.first;
      other_names = parts.sublist(1).join(' ');
    } else {
      first_name = name_;
      other_names = '';
    }

    _firstNameController.text = first_name;
    _lastNameController.text = other_names;
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  String _hashPassword(String password) {
    var bytes = utf8.encode(password);
    var digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _showResultPopup(String message, bool isSuccess) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isSuccess ? Icons.check_circle : Icons.error,
                color: isSuccess ? Colors.green : Colors.red,
                size: 50,
              ),
              const SizedBox(height: 16),
              Text(
                message,
                style: jerseyStyle(16, Colors.black),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the popup
                if (isSuccess && mounted) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => HomeScreen()),
                  );
                }
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _completeSignUp() async {
    setState(() {
      _isLoading = true; // Show loading circle
    });

    Map<String, dynamic> userData = {
      'firstName': _firstNameController.text,
      'lastName': _lastNameController.text,
      'dateOfBirth': _selectedDate?.toIso8601String(),
      'weight': _weightController.text,
      'height': _heightController.text,
      'gender': _selectedGender,
      'email': email_,
      'password': _hashPassword(password_),
    };

    try {
      final response = await http.post(
        Uri.parse('https://e-fit-backend.onrender.com/user/create'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(userData),
      );

      if (response.statusCode == 201) {
        final responseData = jsonDecode(response.body);

        if (responseData['email'] != null) {
          await storage.write(key: 'email', value: email_);
          await _showResultPopup('Sign up successful!', true);
        } else {
          await _showResultPopup(
              'Sign up failed: Invalid response from server', false);
        }
      } else {
        await _showResultPopup(
            'Sign up failed: Server error ${response.statusCode}', false);
      }
    } catch (e) {
      await _showResultPopup('Sign up failed: $e', false);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false; // Hide loading circle
        });
      }
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
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('SIGN UP', style: jerseyStyle(32, Colors.black)),
                const SizedBox(height: 8),
                Text(
                  'The lower abdomen and hips are the most difficult areas of the body to reduce when...',
                  style: jerseyStyle(16, Colors.grey),
                ),
                const SizedBox(height: 20),
                _buildTextField(
                  controller: _firstNameController,
                  hintText: 'First Name',
                ),
                _buildTextField(
                  controller: _lastNameController,
                  hintText: 'Last Name',
                ),
                GestureDetector(
                  onTap: () => _selectDate(context),
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 16.0),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _selectedDate == null
                              ? 'Date of Birth'
                              : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                          style: jerseyStyle(
                            20,
                            _selectedDate == null ? Colors.grey : Colors.black,
                          ),
                        ),
                        Image.asset(
                          'assets/images/calendar_icon.png',
                          height: 24,
                          width: 24,
                          fit: BoxFit.contain,
                        ),
                      ],
                    ),
                  ),
                ),
                _buildTextField(
                  controller: _weightController,
                  hintText: 'Weight',
                  keyboardType: TextInputType.number,
                ),
                _buildTextField(
                  controller: _heightController,
                  hintText: 'Height',
                  keyboardType: TextInputType.number,
                ),
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedGender,
                      hint: Text('Gender', style: jerseyStyle(20, Colors.grey)),
                      isExpanded: true,
                      items: _genders.map((String gender) {
                        return DropdownMenuItem<String>(
                          value: gender,
                          child: Text(gender,
                              style: jerseyStyle(20, Colors.black)),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedGender = newValue;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF562634),
                      fixedSize: const Size(350, 59),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    onPressed: _isLoading ? null : _completeSignUp,
                    child: _isLoading
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
                            'Complete sign up',
                            style: jerseyStyle(20, Colors.white),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
