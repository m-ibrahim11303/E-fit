import 'package:flutter/material.dart';
import 'package:login_signup_1/style.dart';

class EateryMealScreen extends StatefulWidget {
  final Map<String, dynamic> eatery;

  const EateryMealScreen({required this.eatery});

  @override
  _EateryMealScreenState createState() => _EateryMealScreenState();
}

class _EateryMealScreenState extends State<EateryMealScreen> {
  int? _selectedIndex;

  @override
  Widget build(BuildContext context) {
    final List<dynamic> dishes = widget.eatery['dishes'];

    return Scaffold(
      floatingActionButton: _selectedIndex != null
          ? FloatingActionButton(
            key: Key("add_dish_button"),
              onPressed: () {
                final selectedDish = dishes[_selectedIndex!];
                Navigator.pop(context, {
                  'name': selectedDish['name'],
                  'calories': selectedDish['calories'],
                  'protein': selectedDish['protein'],
                });
              },
              backgroundColor: darkMaroon,
              child: Icon(Icons.check, color: brightWhite),
            )
          : null,
      appBar: AppBar(
        title: Text(widget.eatery['name']),
        titleTextStyle: TextStyle(
          color: brightWhite,
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
        child: ListView.builder(
          padding: EdgeInsets.all(16),
          itemCount: dishes.length,
          itemBuilder: (context, index) {
            final dish = dishes[index];
            return Card(
              elevation: 4,
              margin: EdgeInsets.symmetric(vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              color: _selectedIndex == index ? Colors.red[50] : Colors.white,
              child: InkWell(
                borderRadius: BorderRadius.circular(15),
                onTap: () {
                  setState(() {
                    _selectedIndex = index;
                  });
                },
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        dish['name'],
                        style: TextStyle(
                          fontFamily: "Jersey 25",
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.red.shade900,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        dish['description'],
                        style: TextStyle(fontFamily: "Jersey 25", fontSize: 14, color: Colors.grey[700]),
                      ),
                      SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(Icons.local_fire_department,
                              size: 16, color: Colors.orange),
                          SizedBox(width: 4),
                          Text(
                            '${dish['calories']} kcal',
                            style: TextStyle(
                              fontFamily: "Jersey 25",
                              fontSize: 14,
                              color: Colors.grey[800],
                            ),
                          ),
                          SizedBox(width: 16),
                          Icon(Icons.fitness_center,
                              size: 16, color: Colors.green),
                          SizedBox(width: 4),
                          Text(
                            '${dish['protein']} g protein',
                            style: TextStyle(
                              fontFamily: "Jersey 25",
                              fontSize: 14,
                              color: Colors.grey[800],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class CustomMealScreen extends StatefulWidget {
  @override
  _CustomMealScreenState createState() => _CustomMealScreenState();
}

class _CustomMealScreenState extends State<CustomMealScreen> {
  final _formKey = GlobalKey<FormState>();
  final _mealNameController = TextEditingController();
  final _caloriesController = TextEditingController();
  final _proteinController = TextEditingController();

  @override
  void dispose() {
    _mealNameController.dispose();
    _caloriesController.dispose();
    _proteinController.dispose();
    super.dispose();
  }

  void _saveMeal() {
    if (_formKey.currentState!.validate()) {
      final mealData = {
        'name': _mealNameController.text,
        'calories': int.parse(_caloriesController.text),
        'protein': int.parse(_proteinController.text),
      };

      Navigator.pop(context, mealData);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${mealData['name']} saved!'),
          backgroundColor: Colors.green,
        ),
      );

      _mealNameController.clear();
      _caloriesController.clear();
      _proteinController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Custom Meal'),
        titleTextStyle: jerseyStyle(20, brightWhite),
        // titleTextStyle: TextStyle(
        //   color: Colors.white,
        //   fontSize: 20,
        // ),
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
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _mealNameController,
                  decoration: InputDecoration(
                    labelText: 'Meal Name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    prefixIcon: Icon(
                      Icons.fastfood,
                      color: Colors.red.shade800,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a meal name';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                TextFormField(
                  controller: _caloriesController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Calories (kcal)',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    prefixIcon: Icon(
                      Icons.local_fire_department,
                      color: Colors.orange.shade800,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter calories';
                    }
                    if (int.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                TextFormField(
                  controller: _proteinController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Protein (g)',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    prefixIcon: Icon(
                      Icons.fitness_center,
                      color: Colors.green.shade800,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter protein';
                    }
                    if (int.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 30),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: darkMaroon,
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  onPressed: _saveMeal,
                  child: Text(
                    'Save Meal',
                    style: jerseyStyle(18, brightWhite),
                    // style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}