import 'package:flutter/material.dart';

// Diet screen

class DietScreen extends StatefulWidget {
  @override
  _DietScreenState createState() => _DietScreenState();
}

class _DietScreenState extends State<DietScreen> {
  double waterIntake = 500; // in ml
  double proteinIntake = 100; // in grams
  double caloriesIntake = 2000; // in kcal

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Diet Tracker'),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.red.shade900, Colors.yellow.shade800],
            ),
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
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Daily Intake Summary
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
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
                    _IntakeStat(
                      icon: Icons.water_drop,
                      value: waterIntake,
                      unit: 'ml',
                      label: 'Water Intake',
                      color: Colors.blue[200]!,
                    ),
                    Divider(height: 30),
                    _IntakeStat(
                      icon: Icons.fitness_center,
                      value: proteinIntake,
                      unit: 'g',
                      label: 'Protein Intake',
                      color: Colors.green[400]!,
                    ),
                    Divider(height: 30),
                    _IntakeStat(
                      icon: Icons.local_fire_department,
                      value: caloriesIntake,
                      unit: 'kcal',
                      label: 'Calories',
                      color: Colors.orange[400]!,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 30),
              // Logging Buttons
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _DietButton(
                      icon: Icons.restaurant,
                      label: 'Log Meal',
                      gradient: LinearGradient(
                        colors: [Colors.red[700]!, Colors.orange[700]!],
                      ),
                      onPressed: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => MealLogScreen()),
                        );
                        if (result != null) {
                          setState(() {
                            caloriesIntake += result['calories'];
                            proteinIntake += result['protein'];
                          });
                        }
                      },
                    ),
                    SizedBox(height: 30),
                    _DietButton(
                      icon: Icons.local_drink,
                      label: 'Log Drink',
                      gradient: LinearGradient(
                        colors: [Colors.amber[600]!, Colors.orange[700]!],
                      ),
                      onPressed: () async {
                        final water = await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => DrinkLogScreen()),
                        );
                        if (water != null) {
                          setState(() {
                            waterIntake += water;
                          });
                        }
                      },
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

class _IntakeStat extends StatelessWidget {
  final IconData icon;
  final double value;
  final String unit;
  final String label;
  final Color color;

  const _IntakeStat({
    required this.icon,
    required this.value,
    required this.unit,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 32, color: color),
        SizedBox(width: 15),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            Text(
              '${value.toStringAsFixed(0)}$unit',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// Add this widget class in the same file (outside DietScreen class)
class _DietButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Gradient gradient;
  final VoidCallback onPressed;

  const _DietButton({
    required this.icon,
    required this.label,
    required this.gradient,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 4,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: gradient,
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onPressed,
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 20, horizontal: 30),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 32, color: Colors.white),
                SizedBox(width: 15),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
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

// Meal Log Screen
class MealLogScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Log Meal'),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.red[800]!, Colors.amber[600]!],
            ),
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
            children: [
              _MealOptionCard(
                title: 'Custom',
                color: Colors.red[400]!,
                onTap:
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => CustomMealScreen()),
                    ),
              ),
              SizedBox(height: 20),
              _MealOptionCard(
                title: 'Baradari',
                color: Colors.orange[400]!,
                onTap:
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => BaradariMealScreen()),
                    ),
              ),
              SizedBox(height: 20),
              _MealOptionCard(
                title: 'Jammin',
                color: Colors.amber[400]!,
                onTap:
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => JamminMealScreen()),
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

// Drink Log Screen
class DrinkLogScreen extends StatelessWidget {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Log Water Intake'),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.red[800]!, Colors.amber[600]!],
            ),
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
                          Navigator.pop(context, water);
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
      // Save the meal data (you can add your logic here)
      final mealName = _mealNameController.text;
      final calories = int.parse(_caloriesController.text);
      final protein = int.parse(_proteinController.text);

      // Show a success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '$mealName saved! Calories: $calories, Protein: $protein g',
          ),
          backgroundColor: Colors.green,
        ),
      );

      // Clear the form
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
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.red.shade900, Colors.yellow.shade800],
            ),
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
                    backgroundColor: Colors.red.shade800,
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

class BaradariMealScreen extends StatefulWidget {
  @override
  _BaradariMealScreenState createState() => _BaradariMealScreenState();
}

class _BaradariMealScreenState extends State<BaradariMealScreen> {
  int? _selectedIndex;

  final List<Map<String, dynamic>> _menuItems = [
    {
      'name': 'Grilled Chicken',
      'calories': 350,
      'protein': 40,
      'description': 'Juicy grilled chicken breast with herbs.',
    },
    {
      'name': 'Vegetable Stir Fry',
      'calories': 250,
      'protein': 10,
      'description': 'Fresh vegetables stir-fried in olive oil.',
    },
    {
      'name': 'Salmon Fillet',
      'calories': 400,
      'protein': 35,
      'description': 'Pan-seared salmon with lemon butter sauce.',
    },
    {
      'name': 'Quinoa Salad',
      'calories': 300,
      'protein': 12,
      'description': 'Healthy quinoa with mixed greens and vinaigrette.',
    },
    {
      'name': 'Beef Steak',
      'calories': 500,
      'protein': 45,
      'description': 'Grilled beef steak with garlic butter.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Baradari Meals'),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.red.shade900, Colors.yellow.shade800],
            ),
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
          itemCount: _menuItems.length,
          itemBuilder: (context, index) {
            final item = _menuItems[index];
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
                  // You can add additional logic here, like saving the selected meal
                },
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['name'],
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.red.shade900,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        item['description'],
                        style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                      ),
                      SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(
                            Icons.local_fire_department,
                            size: 16,
                            color: Colors.orange,
                          ),
                          SizedBox(width: 4),
                          Text(
                            '${item['calories']} kcal',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[800],
                            ),
                          ),
                          SizedBox(width: 16),
                          Icon(
                            Icons.fitness_center,
                            size: 16,
                            color: Colors.green,
                          ),
                          SizedBox(width: 4),
                          Text(
                            '${item['protein']} g protein',
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
      floatingActionButton:
          _selectedIndex != null
              ? FloatingActionButton(
                onPressed: () {
                  final selectedItem = _menuItems[_selectedIndex!];
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Selected: ${selectedItem['name']}'),
                      backgroundColor: Colors.green,
                    ),
                  );
                },
                backgroundColor: Colors.red.shade800,
                child: Icon(Icons.check, color: Colors.white),
              )
              : null,
    );
  }
}

class JamminMealScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      Scaffold(appBar: AppBar(title: Text('Jammin Meals')));
}

// Analytics Screen
class AnalyticsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Analytics')),
      body: ListView(
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: Text('Step Counter Chart (Placeholder)'),
          ),
          ListTile(
            title: Text('Past Exercise Intensity'),
            subtitle: Text('Last 7 days: High Intensity'),
          ),
          ListTile(
            title: Text('Calorie Intake'),
            subtitle: Text('Average: 2000 kcal/day'),
          ),
        ],
      ),
    );
  }
}
