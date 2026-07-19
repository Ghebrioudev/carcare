import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_states.dart';
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
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hello, ${auth.user?.name.split(' ').first ?? 'there'}!',
                        style: Theme.of(context)
                            .textTheme
                            .titleSmall
                            ?.copyWith(
                              color: AppTheme.textSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Keep your car in perfect shape!',
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
              if (dashboard.isLoading && dashboard.data == null)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: AppLoadingOverlay(message: 'Loading dashboard...'),
                )
              else if (dashboard.errorMessage != null &&
                  dashboard.data == null)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: AppErrorView(
                    message: dashboard.errorMessage!,
                    onRetry: dashboard.loadDashboard,
                  ),
                )
              else if (dashboard.data != null)
                ..._buildDashboardContent(dashboard.data!, context),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildDashboardContent(
    DashboardData data,
    BuildContext context,
  ) {
    return [
      if (data.nextReminder != null)
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
          sliver: SliverToBoxAdapter(
            child: _NextReminderBanner(reminder: data.nextReminder!),
          ),
        ),
      SliverPadding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
        sliver: SliverGrid.count(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          children: [
            StatCard(
              icon: Icons.directions_car_outlined,
              label: 'Vehicles',
              value: '${data.vehiclesCount}',
              iconColor: AppTheme.primary,
              onTap: () => context.go('/vehicles'),
            ),
            StatCard(
              icon: Icons.attach_money_outlined,
              label: 'Total spent',
              value: AppFormatters.currency(data.totalCost),
              iconColor: AppTheme.success,
              onTap: () => context.go('/vehicles'),
            ),
            StatCard(
              icon: Icons.build_outlined,
              label: 'Maintenances',
              value: '${data.recentMaintenances.length}',
              iconColor: AppTheme.warning,
              onTap: () => context.go('/reminders'),
            ),
            StatCard(
              icon: Icons.notifications_outlined,
              label: 'Reminders',
              value: data.nextReminder == null ? '0' : '1',
              iconColor: AppTheme.secondary,
              onTap: () => context.go('/reminders'),
            ),
          ],
        ),
      ),
      const SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.fromLTRB(20, 16, 20, 12),
          child: SectionHeader(title: 'Recent Maintenance'),
        ),
      ),
      if (data.recentMaintenances.isEmpty)
        const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: AppCard(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Column(
                  children: [
                    Icon(
                      Icons.build_circle_outlined,
                      color: AppTheme.textSecondary,
                      size: 48,
                    ),
                    SizedBox(height: 12),
                    Text(
                      'No maintenance records yet',
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        )
      else
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
          sliver: SliverList.separated(
            itemCount: data.recentMaintenances.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final maintenance = data.recentMaintenances[index];
              return _MaintenanceItemTile(maintenance: maintenance);
            },
          ),
        ),
    ];
  }
}

class _NextReminderBanner extends StatelessWidget {
  const _NextReminderBanner({required this.reminder});

  final NextReminder reminder;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.primary, AppTheme.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.all(Radius.circular(22)),
        boxShadow: [
          BoxShadow(
            color: Color(0x336C5CE7),
            blurRadius: 18,
            offset: Offset(0, 8),
            spreadRadius: -3,
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Next reminder',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 6),
                Text(
                  reminder.maintenanceType,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${reminder.vehicle.displayName} · ${reminder.vehicle.licensePlate}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white.withValues(alpha: 0.85),
                      ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    if (reminder.nextDueDate != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.calendar_today_outlined,
                              color: Colors.white,
                              size: 14,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              AppFormatters.date(reminder.nextDueDate),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (reminder.nextDueMileage != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.speed_outlined,
                              color: Colors.white,
                              size: 14,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              AppFormatters.mileage(reminder.nextDueMileage),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.water_drop_outlined,
              color: Colors.white,
              size: 26,
            ),
          ),
        ],
      ),
    );
  }
}

class _MaintenanceItemTile extends StatelessWidget {
  const _MaintenanceItemTile({required this.maintenance});

  final Maintenance maintenance;

  @override
  Widget build(BuildContext context) {
    final vehicleName = maintenance.vehicle?.displayName ?? 'Vehicle';
    return AppCard(
      onTap: () => context.push('/maintenances/${maintenance.id}'),
      child: Row(
        children: [
          const IconBadge(
            icon: Icons.build_circle_outlined,
            size: 48,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  vehicleName,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${AppFormatters.date(maintenance.performedAt)} · ${AppFormatters.mileage(maintenance.mileage)}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                ),
                if (maintenance.garageName != null &&
                    maintenance.garageName!.isNotEmpty)
                  Text(
                    maintenance.garageName!,
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                AppFormatters.currency(maintenance.totalCost),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
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
