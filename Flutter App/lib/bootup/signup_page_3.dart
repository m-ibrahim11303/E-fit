import 'package:flutter/material.dart';
import 'signup_page_2.dart'; // Import the VerifyEmailPage

// Global variables
String name_ = "";
String password_ = "";
String email_ = "";

// Define jerseyStyle globally
TextStyle jerseyStyle(double fontSize, [Color color = Colors.white]) {
  return TextStyle(
    fontFamily: 'Jersey 25',
    fontSize: fontSize,
    color: color,
  );
}

class SignUpPage3 extends StatefulWidget {
  final String email; // Email from previous screen
  final String password; // Password from previous screen
  final String name; // Name from previous screen

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
  double _lifestyleValue = 2; // Default to "Moderately active"

  final List<String> _genders = ['Male', 'Female', 'Other'];
  final List<String> _lifestyleLabels = [
    'Sedentary',
    'Lightly active',
    'Moderately active',
    'Very active',
    'Super active'
  ];

  @override
  void initState() {
    super.initState();

    // Set the global variables from widget values
    name_ = widget.name;
    email_ = widget.email;
    password_ = widget.password;

    // Name processing from global variable
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
                Text('LIFESTYLE', style: jerseyStyle(16, Colors.black)),
                Slider(
                  value: _lifestyleValue,
                  min: 0,
                  max: 4,
                  divisions: 4,
                  onChanged: (double value) {
                    setState(() {
                      _lifestyleValue = value;
                    });
                  },
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: _lifestyleLabels.map((label) {
                    return Text(label,
                        style: jerseyStyle(12, Colors.grey),
                        textAlign: TextAlign.center);
                  }).toList(),
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
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SignUpPage2(
                            email: email_,
                            password: password_,
                            name: name_,
                          ),
                        ),
                      );
                    },
                    child: Text('Complete sign up',
                        style: jerseyStyle(20, Colors.white)),
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
