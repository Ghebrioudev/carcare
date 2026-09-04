import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/fuel_types.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_states.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/widgets/skeleton_loader.dart';
import '../../../core/widgets/status_badge.dart';
import '../../auth/providers/auth_provider.dart';
import '../../maintenance/models/maintenance.dart';
import '../../vehicles/models/vehicle.dart';
import '../../vehicles/providers/vehicle_provider.dart';
import '../models/dashboard_data.dart';
import '../providers/dashboard_provider.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedVehicleIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardProvider>().loadDashboard();
      context.read<VehicleProvider>().loadVehicles();
    });
  }

  Future<void> _refresh() async {
    await Future.wait([
      context.read<DashboardProvider>().loadDashboard(),
      context.read<VehicleProvider>().loadVehicles(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final dashboard = context.watch<DashboardProvider>();
    final vehicleProv = context.watch<VehicleProvider>();

    return Scaffold(
      backgroundColor: AppTheme.canvas,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          backgroundColor: AppTheme.surface2,
          color: AppTheme.primaryLight,
          onRefresh: _refresh,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // Header
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                sliver: SliverToBoxAdapter(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'HELLO, ${auth.user?.name.split(' ').first.toUpperCase() ?? 'DRIVER'}',
                            style: const TextStyle(
                              color: AppTheme.textMuted,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Vehicle Dashboard',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.textPrimary,
                              letterSpacing: -0.4,
                            ),
                          ),
                        ],
                      ),
                      InkWell(
                        onTap: () => context.go('/reminders'),
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: AppTheme.surface1,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppTheme.border, width: 1),
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              const Icon(
                                Icons.notifications_outlined,
                                color: AppTheme.textPrimary,
                                size: 22,
                              ),
                              if (dashboard.data?.nextReminder != null)
                                Positioned(
                                  top: 10,
                                  right: 11,
                                  child: Container(
                                    width: 8,
                                    height: 8,
                                    decoration: const BoxDecoration(
                                      color: AppTheme.warning,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Loading & Error states
              if (dashboard.isLoading && dashboard.data == null)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: DashboardSkeleton(),
                )
              else if (dashboard.errorMessage != null && dashboard.data == null)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: AppErrorView(
                    message: dashboard.errorMessage!,
                    onRetry: _refresh,
                  ),
                )
              else if (dashboard.data != null)
                ..._buildContent(
                  dashboard.data!,
                  vehicleProv.vehicles,
                  context,
                ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildContent(
    DashboardData data,
    List<Vehicle> vehicles,
    BuildContext context,
  ) {
    final hasVehicles = vehicles.isNotEmpty;
    final selectedVehicle = hasVehicles
        ? vehicles[_selectedVehicleIndex.clamp(0, vehicles.length - 1)]
        : null;

    return [
      // 1. VEHICLE HERO SECTION
      SliverPadding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
        sliver: SliverToBoxAdapter(
          child: hasVehicles && selectedVehicle != null
              ? _VehicleHeroShowcase(
                  vehicle: selectedVehicle,
                  vehicles: vehicles,
                  selectedIndex: _selectedVehicleIndex,
                  onSelectVehicle: (index) {
                    setState(() => _selectedVehicleIndex = index);
                  },
                )
              : _EmptyVehicleHero(),
        ),
      ),

      // 2. NEXT DUE REMINDER (If exists)
      if (data.nextReminder != null)
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
          sliver: SliverToBoxAdapter(
            child: _NextReminderCard(reminder: data.nextReminder!),
          ),
        ),

      // 3. QUICK ACTION BUTTONS
      SliverPadding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 18),
        sliver: SliverToBoxAdapter(
          child: _QuickActionsRow(
            selectedVehicleId: selectedVehicle?.id,
          ),
        ),
      ),

      // 4. TELEMETRY & SPENDING ANALYTICS
      SliverPadding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 18),
        sliver: SliverToBoxAdapter(
          child: _SpendingAnalyticsCard(
            totalCost: data.totalCost,
            monthlyCosts: data.monthlyCosts,
            categoryCosts: data.categoryCosts,
          ),
        ),
      ),

      // 5. RECENT MAINTENANCE LOGS
      const SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.fromLTRB(20, 8, 20, 12),
          child: SectionHeader(title: 'Recent Service History'),
        ),
      ),

      if (data.recentMaintenances.isEmpty)
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
            child: GlassCard(
              padding: const EdgeInsets.all(28),
              child: Column(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: AppTheme.surface2,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppTheme.border, width: 1),
                    ),
                    child: const Icon(
                      Icons.build_circle_outlined,
                      color: AppTheme.textMuted,
                      size: 28,
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'No maintenance logs yet',
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Log your garage visits to unlock maintenance telemetry.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),
        )
      else
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
          sliver: SliverList.separated(
            itemCount: data.recentMaintenances.length,
            separatorBuilder: (context, index) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final maintenance = data.recentMaintenances[index];
              return _RecentMaintenanceTile(maintenance: maintenance);
            },
          ),
        ),
    ];
  }
}

