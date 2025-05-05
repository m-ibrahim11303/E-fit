import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:login_signup_1/style.dart';

class DrinkLogScreen extends StatelessWidget {
  final TextEditingController _controller = TextEditingController();
  final FlutterSecureStorage storage = FlutterSecureStorage();

  Future<void> logWater(BuildContext context, double amount) async {
    try {
      final userEmail = await storage.read(key: 'email');

      if (userEmail == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('User email not found. Please log in again.')),
        );
        return;
      }

      const url = 'https://e-fit-backend.onrender.com/user/logwater';

      final body = jsonEncode({
        'email': userEmail,
        'amount': amount,
      });

      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Water intake saved!')),
        );
        Navigator.pop(context, amount);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save water intake. Try again.')),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Log Water Intake'),
        titleTextStyle: TextStyle(
          fontFamily: "Jersey 25",
          color: brightWhite,
          fontSize: 20,
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            color: darkMaroon,
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.amber[50]!, Colors.red[50]!],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: brightWhite,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Icon(Icons.water_drop, size: 60, color: Colors.blue[200]),
                    SizedBox(height: 20),
                    TextField(
                      controller: _controller,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Water (ml)',
                        border: OutlineInputBorder(),
                        suffixText: 'ml',
                        prefixIcon: Icon(Icons.rotate_90_degrees_ccw),
                      ),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[200],
                        padding: EdgeInsets.symmetric(
                          horizontal: 40,
                          vertical: 15,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      onPressed: () {
                        if (_controller.text.isNotEmpty) {
                          final water = double.parse(_controller.text);
                          logWater(context, water);
                        }
                      },
                      child: Text(
                        'Save Intake',
                        style: TextStyle(fontFamily: "Jersey 25", fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
