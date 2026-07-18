import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_states.dart';
import '../../../core/widgets/main_shell.dart';
import '../../auth/providers/auth_provider.dart';
import '../../maintenance/models/maintenance.dart';
import '../models/dashboard_data.dart';
import '../providers/dashboard_provider.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardProvider>().loadDashboard();
    });
  }

  Future<void> _logout() async {
    await context.read<AuthProvider>().logout();
    if (mounted) context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final dashboard = context.watch<DashboardProvider>();

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: dashboard.loadDashboard,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: ScreenHeader(
                  title: 'Dashboard',
                  subtitle: auth.user != null
                      ? 'Welcome back, ${auth.user!.name}'
                      : 'Your maintenance overview',
                  trailing: IconButton(
                    tooltip: 'Logout',
                    onPressed: auth.isLoading ? null : _logout,
                    icon: const Icon(Icons.logout),
                  ),
                ),
              ),
              if (dashboard.isLoading && dashboard.data == null)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: AppLoadingOverlay(message: 'Loading dashboard...'),
                )
              else if (dashboard.errorMessage != null && dashboard.data == null)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: AppErrorView(
                    message: dashboard.errorMessage!,
                    onRetry: dashboard.loadDashboard,
                  ),
                )
              else if (dashboard.data != null)
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      _StatsGrid(data: dashboard.data!),
                      const SizedBox(height: 20),
                      _NextReminderCard(reminder: dashboard.data!.nextReminder),
                      const SizedBox(height: 24),
                      SectionHeader(
                        title: 'Recent maintenances',
                        actionLabel: 'View vehicles',
                        onAction: () => context.go('/vehicles'),
                      ),
                      if (dashboard.data!.recentMaintenances.isEmpty)
                        const AppCard(
                          child: Text(
                            'No maintenance records yet. Add a visit from a vehicle page.',
                            style: TextStyle(color: AppTheme.textSecondary),
                          ),
                        )
                      else
                        ...dashboard.data!.recentMaintenances.map(
                          (maintenance) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _MaintenanceTile(
                              maintenance: maintenance,
                              onTap: () =>
                                  context.push('/maintenances/${maintenance.id}'),
                            ),
                          ),
                        ),
                    ]),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatsGrid extends StatelessWidget {
  const _StatsGrid({required this.data});

  final DashboardData data;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: StatCard(
            icon: Icons.directions_car,
            label: 'Vehicles',
            value: '${data.vehiclesCount}',
            iconColor: AppTheme.primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: StatCard(
            icon: Icons.payments_outlined,
            label: 'Total spent',
            value: AppFormatters.currency(data.totalCost),
            iconColor: AppTheme.secondary,
            iconBackground: AppTheme.secondary,
          ),
        ),
      ],
    );
  }
}

class _NextReminderCard extends StatelessWidget {
  const _NextReminderCard({required this.reminder});

  final NextReminder? reminder;

  @override
  Widget build(BuildContext context) {
    if (reminder == null) {
      return AppCard(
        child: Row(
          children: [
           const IconBadge(icon: Icons.event_available, color: AppTheme.success),
           const SizedBox(width: 14),
           Expanded(
             child: Column(
               crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                 Text(
                   'No upcoming reminders',
                   style: Theme.of(context).textTheme.titleMedium?.copyWith(
                       fontWeight: FontWeight.w700,
                       ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                   'Add maintenance with reminder dates to track upcoming service.',
                   style: TextStyle(color: AppTheme.textSecondary),
                 ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    final r = reminder!;

    return AppCard(
      onTap: () => context.go('/reminders'),
      child: Row(
        children: [
          const IconBadge(
            icon: Icons.notifications_active,
            color: AppTheme.warning,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Next reminder',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  r.maintenanceType,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${r.vehicle.displayName} · ${r.vehicle.licensePlate}',
                  style: const TextStyle(color: AppTheme.textSecondary),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    if (r.nextDueDate != null)
                      StatusChip(
                        label: AppFormatters.date(r.nextDueDate),
                        color: AppTheme.warning,
                      ),
                    if (r.nextDueMileage != null)
                      StatusChip(
                        label: AppFormatters.mileage(r.nextDueMileage),
                        color: AppTheme.primary,
                      ),
                  ],
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: AppTheme.textSecondary),
        ],
      ),
    );
  }
}

class _MaintenanceTile extends StatelessWidget {
  const _MaintenanceTile({required this.maintenance, this.onTap});

  final Maintenance maintenance;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final vehicleName = maintenance.vehicle?.displayName ?? 'Vehicle';

    return AppCard(
      onTap: onTap,
      child: Row(
        children: [
          const IconBadge(icon: Icons.build_circle_outlined, size: 44),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  vehicleName,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${AppFormatters.date(maintenance.performedAt)} · ${AppFormatters.mileage(maintenance.mileage)}',
                  style: const TextStyle(color: AppTheme.textSecondary),
                ),
                if (maintenance.garageName != null &&
                    maintenance.garageName!.isNotEmpty)
                  Text(
                    maintenance.garageName!,
                    style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                  ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                AppFormatters.currency(maintenance.totalCost),
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppTheme.primary,
                    ),
              ),
              const Icon(Icons.chevron_right, color: AppTheme.textSecondary),
            ],
          ),
        ],
      ),
    );
  }
}