/// Hero showcase widget that puts the vehicle front and center
class _VehicleHeroShowcase extends StatelessWidget {
  const _VehicleHeroShowcase({
    required this.vehicle,
    required this.vehicles,
    required this.selectedIndex,
    required this.onSelectVehicle,
  });

  final Vehicle vehicle;
  final List<Vehicle> vehicles;
  final int selectedIndex;
  final ValueChanged<int> onSelectVehicle;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1B1B20),
            Color(0xFF101013),
          ],
        ),
        border: Border.all(
          color: const Color(0x33FFFFFF),
          width: 1.0,
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.black87,
            blurRadius: 28,
            offset: Offset(0, 10),
            spreadRadius: -4,
          ),
          BoxShadow(
            color: Color(0x1A16A249),
            blurRadius: 24,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Vehicle switcher pills if multiple vehicles exist
          if (vehicles.length > 1)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: List.generate(vehicles.length, (idx) {
                    final v = vehicles[idx];
                    final isSelected = idx == selectedIndex;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: InkWell(
                        onTap: () => onSelectVehicle(idx),
                        borderRadius: BorderRadius.circular(16),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppTheme.primary.withValues(alpha: 0.2)
                                : AppTheme.surface1,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected
                                  ? AppTheme.primaryLight
                                  : AppTheme.border,
                              width: 1.0,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.directions_car_rounded,
                                size: 14,
                                color: isSelected
                                    ? AppTheme.primaryLight
                                    : AppTheme.textSecondary,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                v.displayName,
                                style: TextStyle(
                                  color: isSelected
                                      ? Colors.white
                                      : AppTheme.textSecondary,
                                  fontSize: 12,
                                  fontWeight: isSelected
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),

          // Main Hero Showcase Body
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row: Brand / Model + Status Pill
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            vehicle.displayName,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.textPrimary,
                              letterSpacing: -0.4,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${vehicle.year} · ${fuelTypeLabel(vehicle.fuelType)}',
                            style: const TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const StatusBadge(
                      label: 'ACTIVE',
                      color: AppTheme.primaryLight,
                      showDot: true,
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Vehicle Imagery Area with Cinematic Glow
                InkWell(
                  onTap: () => context.push('/vehicles/${vehicle.id}'),
                  borderRadius: BorderRadius.circular(18),
                  child: Container(
                    height: 150,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0E0E12),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: const Color(0x1FFFFFFF),
                        width: 1.0,
                      ),
                    ),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        // Subtle center highlight
                        Center(
                          child: Container(
                            width: 120,
                            height: 60,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [
                                  AppTheme.primary.withValues(alpha: 0.18),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          ),
                        ),
                        Hero(
                          tag: 'vehicle-photo-${vehicle.id}',
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(18),
                            child: vehicle.photoUrl != null
                                ? CachedNetworkImage(
                                    imageUrl: vehicle.photoUrl!,
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) => const Center(
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: AppTheme.primaryLight,
                                      ),
                                    ),
                                    errorWidget: (context, url, error) =>
                                        const Center(
                                      child: Icon(
                                        Icons.directions_car_rounded,
                                        size: 72,
                                        color: AppTheme.textMuted,
                                      ),
                                    ),
                                  )
                                : const Center(
                                    child: Icon(
                                      Icons.directions_car_rounded,
                                      size: 76,
                                      color: Color(0xFF2C2C32),
                                    ),
                                  ),
                          ),
                        ),
                        Positioned(
                          bottom: 10,
                          right: 12,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.65),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color(0x26FFFFFF),
                                width: 0.8,
                              ),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Specs',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(width: 4),
                                Icon(
                                  Icons.arrow_forward_ios_rounded,
                                  color: Colors.white,
                                  size: 10,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Telemetry Footer: License Plate + Mileage Odometer
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    LicensePlateBadge(plate: vehicle.licensePlate),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.surface1,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppTheme.border,
                          width: 1.0,
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.speed_rounded,
                            size: 15,
                            color: AppTheme.primaryLight,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            AppFormatters.mileage(vehicle.currentMileage),
                            style: const TextStyle(
                              color: AppTheme.textPrimary,
                              fontSize: 13.5,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.2,
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
        ],
      ),
    );
  }
}

