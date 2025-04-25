import 'package:flutter/material.dart';
import 'forgot_password_reset.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ForgotPasswordOTP extends StatefulWidget {
  final String email;

  const ForgotPasswordOTP({Key? key, required this.email}) : super(key: key);

  @override
  _ForgotPasswordOTPState createState() => _ForgotPasswordOTPState();
}

class _ForgotPasswordOTPState extends State<ForgotPasswordOTP> {
  final TextEditingController _otpController = TextEditingController();

  Future<void> verifyCode() async {
    final response = await http.post(
      Uri.parse(
          'https://e-fit-backend.onrender.com/forget-password/verify-code'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(
          {'email': widget.email, 'code': _otpController.text.trim()}),
    );

    if (response.statusCode == 200) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ForgotPasswordReset(
            email: widget.email,
            code: _otpController.text.trim(),
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Invalid code.")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Enter OTP")),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
                controller: _otpController,
                decoration: InputDecoration(labelText: "6-digit OTP")),
            ElevatedButton(onPressed: verifyCode, child: Text("Verify")),
          ],
        ),
      ),
    );
  }
}
