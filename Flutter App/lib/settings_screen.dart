import 'package:flutter/material.dart';

// Settings Screen
class SettingsScreen extends StatelessWidget {
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
        ],
      ),
    );
  }
}