/// Fallback hero card when user has not registered a vehicle yet
class _EmptyVehicleHero extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppTheme.surface2,
              shape: BoxShape.circle,
              border: Border.all(color: AppTheme.border, width: 1),
            ),
            child: const Icon(
              Icons.directions_car_filled_rounded,
              color: AppTheme.primaryLight,
              size: 32,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'No Vehicle Registered',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Add your car to track mileage, service history, and health alerts.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 18),
          PrimaryButton(
            onPressed: () => context.push('/vehicles/new'),
            label: 'Add Vehicle',
            icon: Icons.add_rounded,
            height: 48,
          ),
        ],
      ),
    );
  }
}

/// High-priority next reminder glass card
class _NextReminderCard extends StatelessWidget {
  const _NextReminderCard({required this.reminder});

  final NextReminder reminder;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF262010),
            Color(0xFF14120B),
          ],
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: AppTheme.warning.withValues(alpha: 0.35),
          width: 1.0,
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.black54,
            blurRadius: 18,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: AppTheme.warning.withValues(alpha: 0.15),
              shape: BoxShape.circle,
              border: Border.all(
                color: AppTheme.warning.withValues(alpha: 0.3),
                width: 1.0,
              ),
            ),
            child: const Icon(
              Icons.notifications_active_rounded,
              color: AppTheme.warning,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      'NEXT SERVICE DUE',
                      style: TextStyle(
                        color: AppTheme.warning,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.warning.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        reminder.vehicle.displayName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  reminder.maintenanceType,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    if (reminder.nextDueDate != null)
                      _BadgePill(
                        icon: Icons.calendar_today_rounded,
                        text: AppFormatters.date(reminder.nextDueDate),
                      ),
                    if (reminder.nextDueMileage != null)
                      _BadgePill(
                        icon: Icons.speed_rounded,
                        text: AppFormatters.mileage(reminder.nextDueMileage),
                      ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => context.go('/reminders'),
            icon: const Icon(
              Icons.chevron_right_rounded,
              color: AppTheme.warning,
            ),
          ),
        ],
      ),
    );
  }
}

