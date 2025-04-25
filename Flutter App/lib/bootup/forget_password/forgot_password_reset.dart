import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'dart:convert' as convert;

class ForgotPasswordReset extends StatefulWidget {
  final String email;
  final String code;

  const ForgotPasswordReset({Key? key, required this.email, required this.code})
      : super(key: key);

  @override
  _ForgotPasswordResetState createState() => _ForgotPasswordResetState();
}

class _ForgotPasswordResetState extends State<ForgotPasswordReset> {
  final TextEditingController _passwordController = TextEditingController();

  String sha256Hash(String password) {
    return sha256.convert(convert.utf8.encode(password)).toString();
  }

  Future<void> resetPassword() async {
    final response = await http.post(
      Uri.parse('https://e-fit-backend.onrender.com/forget-password/reset'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': widget.email,
        'code': widget.code,
        'newPassword': hashPassword(_passwordController.text.trim()),
      }),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Password reset successful.")));
      Navigator.popUntil(context, (route) => route.isFirst); // Go back to login
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Reset failed.")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Reset Password")),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(labelText: "New Password")),
            ElevatedButton(
                onPressed: resetPassword, child: Text("Reset Password")),
          ],
        ),
      ),
    );
  }
}

String hashPassword(String password) {
  var bytes = utf8.encode(password);
  var digest = sha256.convert(bytes);
  return digest.toString();
}
