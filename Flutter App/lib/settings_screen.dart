// import 'package:flutter/material.dart';

// // Settings Screen
// class SettingsScreen extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Settings')),
//       body: ListView(
//         children: [
//           ListTile(
//             title: Text('About'),
//             leading: Icon(Icons.info),
//             onTap: () {
//               // Add about functionality
//             },
//           ),
//           ListTile(
//             title: Text('Notifications'),
//             leading: Icon(Icons.notifications),
//             onTap: () {
//               // Add notifications functionality
//             },
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:login_signup_1/bootup/signup_page_1.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SettingsScreen extends StatelessWidget {
  final String email; // User's email

  SettingsScreen({required this.email});

  Future<void> _deleteAccount(BuildContext context) async {
    final TextEditingController passwordController = TextEditingController();

    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirm Deletion'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Enter your password to delete your account:'),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(labelText: 'Password'),
            ),
          ],
        ),
        actions: [
          TextButton(
            child: Text('Cancel'),
            onPressed: () => Navigator.pop(context, false),
          ),
          TextButton(
            child: Text('Delete', style: TextStyle(color: Colors.red)),
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );

    if (shouldDelete == true) {
      final password = passwordController.text.trim();

      try {
        final response = await http.post(
          Uri.parse('https://e-fit-backend.onrender.com/user/delete'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'email': email, 'password': password}),
        );

        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Account deleted successfully')),
          );

          // Redirect to login page and clear history
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => SignupPage1()),
            (Route<dynamic> route) => false,
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed: ${response.body}')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Settings')),
      body: ListView(
        children: [
          ListTile(
            title: Text('About'),
            leading: Icon(Icons.info),
            onTap: () {
              // Add about functionality
            },
          ),
          ListTile(
            title: Text('Notifications'),
            leading: Icon(Icons.notifications),
            onTap: () {
              // Add notifications functionality
            },
          ),
          Divider(),
          ListTile(
            title: Text('Delete Account', style: TextStyle(color: Colors.red)),
            leading: Icon(Icons.delete, color: Colors.red),
            onTap: () => _deleteAccount(context),
          ),
        ],
      ),
    );
  }
}