class _BadgePill extends StatelessWidget {
  const _BadgePill({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.white70),
          const SizedBox(width: 5),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// 4-item glass quick action row
class _QuickActionsRow extends StatelessWidget {
  const _QuickActionsRow({this.selectedVehicleId});
  final int? selectedVehicleId;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ActionItem(
            icon: Icons.build_rounded,
            label: 'Add Visit',
            color: AppTheme.primaryLight,
            onTap: () {
              if (selectedVehicleId != null) {
                context.push('/vehicles/$selectedVehicleId/maintenances/new');
              } else {
                context.go('/vehicles');
              }
            },
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _ActionItem(
            icon: Icons.directions_car_rounded,
            label: 'Garage',
            color: AppTheme.secondary,
            onTap: () => context.go('/vehicles'),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _ActionItem(
            icon: Icons.notifications_active_rounded,
            label: 'Reminders',
            color: AppTheme.warning,
            onTap: () => context.go('/reminders'),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _ActionItem(
            icon: Icons.auto_awesome_rounded,
            label: 'AI Care',
            color: const Color(0xFFA855F7),
            onTap: () => context.go('/chat'),
          ),
        ),
      ],
    );
  }
}

class _ActionItem extends StatelessWidget {
  const _ActionItem({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        splashColor: color.withValues(alpha: 0.15),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: AppTheme.surface1,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppTheme.border, width: 1.0),
            boxShadow: const [
              BoxShadow(
                color: Colors.black38,
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 19),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Spending Analytics Card powered by real monthlyCosts and categoryCosts using fl_chart
class _SpendingAnalyticsCard extends StatelessWidget {
  const _SpendingAnalyticsCard({
    required this.totalCost,
    required this.monthlyCosts,
    required this.categoryCosts,
  });

  final double totalCost;
  final List<MonthlyCost> monthlyCosts;
  final List<CategoryCost> categoryCosts;

  @override
  Widget build(BuildContext context) {
    final maxCost = monthlyCosts.fold<double>(
      0.0,
      (max, m) => m.cost > max ? m.cost : max,
    );
    final chartMaxY = maxCost > 0 ? maxCost * 1.25 : 100.0;

    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'TOTAL MAINTENANCE SPEND',
                    style: TextStyle(
                      color: AppTheme.textMuted,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    AppFormatters.currency(totalCost),
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: AppTheme.primary.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.bar_chart_rounded,
                      size: 14,
                      color: AppTheme.primaryLight,
                    ),
                    SizedBox(width: 4),
                    Text(
                      '6 Months',
                      style: TextStyle(
                        color: AppTheme.primaryLight,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Monthly spending bar chart
          SizedBox(
            height: 120,
            child: monthlyCosts.isEmpty
                ? const Center(
                    child: Text(
                      'No expense records yet',
                      style: TextStyle(color: AppTheme.textMuted, fontSize: 13),
                    ),
                  )
                : BarChart(
                    BarChartData(
                      maxY: chartMaxY,
                      alignment: BarChartAlignment.spaceAround,
                      gridData: const FlGridData(show: false),
                      borderData: FlBorderData(show: false),
                      titlesData: FlTitlesData(
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        leftTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              final index = value.toInt();
                              if (index < 0 || index >= monthlyCosts.length) {
                                return const SizedBox();
                              }
                              return Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(
                                  monthlyCosts[index].month,
                                  style: const TextStyle(
                                    color: AppTheme.textMuted,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      barGroups: monthlyCosts.asMap().entries.map((entry) {
                        final idx = entry.key;
                        final item = entry.value;
                        final isLast = idx == monthlyCosts.length - 1;

                        return BarChartGroupData(
                          x: idx,
                          barRods: [
                            BarChartRodData(
                              toY: item.cost,
                              width: 18,
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(6),
                              ),
                              gradient: isLast
                                  ? AppTheme.primaryGradient
                                  : const LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Color(0xFF323238),
                                        Color(0xFF1C1C20),
                                      ],
                                    ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
          ),

          // Category Pills Breakdown
          if (categoryCosts.isNotEmpty) ...[
            const SizedBox(height: 18),
            const Divider(),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: categoryCosts.take(4).map((cat) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.surface2,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppTheme.border, width: 1),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        cat.category,
                        style: const TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        AppFormatters.currency(cat.cost),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }
}

/// Timeline-styled recent maintenance entry card
class _RecentMaintenanceTile extends StatelessWidget {
  const _RecentMaintenanceTile({required this.maintenance});

  final Maintenance maintenance;

  @override
  Widget build(BuildContext context) {
    final vehicleName = maintenance.vehicle?.displayName ?? 'Vehicle';

    return AppCard(
      onTap: () => context.push('/maintenances/${maintenance.id}'),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppTheme.surface2,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppTheme.border, width: 1),
            ),
            child: const Icon(
              Icons.build_rounded,
              color: AppTheme.primaryLight,
              size: 20,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  vehicleName,
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${AppFormatters.date(maintenance.performedAt)} · ${AppFormatters.mileage(maintenance.mileage)}',
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 12.5,
                  ),
                ),
                if (maintenance.garageName != null &&
                    maintenance.garageName!.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    maintenance.garageName!,
                    style: const TextStyle(
                      color: AppTheme.textMuted,
                      fontSize: 11.5,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                AppFormatters.currency(maintenance.totalCost),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 4),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppTheme.textMuted,
                size: 18,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
