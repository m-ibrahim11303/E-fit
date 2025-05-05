import 'package:flutter/material.dart';
import 'package:login_signup_1/settings_screens/delete_account.dart';
import 'package:login_signup_1/settings_screens/change_password.dart';
import 'package:login_signup_1/style.dart';

class SettingsScreen extends StatelessWidget {
  final String email;

  const SettingsScreen({Key? key, required this.email})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Settings',
          style: jerseyStyle(24, darkMaroon),
        ),
        backgroundColor: brightWhite,
        iconTheme: const IconThemeData(
            color: darkMaroon),
        elevation: 1,
      ),
      body: ListView(
        children: [
          ListTile(
            title: Text(
              'About',
              style: jerseyStyle(20, darkMaroon),
            ),
            leading:
                const Icon(Icons.info, color: darkMaroon),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title:
                      Text('About E-Fit', style: jerseyStyle(22, darkMaroon)),
                  content: Text(
                      'Version 1.0.0\nDeveloped by [Your Name/Company]',
                      style: jerseyStyle(16, darkMaroon)),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child:
                          Text('OK', style: jerseyStyle(18, darkMaroon)),
                    ),
                  ],
                ),
              );
            },
          ),
          ListTile(
            title: Text(
              'Notifications',
              style: jerseyStyle(20, darkMaroon),
            ),
            leading: const Icon(Icons.notifications,
                color: darkMaroon),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Notification settings not implemented yet.',
                      style: jerseyStyle(16, brightWhite)),
                  backgroundColor: darkMaroon,
                ),
              );
            },
          ),
          const Divider(),
          ListTile(
            title: Text(
              'Change Password',
              style: jerseyStyle(20, darkMaroon),
            ),
            leading: const Icon(Icons.lock_reset,
                color: Colors.black54),
            onTap: () => changePassword(context, email),
          ),
          ListTile(
            title: Text(
              'Delete Account',
              style: jerseyStyle(20, errorRed),
            ),
            leading: const Icon(Icons.delete,
                color: errorRed),
            onTap: () => deleteAccount(context, email),
          ),
        ],
      ),
    );
  }
}
