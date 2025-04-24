import 'package:flutter/material.dart';
import 'package:login_signup_1/settings_screens/delete_account.dart';
import 'package:login_signup_1/settings_screens/change_password.dart';

class SettingsScreen extends StatelessWidget {
  final String email; // User's email

  SettingsScreen({required this.email});

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
            title: Text('Change Password'),
            leading: Icon(Icons.lock_reset),
            onTap: () => changePassword(context, email),
          ),
          ListTile(
            title: Text('Delete Account', style: TextStyle(color: Colors.red)),
            leading: Icon(Icons.delete, color: Colors.red),
            onTap: () => deleteAccount(context, email),
          ),
        ],
      ),
    );
  }
}
