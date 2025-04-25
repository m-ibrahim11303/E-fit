import 'package:flutter/material.dart';
import 'forgot_password_otp.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ForgotPasswordEmail extends StatefulWidget {
  @override
  _ForgotPasswordEmailState createState() => _ForgotPasswordEmailState();
}

class _ForgotPasswordEmailState extends State<ForgotPasswordEmail> {
  final TextEditingController _emailController = TextEditingController();

  Future<void> sendCode() async {
    final response = await http.post(
      Uri.parse('https://e-fit-backend.onrender.com/forget-password/send-code'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': _emailController.text.trim()}),
    );

    if (response.statusCode == 200) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              ForgotPasswordOTP(email: _emailController.text.trim()),
        ),
      );
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Failed to send code.")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Forgot Password")),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
                controller: _emailController,
                decoration: InputDecoration(labelText: "Email")),
            ElevatedButton(onPressed: sendCode, child: Text("Send Code")),
          ],
        ),
      ),
    );
  }
}
