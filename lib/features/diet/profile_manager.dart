import 'package:shared_preferences/shared_preferences.dart';
import 'package:personal_trainer_app_clean/features/diet/diet_profile.dart';
import 'package:personal_trainer_app_clean/features/diet/diet_state_manager.dart';

class ProfileManager {
  final DietStateManager _stateManager;

  ProfileManager(this._stateManager);

  Future<void> loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    print('Prefs loaded');
    _stateManager.customCalories = prefs.getInt('customCalories');
    final profileName = prefs.getString('profileName');
    print('Loaded profileName: $profileName, customCalories: ${_stateManager.customCalories}');
    if (profileName != null) {
      final profile = DietProfile.profiles.firstWhere(
            (p) => p.name == profileName,
        orElse: () => DietProfile.profiles[0],
      );
      final customProtein = prefs.getDouble('customProtein');
      final customCarbs = prefs.getDouble('customCarbs');
      final customFat = prefs.getDouble('customFat');
      if (profileName == 'Custom' &&
          customProtein != null &&
          customCarbs != null &&
          customFat != null) {
        _stateManager.dietProfile.value = DietProfile(
          name: 'Custom',
          proteinPercentage: customProtein,
          carbsPercentage: customCarbs,
          fatPercentage: customFat,
          defaultCalories: _stateManager.customCalories ?? 2000,
          scripture: 'Proverbs 16:3 - "Commit to the Lord whatever you do, and he will establish your plans."',
        );
      } else {
        _stateManager.dietProfile.value = profile;
      }
    }

    final savedMealNames = prefs.getStringList('mealNames');
    if (savedMealNames != null && savedMealNames.isNotEmpty) {
      _stateManager.mealNames.value = savedMealNames;
      print('Loaded mealNames: ${_stateManager.mealNames.value}');
    } else {
      _stateManager.mealNames.value = ['Breakfast', 'Lunch', 'Dinner'];
      await prefs.setStringList('mealNames', _stateManager.mealNames.value);
      print('Initialized default mealNames: ${_stateManager.mealNames.value}');
    }
    _stateManager.selectedMealType = _stateManager.mealNames.value[0];

    if (_stateManager.customCalories != null) {
      print('Applied customCalories: ${_stateManager.customCalories}');
    } else {
      print('No customCalories found, using default: ${_stateManager.dietProfile.value.defaultCalories}');
    }
  }

  Future<void> setDietProfile(DietProfile profile, int customCalories) async {
    _stateManager.dietProfile.value = profile;
    _stateManager.customCalories = customCalories;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('customCalories', customCalories);
    await prefs.setString('profileName', profile.name);
    if (profile.name == 'Custom') {
      await prefs.setDouble('customProtein', profile.proteinPercentage);
      await prefs.setDouble('customCarbs', profile.carbsPercentage);
      await prefs.setDouble('customFat', profile.fatPercentage);
    } else {
      await prefs.remove('customProtein');
      await prefs.remove('customCarbs');
      await prefs.remove('customFat');
    }
    print('Saved: customCalories=$customCalories, profileName=${profile.name}');
  }

  Future<void> setMealNames(List<String> names) async {
    print('ProfileManager: Setting meal names to $names');
    _stateManager.mealNames.value = names.isNotEmpty ? names : ['Meal 1'];
    _stateManager.selectedMealType = _stateManager.mealNames.value[0];
    final prefs = await SharedPreferences.getInstance();
    bool success = await prefs.setStringList('mealNames', _stateManager.mealNames.value);
    if (success) {
      print('ProfileManager: Successfully saved mealNames to SharedPreferences: ${_stateManager.mealNames.value}');
    } else {
      print('ProfileManager: Failed to save mealNames to SharedPreferences');
    }
  }
}