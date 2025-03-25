class BMICalculator {
  /// Calculates Basal Metabolic Rate (BMR) based on age, gender, weight, and height.
  /// Uses Schofield Equation for ages 10-17 and Mifflin-St Jeor Equation for 18-70.
  static double calculateBMR(int age, String gender, double weight, double height) {
    double bmr;

    if (age >= 10 && age <= 17) {
      // Schofield Equation
      if (gender.toLowerCase() == 'male') {
        bmr = 16.6 * weight + 77;
      } else if (gender.toLowerCase() == 'female') {
        bmr = 7.4 * weight + 482;
      } else {
        throw ArgumentError('Invalid gender: must be "male" or "female"');
      }
    } else if (age >= 18 && age <= 70) {
      // Mifflin-St Jeor Equation
      if (gender.toLowerCase() == 'male') {
        bmr = 10 * weight + 6.25 * height - 5 * age + 5;
      } else if (gender.toLowerCase() == 'female') {
        bmr = 10 * weight + 6.25 * height - 5 * age - 161;
      } else {
        throw ArgumentError('Invalid gender: must be "male" or "female"');
      }
    } else {
      throw ArgumentError('Age out of range (must be between 10 and 70 years)');
    }

    return bmr;
  }

  /// Calculates Total Daily Energy Expenditure (TDEE) using BMR and activity level.
  static double calculateTDEE(double bmr, String activityLevel) {
    final Map<String, double> activityMultipliers = {
      'sedentary': 1.2,
      'lightly_active': 1.375,
      'moderately_active': 1.55,
      'very_active': 1.725,
      'super_active': 1.9
    };

    if (!activityMultipliers.containsKey(activityLevel.toLowerCase())) {
      throw ArgumentError('Invalid activity level');
    }

    return (bmr * activityMultipliers[activityLevel.toLowerCase()]).roundToDouble();
  }
}
