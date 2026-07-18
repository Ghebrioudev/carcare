import 'package:go_router/go_router.dart';

import '../../features/auth/providers/auth_provider.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/auth/screens/splash_screen.dart';
import '../../features/dashboard/screens/dashboard_screen.dart';
import '../../features/maintenance/screens/maintenance_detail_screen.dart';
import '../../features/maintenance/screens/maintenance_form_screen.dart';
import '../../features/maintenance/screens/maintenance_list_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../../features/reminders/screens/reminders_screen.dart';
import '../../features/vehicles/screens/vehicle_detail_screen.dart';
import '../../features/vehicles/screens/vehicle_form_screen.dart';
import '../../features/vehicles/screens/vehicles_screen.dart';
import '../widgets/main_shell.dart';

GoRouter createAppRouter(AuthProvider authProvider) {
  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: authProvider,
    redirect: (context, state) {
      final location = state.matchedLocation;
      final isAuthRoute = location == '/login' || location == '/register';
      final isSplash = location == '/splash';

      if (authProvider.status == AuthStatus.unknown) {
        return isSplash ? null : '/splash';
      }

      if (authProvider.status == AuthStatus.unauthenticated) {
        return isAuthRoute ? null : '/login';
      }

      if (authProvider.status == AuthStatus.authenticated) {
        if (isAuthRoute || isSplash) {
          return '/home';
        }
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                builder: (context, state) => const DashboardScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/vehicles',
                builder: (context, state) => const VehiclesScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/reminders',
                builder: (context, state) => const RemindersScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/vehicles/new',
        builder: (context, state) => const VehicleFormScreen(),
      ),
      GoRoute(
        path: '/vehicles/:id',
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return VehicleDetailScreen(vehicleId: id);
        },
        routes: [
          GoRoute(
            path: 'edit',
            builder: (context, state) {
              final id = int.parse(state.pathParameters['id']!);
              return VehicleFormScreen(vehicleId: id);
            },
          ),
          GoRoute(
            path: 'maintenances',
            builder: (context, state) {
              final id = int.parse(state.pathParameters['id']!);
              return MaintenanceListScreen(vehicleId: id);
            },
            routes: [
              GoRoute(
                path: 'new',
                builder: (context, state) {
                  final id = int.parse(state.pathParameters['id']!);
                  return MaintenanceFormScreen(vehicleId: id);
                },
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/maintenances/:id',
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return MaintenanceDetailScreen(maintenanceId: id);
        },
        routes: [
          GoRoute(
            path: 'edit',
            builder: (context, state) {
              final id = int.parse(state.pathParameters['id']!);
              return MaintenanceFormScreen(maintenanceId: id);
            },
          ),
        ],
      ),
    ],
  );
}
