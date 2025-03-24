import 'package:get_it/get_it.dart';
import 'package:personal_trainer_app_clean/core/data/repositories/program_repository.dart';
import 'package:personal_trainer_app_clean/core/data/repositories/workout_repository.dart';
import 'package:personal_trainer_app_clean/core/data/repositories/meal_repository.dart';
import 'package:personal_trainer_app_clean/core/services/database_service.dart';
import 'package:personal_trainer_app_clean/core/services/network_service.dart';

final GetIt getIt = GetIt.instance;

void setupLocator() {
  print('Locator: Setting up dependency injection...');

  // Register services
  getIt.registerLazySingleton<DatabaseService>(() => DatabaseService());
  getIt.registerLazySingleton<NetworkService>(() => NetworkService());

  // Register repositories
  getIt.registerLazySingleton<ProgramRepository>(() => ProgramRepository());
  getIt.registerLazySingleton<WorkoutRepository>(() => WorkoutRepository());
  getIt.registerLazySingleton<MealRepository>(() => MealRepository());

  print('Locator: Dependency injection setup completed.');
}