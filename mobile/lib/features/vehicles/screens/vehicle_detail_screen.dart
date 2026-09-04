import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/fuel_types.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_states.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/widgets/status_badge.dart';
import '../data/vehicle_repository.dart';
import '../models/vehicle.dart';
import '../providers/vehicle_provider.dart';

class VehicleDetailScreen extends StatefulWidget {
  const VehicleDetailScreen({super.key, required this.vehicleId});

  final int vehicleId;

  @override
  State<VehicleDetailScreen> createState() => _VehicleDetailScreenState();
}

class _VehicleDetailScreenState extends State<VehicleDetailScreen> {
  Vehicle? _vehicle;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadVehicle();
  }

  Future<void> _loadVehicle() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final repository = context.read<VehicleRepository>();
      final vehicle = await repository.fetchById(widget.vehicleId);
      if (mounted) {
        setState(() {
          _vehicle = vehicle;
          _isLoading = false;
        });
      }
    } on ApiException catch (error) {
      if (mounted) {
        setState(() {
          _errorMessage = error.message;
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _deleteVehicle() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surface1,
        title: const Text('Delete Vehicle'),
        content: const Text(
          'This will permanently erase this vehicle and all associated service records. This action cannot be undone.',
          style: TextStyle(color: AppTheme.textSecondary, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel', style: TextStyle(color: AppTheme.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.danger,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) {
      return;
    }

    final success =
        await context.read<VehicleProvider>().deleteVehicle(widget.vehicleId);

    if (success && mounted) {
      context.go('/vehicles');
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.read<VehicleProvider>().errorMessage ?? 'Delete failed',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.canvas,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: AppTheme.canvas,
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircleAvatar(
                backgroundColor: Colors.black54,
                child: IconButton(
                  icon: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                  onPressed: () => context.pop(),
                ),
              ),
            ),
            actions: [
              if (_vehicle != null)
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: CircleAvatar(
                    backgroundColor: Colors.black54,
                    child: IconButton(
                      onPressed: () async {
                        await context.push('/vehicles/${widget.vehicleId}/edit');
                        if (mounted) _loadVehicle();
                      },
                      icon: const Icon(
                        Icons.edit_outlined,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Container(color: const Color(0xFF0C0C0E)),
                  if (_vehicle?.photoUrl != null)
                    Hero(
                      tag: 'vehicle-photo-${_vehicle!.id}',
                      child: CachedNetworkImage(
                        imageUrl: _vehicle!.photoUrl!,
                        cacheKey:
                            '${_vehicle!.photoUrl}-${_vehicle!.updatedAt?.millisecondsSinceEpoch ?? ''}',
                        fit: BoxFit.cover,
                        placeholder: (context, url) => const Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppTheme.primaryLight,
                          ),
                        ),
                        errorWidget: (context, url, error) => const Center(
                          child: Icon(
                            Icons.directions_car_rounded,
                            size: 96,
                            color: Color(0xFF2C2C32),
                          ),
                        ),
                      ),
                    )
                  else
                    const Center(
                      child: Icon(
                        Icons.directions_car_rounded,
                        size: 100,
                        color: Color(0xFF24242A),
                      ),
                    ),
                  // Bottom dark gradient scrim
                  Positioned.fill(
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black45,
                            Colors.transparent,
                            AppTheme.canvas,
                          ],
                          stops: [0.0, 0.4, 1.0],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_isLoading)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: AppLoadingOverlay(message: 'Loading vehicle profile...'),
            )
          else if (_errorMessage != null)
            SliverFillRemaining(
              hasScrollBody: false,
              child: AppErrorView(
                message: _errorMessage!,
                onRetry: _loadVehicle,
              ),
            )
          else if (_vehicle != null)
            ..._buildContent(_vehicle!),
        ],
      ),
    );
  }

  List<Widget> _buildContent(Vehicle vehicle) {
    return [
      SliverPadding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
        sliver: SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      vehicle.displayName,
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textPrimary,
                        letterSpacing: -0.4,
                      ),
                    ),
                  ),
                  LicensePlateBadge(plate: vehicle.licensePlate),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                '${vehicle.year} · ${fuelTypeLabel(vehicle.fuelType)}',
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),

      // Specifications Grid
      SliverPadding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
        sliver: SliverGrid.count(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.8,
          children: [
            MetricTile(
              label: 'Odometer',
              value: AppFormatters.mileage(vehicle.currentMileage),
              icon: Icons.speed_rounded,
              accentColor: AppTheme.primaryLight,
            ),
            MetricTile(
              label: 'Model Year',
              value: '${vehicle.year}',
              icon: Icons.calendar_today_rounded,
              accentColor: AppTheme.secondary,
            ),
            MetricTile(
              label: 'Fuel System',
              value: fuelTypeLabel(vehicle.fuelType),
              icon: Icons.local_gas_station_rounded,
              accentColor: AppTheme.warning,
            ),
            MetricTile(
              label: 'Service Visits',
              value: '${vehicle.maintenancesCount ?? 0}',
              icon: Icons.build_rounded,
              accentColor: const Color(0xFFA855F7),
            ),
          ],
        ),
      ),

      // Action Buttons
      SliverPadding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
        sliver: SliverToBoxAdapter(
          child: Column(
            children: [
              PrimaryButton(
                onPressed: () => context.push(
                  '/vehicles/${widget.vehicleId}/maintenances/new',
                ),
                label: 'Log Service Visit',
                icon: Icons.add_rounded,
              ),
              const SizedBox(height: 12),
              GlassButton(
                onPressed: () => context.push(
                  '/vehicles/${widget.vehicleId}/maintenances',
                ),
                label: 'View Service History',
                icon: Icons.history_rounded,
              ),
            ],
          ),
        ),
      ),

      // Danger Zone
      SliverPadding(
        padding: const EdgeInsets.fromLTRB(20, 32, 20, 80),
        sliver: SliverToBoxAdapter(
          child: OutlinedButton.icon(
            onPressed: _deleteVehicle,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.danger,
              side: const BorderSide(color: AppTheme.danger, width: 1),
              minimumSize: const Size.fromHeight(48),
            ),
            icon: const Icon(Icons.delete_outline_rounded, size: 18),
            label: const Text('Delete Vehicle from Garage'),
          ),
        ),
      ),
    ];
  }
}
