import 'package:get_it/get_it.dart';
import 'package:roadify_app/core/database/app_database.dart';
import 'package:roadify_app/core/database/daos/run_dao.dart';
import 'package:roadify_app/core/database/daos/vehicle_dao.dart';
import 'package:roadify_app/core/session/session_lifecycle_orchestrator.dart';
import 'package:roadify_app/features/dados/services/run_export_service.dart';
import 'package:roadify_app/features/veiculos/viewmodels/vehicle_viewmodel.dart';

// Instância global do GetIt
final getIt = GetIt.instance;

void setupLocators({AppDatabase? database}) {
  // Registra o banco de dados como LazySingleton (criado uma única vez e mantido na memória)
  if (!getIt.isRegistered<AppDatabase>()) {
    getIt.registerLazySingleton<AppDatabase>(() => database ?? AppDatabase());
  }

  // Registra os DAOs para os ViewModels consumirem
  if (!getIt.isRegistered<VehicleDao>()) {
    getIt.registerLazySingleton<VehicleDao>(
      () => getIt<AppDatabase>().vehicleDao,
    );
  }

  if (!getIt.isRegistered<RunDao>()) {
    getIt.registerLazySingleton<RunDao>(() => getIt<AppDatabase>().runDao);
  }

  if (!getIt.isRegistered<RunExportService>()) {
    getIt.registerLazySingleton<RunExportService>(
      () => RunExportService(getIt<AppDatabase>()),
    );
  }

  if (!getIt.isRegistered<VehicleViewModel>()) {
    getIt.registerLazySingleton<VehicleViewModel>(
      () => VehicleViewModel(getIt<VehicleDao>()),
    );
  }

  if (!getIt.isRegistered<SessionLifecycleOrchestrator>()) {
    getIt.registerLazySingleton<SessionLifecycleOrchestrator>(
      () => SessionLifecycleOrchestrator(
        runsStream: getIt<RunDao>().watchAllRuns(),
      ),
    );
  }
}
