import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_states.dart';
import '../../../core/widgets/skeleton_loader.dart';
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
                  child: DashboardSkeleton(),
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
      SliverToBoxAdapter(
        child: _DashboardCharts(data: data),
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

class _DashboardCharts extends StatefulWidget {
  const _DashboardCharts({required this.data});

  final DashboardData data;

  @override
  State<_DashboardCharts> createState() => _DashboardChartsState();
}

class _DashboardChartsState extends State<_DashboardCharts> {
  int _activeTab = 0; // 0 = Cost History, 1 = Categories

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: AppCard(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Analytics',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  Row(
                    children: [
                      _buildTabButton(0, 'History'),
                      const SizedBox(width: 8),
                      _buildTabButton(1, 'Categories'),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 200,
                child: _activeTab == 0 ? _buildBarChart() : _buildPieChart(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabButton(int index, String label) {
    final isActive = _activeTab == index;
    return GestureDetector(
      onTap: () => setState(() => _activeTab = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? AppTheme.primary : AppTheme.cardBackground,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? AppTheme.primary : Colors.grey[300]!,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.white : AppTheme.textSecondary,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildBarChart() {
    final monthlyCosts = widget.data.monthlyCosts;
    if (monthlyCosts.isEmpty) {
      return const Center(child: Text('No history data available'));
    }

    final maxCost = monthlyCosts
        .map((e) => e.cost)
        .fold<double>(0.0, (prev, element) => prev > element ? prev : element);
    final yLimit = maxCost == 0 ? 100.0 : maxCost * 1.25;

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: yLimit,
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (_) => AppTheme.primary,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              return BarTooltipItem(
                AppFormatters.currency(rod.toY),
                const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (double value, TitleMeta meta) {
                final index = value.toInt();
                if (index >= 0 && index < monthlyCosts.length) {
                  return SideTitleWidget(
                    axisSide: meta.axisSide,
                    child: Text(
                      monthlyCosts[index].month,
                      style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
              reservedSize: 22,
            ),
          ),
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        barGroups: List.generate(
          monthlyCosts.length,
          (index) => BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: monthlyCosts[index].cost,
                color: AppTheme.primary,
                width: 16,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                backDrawRodData: BackgroundBarChartRodData(
                  show: true,
                  toY: yLimit,
                  color: Colors.grey[100]!,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPieChart() {
    final categoryCosts = widget.data.categoryCosts;
    if (categoryCosts.isEmpty) {
      return const Center(child: Text('No category data available'));
    }

    final total = categoryCosts
        .map((e) => e.cost)
        .fold<double>(0.0, (val, element) => val + element);

    final colors = [
      AppTheme.primary,
      AppTheme.success,
      AppTheme.warning,
      AppTheme.secondary,
      Colors.cyan,
      Colors.teal,
      Colors.orange,
    ];

    return Row(
      children: [
        Expanded(
          flex: 4,
          child: PieChart(
            PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: 30,
              sections: List.generate(
                categoryCosts.length,
                (index) {
                  final costItem = categoryCosts[index];
                  final percentage = total == 0 ? 0.0 : (costItem.cost / total) * 100;
                  return PieChartSectionData(
                    color: colors[index % colors.length],
                    value: costItem.cost,
                    title: percentage > 10 ? '${percentage.toStringAsFixed(0)}%' : '',
                    radius: 35,
                    titleStyle: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  );
                },
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 6,
          child: ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: categoryCosts.length,
            itemBuilder: (context, index) {
              final costItem = categoryCosts[index];
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: colors[index % colors.length],
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        costItem.category,
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      AppFormatters.currency(costItem.cost),
                      style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
