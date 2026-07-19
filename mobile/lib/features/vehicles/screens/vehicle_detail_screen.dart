import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/fuel_types.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_states.dart';
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
        title: const Text('Delete vehicle'),
        content: const Text(
          'This will permanently delete the vehicle and all related maintenance records.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppTheme.danger),
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
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(_vehicle?.displayName ?? 'Vehicle details'),
              background: _vehicle != null
                  ? Hero(
                      tag: 'vehicle-photo-${_vehicle!.id}',
                      child: Container(
                        color: AppTheme.primary.withValues(alpha: 0.1),
                        child: _vehicle!.photoUrl != null
                            ? CachedNetworkImage(
                                imageUrl: _vehicle!.photoUrl!,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => const Center(
                                  child: CircularProgressIndicator(),
                                ),
                                errorWidget: (context, url, error) => const Icon(
                                  Icons.directions_car_outlined,
                                  size: 80,
                                  color: AppTheme.textSecondary,
                                ),
                              )
                            : const Icon(
                                Icons.directions_car_outlined,
                                size: 80,
                                color: AppTheme.textSecondary,
                              ),
                      ),
                    )
                  : null,
            ),
            actions: [
              if (_vehicle != null)
                IconButton(
                  onPressed: () =>
                      context.push('/vehicles/${widget.vehicleId}/edit'),
                  icon: const Icon(Icons.edit_outlined),
                ),
            ],
          ),
          if (_isLoading)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: AppLoadingOverlay(message: 'Loading vehicle...'),
            )
          else if (_errorMessage != null)
            SliverFillRemaining(
              hasScrollBody: false,
              child: AppErrorView(
                message: _errorMessage!,
                onRetry: _loadVehicle,
              ),
            )
          else if (_vehicle != null) ..._buildContent(_vehicle!),
        ],
      ),
    );
  }

  List<Widget> _buildContent(Vehicle vehicle) {
    return [
      SliverPadding(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
        sliver: SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                vehicle.displayName,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                vehicle.licensePlate,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
              ),
            ],
          ),
        ),
      ),
      SliverPadding(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
        sliver: SliverToBoxAdapter(
          child: AppCard(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _DetailRow(label: 'Year', value: '${vehicle.year}'),
                  _DetailRow(
                    label: 'Mileage',
                    value: AppFormatters.mileage(vehicle.currentMileage),
                  ),
                  _DetailRow(
                    label: 'Fuel type',
                    value: fuelTypeLabel(vehicle.fuelType),
                  ),
                  if (vehicle.maintenancesCount != null)
                    _DetailRow(
                      label: 'Maintenances',
                      value: '${vehicle.maintenancesCount}',
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
      SliverPadding(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
        sliver: SliverToBoxAdapter(
          child: Column(
            children: [
              ElevatedButton.icon(
                onPressed: () =>
                    context.push('/vehicles/${widget.vehicleId}/maintenances'),
                icon: const Icon(Icons.build_outlined),
                label: const Text('View maintenance history'),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _deleteVehicle,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.danger,
                  side: const BorderSide(color: AppTheme.danger),
                  minimumSize: const Size.fromHeight(48),
                ),
                icon: const Icon(Icons.delete_outlined),
                label: const Text('Delete vehicle'),
              ),
            ],
          ),
        ),
      ),
    ];
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}
