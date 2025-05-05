import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:login_signup_1/style.dart';

Future<void> changePassword(BuildContext context, String email) async {
  final currentController = TextEditingController();
  final newController = TextEditingController();
  final confirmController = TextEditingController();

  final shouldChange = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(
        'Change Password',
        style: jerseyStyle(24, darkMaroon),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: currentController,
            obscureText: true,
            style: jerseyStyle(18, darkMaroon),
            decoration: InputDecoration(
              labelText: 'Current Password',
              labelStyle: jerseyStyle(18, lightMaroon), 
            ),
          ),
          TextField(
            controller: newController,
            obscureText: true,
            style: jerseyStyle(18, darkMaroon),
            decoration: InputDecoration(
              labelText: 'New Password',
              labelStyle: jerseyStyle(18, lightMaroon),
            ),
          ),
          TextField(
            controller: confirmController,
            obscureText: true,
            style: jerseyStyle(18, darkMaroon), 
            decoration: InputDecoration(
              labelText: 'Confirm New Password',
              labelStyle: jerseyStyle(18, lightMaroon),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(
            'Cancel',
            style: jerseyStyle(18, darkMaroon),
          ),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text(
            'Change',
            style: jerseyStyle(18, darkMaroon),
          ),
        ),
      ],
    ),
  );

  if (shouldChange == true) {
    final current = currentController.text.trim();
    final newPass = newController.text.trim();
    final confirm = confirmController.text.trim();

    if (newPass != confirm) {
      _showSnackbar(context, 'New passwords do not match.');
      return;
    }

    if (!isValidPassword(newPass)) {
      _showSnackbar(context,
          'Password must be 8–30 characters with upper, lower, and number.');
      return;
    }

    final hashedCurrent = hashPassword(current);
    final hashedNew = hashPassword(newPass);

    try {
      final response = await http.post(
        Uri.parse('https://e-fit-backend.onrender.com/user/change-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'currentPassword': hashedCurrent,
          'newPassword': hashedNew,
        }),
      );

      if (response.statusCode == 200) {
        _showSnackbar(context, 'Password updated successfully.');
      } else {
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
        _showSnackbar(context, errorMessage);
      }
    } catch (e) {
      _showSnackbar(context, 'Error: $e');
    }
  }

  currentController.dispose();
  newController.dispose();
  confirmController.dispose();
}

String hashPassword(String password) {
  var bytes = utf8.encode(password);
  var digest = sha256.convert(bytes);
  return digest.toString();
}

bool isValidPassword(String password) {
  final regex = RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)[A-Za-z\d]{8,30}$');
  return regex.hasMatch(password);
}

void _showSnackbar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        message,
        style: jerseyStyle(16, brightWhite),
      ),
      backgroundColor: Colors.black87,
    ),
  );
}
