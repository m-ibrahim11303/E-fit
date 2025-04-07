import 'package:flutter/material.dart';

// list of items selected
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

// Explicitly declared JSON data
const Map<String, dynamic> eateriesData = {
  "number of eateries": 2,
  "eateries": [
    {
      "name": "Green olive",
      "number of dishes": 2,
      "dishes": [
        {
          "name": "Dish 1",
          "calories": 400,
          "protein": 30,
          "description": "Very tasty very great"
        },
        {
          "name": "Dish 2",
          "calories": 300,
          "protein": 20,
          "description": "Very tasty very great"
        }
      ]
    },
    {
      "name": "PDC",
      "number of dishes": 1,
      "dishes": [
        {
          "name": "Dish 1",
          "calories": 400,
          "protein": 30,
          "description": "Very tasty very great"
        }
      ]
    }
  ]
};

// Meal Log Screen
class MealLogScreen extends StatefulWidget {
  @override
  _MealLogScreenState createState() => _MealLogScreenState();
}

class _MealLogScreenState extends State<MealLogScreen> {
  List<SelectedMealItem> selectedItems = [];

  void _addSelectedItem(Map<String, dynamic> itemData) {
    final newItem = SelectedMealItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: itemData['name'],
      calories: itemData['calories'],
      protein: itemData['protein'],
    );
    setState(() {
      selectedItems.add(newItem);
    });
  }

  void _removeItem(String id) {
    setState(() {
      selectedItems.removeWhere((item) => item.id == id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<dynamic> eateries = eateriesData['eateries'];

    return Scaffold(
      appBar: AppBar(
        title: Text('Log Meal'),
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20,
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(color: Color(0xFF562634)),
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
            children: [
              Expanded(
                child: ListView(
                  children: [
                    _MealOptionCard(
                      title: 'Custom',
                      color: Color(0xFF562634),
                      onTap: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => CustomMealScreen()),
                        );
                        if (result != null) {
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
                            color: Color(0xFF562634),
                            onTap: () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => EateryMealScreen(eatery: eatery),
                                ),
                              );
                              if (result != null) {
                                _addSelectedItem(result);
                              }
                            },
                          ),
                          SizedBox(height: 20),
                        ],
                      );
                    }),
                    SizedBox(height: 20),
                    if (selectedItems.isNotEmpty) ...[
                      Text(
                        'Selected Items:',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 10),
                      ...selectedItems.map((item) => ListTile(
                            title: Text(item.name),
                            subtitle: Text('${item.calories} kcal • ${item.protein}g protein'),
                            trailing: IconButton(
                              icon: Icon(Icons.close, color: Colors.red),
                              onPressed: () => _removeItem(item.id),
                            ),
                          )).toList(),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF562634),
                          padding: EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        onPressed: () {
                          double totalCalories = selectedItems.fold(0, (sum, item) => sum + item.calories);
                          double totalProtein = selectedItems.fold(0, (sum, item) => sum + item.protein);
                          Navigator.pop(context, {
                            'calories': totalCalories,
                            'protein': totalProtein
                          });
                          // insert post call to backend here
                        },
                        child: Text('Save All Items', style: TextStyle(color: Colors.white)),
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

// Generic Eatery Meal Screen
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
              onPressed: () {
                final selectedDish = dishes[_selectedIndex!];
                Navigator.pop(context, {
                  'name': selectedDish['name'],
                  'calories': selectedDish['calories'],
                  'protein': selectedDish['protein'],
                });
              },
              backgroundColor: Color(0xFF562634),
              child: Icon(Icons.check, color: Colors.white),
            )
          : null,
      appBar: AppBar(
        title: Text(widget.eatery['name']),
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20,
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration( color: Color(0xFF562634),
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
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.red.shade900,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        dish['description'],
                        style: TextStyle(fontSize: 14, color: Colors.grey[700]),
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
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
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
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // Meal Name Input
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
                // Calories Input
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
                // Protein Input
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
                // Save Button
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF562634),
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  onPressed: _saveMeal,
                  child: Text(
                    'Save Meal',
                    style: TextStyle(fontSize: 18, color: Colors.white),
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