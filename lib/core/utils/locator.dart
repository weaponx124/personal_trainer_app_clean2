import 'package:get_it/get_it.dart';
import 'package:personal_trainer_app_clean/core/data/repositories/program_repository.dart';
import 'package:personal_trainer_app_clean/core/data/repositories/settings_repository.dart';
import 'package:personal_trainer_app_clean/core/data/repositories/verse_of_the_day_repository.dart';

final GetIt locator = GetIt.instance;

void setupLocator() {
  locator.registerLazySingleton<ProgramRepository>(() => ProgramRepository());
  locator.registerLazySingleton<SettingsRepository>(() => SettingsRepository());
  locator.registerLazySingleton<VerseOfTheDayRepository>(() => VerseOfTheDayRepository());
}