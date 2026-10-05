import 'package:get_it/get_it.dart';
import 'package:roadify_app/core/database/app_database.dart';
import 'package:roadify_app/core/database/daos/run_dao.dart';
import 'package:roadify_app/core/database/daos/vehicle_dao.dart';
import 'package:roadify_app/features/veiculos/viewmodels/vehicle_viewmodel.dart';

// Instância global do GetIt
final getIt = GetIt.instance;

void setupLocators() {
  // Registra o banco de dados como LazySingleton (criado uma única vez e mantido na memória)
  getIt.registerLazySingleton<AppDatabase>(() => AppDatabase());

  // Registra os DAOs para os ViewModels consumirem
  getIt.registerLazySingleton<VehicleDao>(
    () => getIt<AppDatabase>().vehicleDao,
  );

  getIt.registerLazySingleton<RunDao>(
    () => getIt<AppDatabase>().runDao,
  );

  getIt.registerLazySingleton<VehicleViewModel>(
    () => VehicleViewModel(getIt<VehicleDao>()),
  );
}
