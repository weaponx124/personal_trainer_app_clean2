import 'package:get_it/get_it.dart';
import '../../screens/program_details_logic.dart';

final GetIt locator = GetIt.instance;

void setupLocator() {
  locator.registerFactoryParam<ProgramDetailsLogic, String, String>(
        (param1, param2) => ProgramDetailsLogic(
      programId: param1,
      unit: param2,
      onSessionInitialized: (sets, controllers, completed, workout) {},
    ),
  );
}