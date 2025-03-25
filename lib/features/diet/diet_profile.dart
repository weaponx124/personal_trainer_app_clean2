class DietProfile {
  final String name;
  final double proteinPercentage; // % of daily calories
  final double carbsPercentage;
  final double fatPercentage;
  final int defaultCalories;
  final String scripture;

  DietProfile({
    required this.name,
    required this.proteinPercentage,
    required this.carbsPercentage,
    required this.fatPercentage,
    this.defaultCalories = 2000,
    required this.scripture,
  });

  // Convert percentages to grams based on provided calories
  double proteinGrams(int calories) => (proteinPercentage / 100 * calories) / 4; // 4 cal/g for protein
  double carbsGrams(int calories) => (carbsPercentage / 100 * calories) / 4; // 4 cal/g for carbs
  double fatGrams(int calories) => (fatPercentage / 100 * calories) / 9; // 9 cal/g for fat

  static final List<DietProfile> profiles = [
    DietProfile(
      name: 'Balanced',
      proteinPercentage: 30,
      carbsPercentage: 40,
      fatPercentage: 30,
      scripture: '1 Corinthians 10:31 - "So whether you eat or drink or whatever you do, do it all for the glory of God."',
    ),
    DietProfile(
      name: 'Keto',
      proteinPercentage: 25,
      carbsPercentage: 5,
      fatPercentage: 70,
      scripture: 'Matthew 6:16 - "When you fast, do not look somber as the hypocrites do, for they disfigure their faces..."',
    ),
    DietProfile(
      name: 'Vegan',
      proteinPercentage: 25,
      carbsPercentage: 55,
      fatPercentage: 20,
      scripture: 'Genesis 1:29 - "Then God said, ‘I give you every seed-bearing plant on the face of the whole earth...’"',
    ),
    DietProfile(
      name: 'Carnivore',
      proteinPercentage: 40,
      carbsPercentage: 0,
      fatPercentage: 60,
      scripture: 'Genesis 9:3 - "Everything that lives and moves about will be food for you..."',
    ),
    DietProfile(
      name: 'Bulk',
      proteinPercentage: 35,
      carbsPercentage: 45,
      fatPercentage: 20,
      defaultCalories: 2500,
      scripture: 'Philippians 4:13 - "I can do all this through him who gives me strength."',
    ),
    DietProfile(
      name: 'Cut',
      proteinPercentage: 40,
      carbsPercentage: 30,
      fatPercentage: 30,
      defaultCalories: 1800,
      scripture: '1 Corinthians 9:27 - "I discipline my body and keep it under control..."',
    ),
  ];
}