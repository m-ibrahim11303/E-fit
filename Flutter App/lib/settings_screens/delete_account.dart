import 'package:flutter/material.dart';
import 'package:login_signup_1/bootup/signup_page_1.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:login_signup_1/style.dart';

Future<void> deleteAccount(BuildContext context, String email) async {
  final TextEditingController passwordController = TextEditingController();

  final shouldDelete = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(
        'Confirm Deletion',
        style: jerseyStyle(24, darkMaroon),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Enter your password to delete your account:',
            style: jerseyStyle(16, darkMaroon),
          ),
          TextField(
            controller: passwordController,
            obscureText: true,
            style: jerseyStyle(18, darkMaroon), 
            decoration: InputDecoration(
              labelText: 'Password',
              labelStyle: jerseyStyle(18, lightMaroon),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          child: Text(
            'Cancel',
            style: jerseyStyle(18, darkMaroon),
          ),
          onPressed: () => Navigator.pop(context, false),
        ),
        TextButton(
          child: Text(
            'Delete',
            style: jerseyStyle(18, errorRed),
          ),
          onPressed: () => Navigator.pop(context, true),
        ),
      ],
    ),
  );

  if (shouldDelete == true) {
    final password = hashPassword(passwordController.text.trim());

    try {
      final response = await http.post(
        Uri.parse('https://e-fit-backend.onrender.com/user/delete'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Account deleted successfully',
              style: jerseyStyle(16, brightWhite),
            ),
            backgroundColor: darkMaroon,
          ),
        );
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  const SignupPage1()),
          (Route<dynamic> route) => false,
        );
      } else {
        if (!context.mounted) return;
        String errorMessage = 'Failed: Status Code ${response.statusCode}';
        try {
          final decodedBody = jsonDecode(response.body);
          if (decodedBody is Map && decodedBody.containsKey('message')) {
            errorMessage = 'Failed: ${decodedBody['message']}';
          } else {
            errorMessage = 'Failed: ${response.body}';
          }
        } catch (_) {
          errorMessage = 'Failed: ${response.body}';
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              errorMessage,
              style: jerseyStyle(16, brightWhite),
            ),
            backgroundColor:
                errorRed,
          ),
        );
      }
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error: $e',
            style: jerseyStyle(16, brightWhite),
          ),
          backgroundColor: errorRed,
        ),
      );
    } finally {
      passwordController.dispose();
    }
  } else {
    passwordController.dispose();
  }
}

String hashPassword(String password) {
  var bytes = utf8.encode(password);
  var digest = sha256.convert(bytes);
  return digest.toString();
}
