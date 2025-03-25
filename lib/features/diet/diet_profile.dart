class DietProfile {
  final String name;
  final double proteinPercentage; // % of daily calories
  final double carbsPercentage;
  final double fatPercentage;
  final int dailyCalories; // Default, adjustable later

  DietProfile({
    required this.name,
    required this.proteinPercentage,
    required this.carbsPercentage,
    required this.fatPercentage,
    this.dailyCalories = 2000, // Typical default
  });

  // Convert percentages to grams based on daily calories (1g protein/carb = 4 cal, 1g fat = 9 cal)
  double get proteinGrams => (proteinPercentage / 100 * dailyCalories) / 4;
  double get carbsGrams => (carbsPercentage / 100 * dailyCalories) / 4;
  double get fatGrams => (fatPercentage / 100 * dailyCalories) / 9;

  static final List<DietProfile> profiles = [
    DietProfile(name: 'Balanced', proteinPercentage: 30, carbsPercentage: 40, fatPercentage: 30),
    DietProfile(name: 'Keto', proteinPercentage: 25, carbsPercentage: 5, fatPercentage: 70),
    DietProfile(name: 'Vegan', proteinPercentage: 25, carbsPercentage: 55, fatPercentage: 20),
    DietProfile(name: 'Carnivore', proteinPercentage: 40, carbsPercentage: 0, fatPercentage: 60),
    DietProfile(name: 'Bulk', proteinPercentage: 35, carbsPercentage: 45, fatPercentage: 20, dailyCalories: 2500),
    DietProfile(name: 'Cut', proteinPercentage: 40, carbsPercentage: 30, fatPercentage: 30, dailyCalories: 1800),
  ];
}