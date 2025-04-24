import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class DrinkLogScreen extends StatelessWidget {
  final TextEditingController _controller = TextEditingController();
  final FlutterSecureStorage storage = FlutterSecureStorage();

  Future<void> logWater(BuildContext context, double amount) async {
    try {
      // Get user email from secure storage
      final userEmail = await storage.read(key: 'email');

      if (userEmail == null) {
        // Handle case where the email is not found in secure storage
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('User email not found. Please log in again.')),
        );
        return;
      }

      // Define the API endpoint
      const url = 'https://e-fit-backend.onrender.com/user/logwater';

      // Create the request body
      final body = jsonEncode({
        'email': userEmail,
        'amount': amount,
      });

      // Send POST request to the backend
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (response.statusCode == 200) {
        // If the request is successful, show a success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Water intake saved!')),
        );
        Navigator.pop(context, amount); // Go back with the logged water amount
      } else {
        // If the request fails, show an error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save water intake. Try again.')),
        );
      }
    } catch (error) {
      // Handle any errors that occur during the request
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
          color: Colors.white,
          fontSize: 20,
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            color: Color(0xFF562634),
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
                  color: Colors.white,
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
                          logWater(context, water); // Call the logWater method
                        }
                      },
                      child: Text(
                        'Save Intake',
                        style: TextStyle(fontSize: 16),
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
