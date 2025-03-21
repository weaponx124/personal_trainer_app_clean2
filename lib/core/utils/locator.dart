import 'package:get_it/get_it.dart';
import 'package:personal_trainer_app_clean/screens/program_details_logic.dart';

final GetIt locator = GetIt.instance;

void setupLocator() {
  locator.registerLazySingleton<ProgramDetailsLogic>(() => ProgramDetailsLogic());
}