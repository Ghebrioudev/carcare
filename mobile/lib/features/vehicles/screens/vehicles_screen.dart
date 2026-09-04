import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/fuel_types.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_states.dart';
import '../../../core/widgets/main_shell.dart';
import '../../../core/widgets/skeleton_loader.dart';
import '../../../core/widgets/status_badge.dart';
import '../models/vehicle.dart';
import '../providers/vehicle_provider.dart';

class VehiclesScreen extends StatefulWidget {
  const VehiclesScreen({super.key});

  @override
  State<VehiclesScreen> createState() => _VehiclesScreenState();
}

class _VehiclesScreenState extends State<VehiclesScreen> {
  Timer? _debounce;
  String _searchQuery = '';
  String _selectedSort = 'latest';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<VehicleProvider>().loadVehicles(
        search: _searchQuery,
        sort: _selectedSort,
      );
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  void _debouncedSearch() {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      if (mounted) {
        context.read<VehicleProvider>().loadVehicles(
          search: _searchQuery,
          sort: _selectedSort,
        );
      }
    });
  }

  void _showSortSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface1,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Container(
                    width: 38,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppTheme.borderHighlighted,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  'Sort Vehicles',
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 14),
                _buildSortOption('latest', 'Latest Added'),
                _buildSortOption('brand_asc', 'Brand (A - Z)'),
                _buildSortOption('brand_desc', 'Brand (Z - A)'),
                _buildSortOption('year_desc', 'Newest Years First'),
                _buildSortOption('year_asc', 'Oldest Years First'),
                _buildSortOption('mileage_desc', 'Highest Mileage'),
                _buildSortOption('mileage_asc', 'Lowest Mileage'),
                const SizedBox(height: 10),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSortOption(String code, String label) {
    final isSelected = _selectedSort == code;
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      tileColor: isSelected ? AppTheme.surface2 : Colors.transparent,
      title: Text(
        label,
        style: TextStyle(
          color: isSelected ? AppTheme.primaryLight : AppTheme.textPrimary,
          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          fontSize: 14.5,
        ),
      ),
      trailing: isSelected
          ? const Icon(Icons.check_rounded, color: AppTheme.primaryLight, size: 20)
          : null,
      onTap: () {
        Navigator.pop(context);
        setState(() {
          _selectedSort = code;
        });
        context.read<VehicleProvider>().loadVehicles(
              search: _searchQuery,
              sort: _selectedSort,
            );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<VehicleProvider>();

    return Scaffold(
      backgroundColor: AppTheme.canvas,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          backgroundColor: AppTheme.surface2,
          color: AppTheme.primaryLight,
          onRefresh: () => provider.loadVehicles(
            search: _searchQuery,
            sort: _selectedSort,
          ),
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              const SliverToBoxAdapter(
                child: ScreenHeader(
                  title: 'Garage',
                  subtitle: 'Manage your vehicle collection and service history.',
                ),
              ),

              // Search & Filter controls
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 48,
                          decoration: BoxDecoration(
                            color: AppTheme.surface1,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppTheme.border, width: 1.0),
                          ),
                          child: TextField(
                            style: const TextStyle(
                              color: AppTheme.textPrimary,
                              fontSize: 14,
                            ),
                            decoration: const InputDecoration(
                              hintText: 'Search brand, model...',
                              hintStyle: TextStyle(
                                color: AppTheme.textMuted,
                                fontSize: 14,
                              ),
                              prefixIcon: Icon(
                                Icons.search_rounded,
                                color: AppTheme.textSecondary,
                                size: 20,
                              ),
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(vertical: 14),
                            ),
                            onChanged: (value) {
                              _searchQuery = value;
                              _debouncedSearch();
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      InkWell(
                        onTap: _showSortSheet,
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: AppTheme.surface1,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppTheme.border, width: 1.0),
                          ),
                          child: const Icon(
                            Icons.tune_rounded,
                            color: AppTheme.textPrimary,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              if (provider.isLoading && provider.vehicles.isEmpty)
                const SliverFillRemaining(
                  child: VehiclesSkeleton(),
                )
              else if (provider.errorMessage != null && provider.vehicles.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: AppErrorView(
                    message: provider.errorMessage!,
                    onRetry: () => provider.loadVehicles(
                      search: _searchQuery,
                      sort: _selectedSort,
                    ),
                  ),
                )
              else if (provider.vehicles.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: AppEmptyView(
                    title: 'Your Garage is Empty',
                    subtitle: 'Add your vehicle to start tracking maintenance and health.',
                    icon: Icons.directions_car_filled_rounded,
                    action: ElevatedButton.icon(
                      onPressed: () => context.push('/vehicles/new'),
                      icon: const Icon(Icons.add_rounded),
                      label: const Text('Add Vehicle'),
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
                  sliver: SliverList.separated(
                    itemCount: provider.vehicles.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 14),
                    itemBuilder: (context, index) {
                      final vehicle = provider.vehicles[index];
                      return _VehicleCard(vehicle: vehicle);
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 70),
        child: FloatingActionButton.extended(
          onPressed: () => context.push('/vehicles/new'),
          backgroundColor: AppTheme.primary,
          foregroundColor: Colors.white,
          icon: const Icon(Icons.add_rounded),
          label: const Text(
            'Add Vehicle',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
      ),
    );
  }
}

class _VehicleCard extends StatelessWidget {
  const _VehicleCard({required this.vehicle});

  final Vehicle vehicle;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: () => context.push('/vehicles/${vehicle.id}'),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Hero(
                tag: 'vehicle-photo-${vehicle.id}',
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    width: 72,
                    height: 72,
                    color: const Color(0xFF0E0E12),
                    child: vehicle.photoUrl != null
                        ? CachedNetworkImage(
                            imageUrl: vehicle.photoUrl!,
                            cacheKey:
                                '${vehicle.photoUrl}-${vehicle.updatedAt?.millisecondsSinceEpoch ?? ''}',
                            fit: BoxFit.cover,
                            placeholder: (context, url) => const Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppTheme.primaryLight,
                              ),
                            ),
                            errorWidget: (context, url, error) => const Icon(
                              Icons.directions_car_rounded,
                              size: 34,
                              color: AppTheme.textMuted,
                            ),
                          )
                        : const Icon(
                            Icons.directions_car_rounded,
                            size: 36,
                            color: Color(0xFF2C2C32),
                          ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      vehicle.displayName,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textPrimary,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${vehicle.year} · ${fuelTypeLabel(vehicle.fuelType)}',
                      style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 12.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    LicensePlateBadge(plate: vehicle.licensePlate, height: 24),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppTheme.textMuted,
                size: 22,
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.speed_rounded,
                    size: 14,
                    color: AppTheme.primaryLight,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    AppFormatters.mileage(vehicle.currentMileage),
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              if (vehicle.maintenancesCount != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppTheme.surface2,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppTheme.border, width: 1),
                  ),
                  child: Text(
                    '${vehicle.maintenancesCount} records',
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
