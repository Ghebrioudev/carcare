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
    _debounce = Timer(const Duration(milliseconds: 500), () {
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
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Sort Vehicles',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              _buildSortOption('latest', 'Latest Added'),
              _buildSortOption('brand_asc', 'Brand (A - Z)'),
              _buildSortOption('brand_desc', 'Brand (Z - A)'),
              _buildSortOption('year_desc', 'Newest Years First'),
              _buildSortOption('year_asc', 'Oldest Years First'),
              _buildSortOption('mileage_desc', 'Highest Mileage'),
              _buildSortOption('mileage_asc', 'Lowest Mileage'),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSortOption(String code, String label) {
    final isSelected = _selectedSort == code;
    return ListTile(
      title: Text(
        label,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      trailing: isSelected ? const Icon(Icons.check, color: AppTheme.primary) : null,
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
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => provider.loadVehicles(
            search: _searchQuery,
            sort: _selectedSort,
          ),
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              const SliverToBoxAdapter(
                child: ScreenHeader(
                  title: 'Vehicles',
                  subtitle: 'Manage your cars and maintenance history.',
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          decoration: const InputDecoration(
                            hintText: 'Search brand, model...',
                            prefixIcon: Icon(Icons.search),
                            contentPadding: EdgeInsets.symmetric(
                              vertical: 0,
                              horizontal: 12,
                            ),
                          ),
                          onChanged: (value) {
                            _searchQuery = value;
                            _debouncedSearch();
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton.filledTonal(
                        onPressed: _showSortSheet,
                        icon: const Icon(Icons.sort),
                      ),
                    ],
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 16)),
              if (provider.isLoading && provider.vehicles.isEmpty)
                const SliverFillRemaining(
                  child: VehiclesSkeleton(),
                )
              else if (provider.errorMessage != null &&
                  provider.vehicles.isEmpty)
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
                    title: 'No vehicles yet',
                    subtitle:
                        'Add your first vehicle to start tracking maintenance.',
                    icon: Icons.directions_car_outlined,
                    action: ElevatedButton.icon(
                      onPressed: () => context.push('/vehicles/new'),
                      icon: const Icon(Icons.add),
                      label: const Text('Add vehicle'),
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 96),
                  sliver: SliverList.separated(
                    itemCount: provider.vehicles.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final vehicle = provider.vehicles[index];
                      return AppCard(
                        onTap: () => context.push('/vehicles/${vehicle.id}'),
                        child: Row(
                          children: [
                            Hero(
                              tag: 'vehicle-photo-${vehicle.id}',
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: Container(
                                  width: 64,
                                  height: 64,
                                  color: AppTheme.primary.withValues(alpha: 0.1),
                                  child: vehicle.photoUrl != null
                                      ? CachedNetworkImage(
                                          imageUrl: vehicle.photoUrl!,
                                          cacheKey:
                                              '${vehicle.photoUrl}-${vehicle.updatedAt?.millisecondsSinceEpoch ?? ''}',
                                          fit: BoxFit.cover,
                                          placeholder: (context, url) =>
                                              const Center(
                                            child: CircularProgressIndicator(),
                                          ),
                                          errorWidget: (context, url, error) =>
                                              const Icon(
                                            Icons.directions_car_outlined,
                                            size: 32,
                                            color: AppTheme.textSecondary,
                                          ),
                                        )
                                      : const Icon(
                                          Icons.directions_car_outlined,
                                          size: 32,
                                          color: AppTheme.textSecondary,
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
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(fontWeight: FontWeight.w700),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${vehicle.year} · ${vehicle.licensePlate}',
                                    style: const TextStyle(
                                      color: AppTheme.textSecondary,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${AppFormatters.mileage(vehicle.currentMileage)} · ${fuelTypeLabel(vehicle.fuelType)}',
                                    style: const TextStyle(
                                      color: AppTheme.textSecondary,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.chevron_right,
                              color: AppTheme.textSecondary,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/vehicles/new'),
        icon: const Icon(Icons.add),
        label: const Text('Add vehicle'),
      ),
    );
  }
}
