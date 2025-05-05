import 'package:http/http.dart' as http;
import 'dart:convert';

class SelectedMealItem {
  final String id;
  final String name;
  final int calories;
  final int protein;

  SelectedMealItem({
    required this.id,
    required this.name,
    required this.calories,
    required this.protein,
  });
}

class FoodService {
  static const String baseUrl = 'https://e-fit-backend.onrender.com';

  static Future<Map<String, dynamic>> getEateries() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/dish/all'),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load eateries: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  static Future<void> saveMeal(
      List<SelectedMealItem> items, String email) async {
    final response = await http.post(
      Uri.parse('$baseUrl/user/savemeals'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'items': items
            .map((item) => {
                  'name': item.name,
                  'calories': item.calories,
                  'protein': item.protein,
                })
            .toList(),
      }),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to save meal: ${response.body}');
    }
  }
}