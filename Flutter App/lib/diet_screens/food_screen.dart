import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:login_signup_1/analytics_screens/analytics_test.dart';
import 'package:login_signup_1/style.dart';
import 'food_models_services.dart';
import 'food_details_screen.dart';

class MealLogScreen extends StatefulWidget {
  @override
  _MealLogScreenState createState() => _MealLogScreenState();
}

class _MealLogScreenState extends State<MealLogScreen> {
  List<SelectedMealItem> selectedItems = [];
  List<dynamic> eateries = [];
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _loadEateries();
  }

  Future<void> _loadEateries() async {
    try {
      final data = await FoodService.getEateries();
      if (mounted) {
        setState(() {
          eateries = data['eateries'];
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          error = e.toString();
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load eateries: $e')),
        );
      }
    }
  }

  void _addSelectedItem(Map<String, dynamic> itemData) {
    final newItem = SelectedMealItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: itemData['name'],
      calories: itemData['calories'],
      protein: itemData['protein'],
    );
    if (mounted) {
      setState(() {
        selectedItems.add(newItem);
      });
    }
  }

  void _removeItem(String id) {
    if (mounted) {
      setState(() {
        selectedItems.removeWhere((item) => item.id == id);
      });
    }
  }

  Future<void> _saveMeal() async {
    if (mounted) {
      setState(() => isLoading = true);
    }
    try {
      final storage = FlutterSecureStorage();
      final userEmail = await storage.read(key: 'email');

      if (userEmail == null) {
        throw Exception('No user email found in secure storage');
      }

      await FoodService.saveMeal(selectedItems, userEmail);

      double totalCalories =
          selectedItems.fold(0, (sum, item) => sum + item.calories);
      double totalProtein =
          selectedItems.fold(0, (sum, item) => sum + item.protein);

      if (mounted) {
        Navigator.pop(context, {
          'calories': totalCalories,
          'protein': totalProtein,
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save meal: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Log Meal'),
        // titleTextStyle: jerseyStyle(20, brightWhite),
        titleTextStyle: TextStyle(
          fontFamily: "Jersey 25",
          color: Colors.white,
          fontSize: 20,
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(color: darkMaroon),
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
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : error != null
                ? Center(child: Text(error!))
                : Padding(
                    padding: EdgeInsets.all(24),
                    child: Column(
                      children: [
                        Expanded(
                          child: ListView(
                            children: [
                              _MealOptionCard(
                                title: 'Custom',
                                color: darkMaroon,
                                onTap: () async {
                                  final result = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) => CustomMealScreen()),
                                  );
                                  if (result != null && mounted) {
                                    _addSelectedItem(result);
                                  }
                                },
                              ),
                              SizedBox(height: 20),
                              ...List.generate(eateries.length, (index) {
                                final eatery = eateries[index];
                                return Column(
                                  children: [
                                    _MealOptionCard(
                                      title: eatery['name'],
                                      color: darkMaroon,
                                      onTap: () async {
                                        final result = await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => EateryMealScreen(
                                                eatery: eatery),
                                          ),
                                        );
                                        if (result != null && mounted) {
                                          _addSelectedItem(result);
                                        }
                                      },
                                    ),
                                    SizedBox(height: 20),
                                  ],
                                );
                              }),
                              if (selectedItems.isNotEmpty) ...[
                                Text(
                                  'Selected Items:',
                                  style: TextStyle(
                                    fontFamily: "Jersey 25",
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                                SizedBox(height: 10),
                                ...selectedItems
                                    .map((item) => ListTile(
                                          title: Text(item.name),
                                          subtitle: Text(
                                              '${item.calories} kcal • ${item.protein}g protein'),
                                          trailing: IconButton(
                                            icon: Icon(Icons.close,
                                                color: errorRed),
                                            onPressed: () =>
                                                _removeItem(item.id),
                                          ),
                                        ))
                                    .toList(),
                                SizedBox(height: 20),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: darkMaroon,
                                    padding: EdgeInsets.symmetric(vertical: 15),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                  ),
                                  onPressed: _saveMeal,
                                  child: Text(
                                    'Save All Items',
                                    // style: jerseyStyle(brightWhite)
                                    style: TextStyle(color: Colors.white, fontFamily: "Jersey 25"),
                                  ),
                                ),
                              ],
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

class _MealOptionCard extends StatelessWidget {
  final String title;
  final Color color;
  final VoidCallback onTap;

  const _MealOptionCard({
    required this.title,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: color.withOpacity(0.9),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                fontFamily: "Jersey 25",
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: brightWhite,
              ),
            ),
          ),
        ),
      ),
    );
  }
}