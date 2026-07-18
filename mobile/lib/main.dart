import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'core/network/api_client.dart';
import 'core/router/app_router.dart';
import 'core/storage/token_storage.dart';
import 'features/auth/data/auth_repository.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/dashboard/data/dashboard_repository.dart';
import 'features/dashboard/providers/dashboard_provider.dart';
import 'features/maintenance/data/maintenance_repository.dart';
import 'features/maintenance/data/maintenance_type_repository.dart';
import 'features/maintenance/providers/maintenance_provider.dart';
import 'features/reminders/providers/reminders_provider.dart';
import 'features/vehicles/data/vehicle_repository.dart';
import 'features/vehicles/providers/vehicle_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  final tokenStorage = TokenStorage();
  final apiClient = ApiClient(tokenStorage);
  final authRepository = AuthRepository(
    apiClient: apiClient,
    tokenStorage: tokenStorage,
  );
  final vehicleRepository = VehicleRepository(apiClient);
  final maintenanceRepository = MaintenanceRepository(apiClient);
  final maintenanceTypeRepository = MaintenanceTypeRepository(apiClient);
  final dashboardRepository = DashboardRepository(apiClient);

  final authProvider = AuthProvider(authRepository);
  final router = createAppRouter(authProvider);

  runApp(
    MultiProvider(
      providers: [
        Provider<TokenStorage>.value(value: tokenStorage),
        Provider<ApiClient>.value(value: apiClient),
        Provider<AuthRepository>.value(value: authRepository),
        Provider<VehicleRepository>.value(value: vehicleRepository),
        Provider<MaintenanceRepository>.value(value: maintenanceRepository),
        Provider<MaintenanceTypeRepository>.value(value: maintenanceTypeRepository),
        Provider<DashboardRepository>.value(value: dashboardRepository),
        ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
        ChangeNotifierProvider(
          create: (_) => VehicleProvider(vehicleRepository),
        ),
        ChangeNotifierProvider(
          create: (_) => MaintenanceProvider(maintenanceRepository),
        ),
        ChangeNotifierProvider(
          create: (_) => DashboardProvider(dashboardRepository),
        ),
        ChangeNotifierProvider(
          create: (_) => RemindersProvider(
            vehicleRepository: vehicleRepository,
            maintenanceRepository: maintenanceRepository,
          ),
        ),
      ],
      child: CarCareApp(router: router),
    ),
  );
}
