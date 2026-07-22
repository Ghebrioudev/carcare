import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_states.dart';
import '../../../core/widgets/skeleton_loader.dart';
import '../providers/maintenance_provider.dart';
import '../models/maintenance_type.dart';
import '../data/maintenance_type_repository.dart';

class MaintenanceListScreen extends StatefulWidget {
  const MaintenanceListScreen({super.key, required this.vehicleId});

  final int vehicleId;

  @override
  State<MaintenanceListScreen> createState() => _MaintenanceListScreenState();
}

class _MaintenanceListScreenState extends State<MaintenanceListScreen> {
  Timer? _debounce;
  String _searchQuery = '';
  String? _selectedTypeId;
  String _selectedSort = 'date_desc';
  List<MaintenanceType> _types = [];

  @override
  void initState() {
    super.initState();
    _loadTypes();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  void _loadTypes() async {
    try {
      final types = await context.read<MaintenanceTypeRepository>().fetchAll();
      if (mounted) {
        setState(() {
          _types = types;
        });
      }
    } catch (_) {}
  }

  void _loadData() {
    context.read<MaintenanceProvider>().loadByVehicle(
      widget.vehicleId,
      search: _searchQuery,
      type: _selectedTypeId,
      sort: _selectedSort,
    );
  }

  void _debouncedSearch() {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (mounted) {
        _loadData();
      }
    });
  }

  void _showFilterSortSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return DraggableScrollableSheet(
              initialChildSize: 0.6,
              minChildSize: 0.4,
              maxChildSize: 0.9,
              expand: false,
              builder: (context, scrollController) {
                return SafeArea(
                  child: ListView(
                    controller: scrollController,
                    padding: const EdgeInsets.all(20),
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Filters & Sort',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          TextButton(
                            onPressed: () {
                              setSheetState(() {
                                _selectedTypeId = null;
                                _selectedSort = 'date_desc';
                              });
                              setState(() {});
                              _loadData();
                              Navigator.pop(context);
                            },
                            child: const Text('Reset All'),
                          ),
                        ],
                      ),
                      const Divider(),
                      const SizedBox(height: 12),
                      Text(
                        'Sort by',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _buildSortChip(setSheetState, 'date_desc', 'Date (Newest)'),
                          _buildSortChip(setSheetState, 'date_asc', 'Date (Oldest)'),
                          _buildSortChip(setSheetState, 'cost_desc', 'Cost (Highest)'),
                          _buildSortChip(setSheetState, 'cost_asc', 'Cost (Lowest)'),
                          _buildSortChip(setSheetState, 'mileage_desc', 'Mileage (Highest)'),
                          _buildSortChip(setSheetState, 'mileage_asc', 'Mileage (Lowest)'),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Category',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 8),
                      if (_types.isEmpty)
                        const Text(
                          'No categories available',
                          style: TextStyle(color: AppTheme.textSecondary),
                        )
                      else
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _types.map((type) {
                            final isSelected = _selectedTypeId == type.id.toString();
                            return ChoiceChip(
                              label: Text(type.name),
                              selected: isSelected,
                              onSelected: (selected) {
                                setSheetState(() {
                                  _selectedTypeId = selected ? type.id.toString() : null;
                                });
                                setState(() {});
                                _loadData();
                              },
                            );
                          }).toList(),
                        ),
                      const SizedBox(height: 32),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size.fromHeight(50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Apply'),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildSortChip(StateSetter setSheetState, String code, String label) {
    final isSelected = _selectedSort == code;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          setSheetState(() {
            _selectedSort = code;
          });
          setState(() {});
          _loadData();
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MaintenanceProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Maintenance history'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () =>
            context.push('/vehicles/${widget.vehicleId}/maintenances/new'),
        icon: const Icon(Icons.add),
        label: const Text('Add visit'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search notes, garage...',
                      prefixIcon: const Icon(Icons.search),
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 0,
                        horizontal: 12,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
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
                  onPressed: _showFilterSortSheet,
                  icon: Icon(
                    (_selectedTypeId != null || _selectedSort != 'date_desc')
                        ? Icons.filter_alt
                        : Icons.filter_alt_outlined,
                    color: (_selectedTypeId != null || _selectedSort != 'date_desc')
                        ? AppTheme.primary
                        : null,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                _loadData();
              },
              child: _buildBody(provider),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(MaintenanceProvider provider) {
    if (provider.isLoading && provider.maintenances.isEmpty) {
      return const MaintenanceSkeleton();
    }

    if (provider.errorMessage != null && provider.maintenances.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height: 280,
            child: AppErrorView(
              message: provider.errorMessage!,
              onRetry: () => provider.loadByVehicle(widget.vehicleId),
            ),
          ),
        ],
      );
    }

    if (provider.maintenances.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height: 360,
            child: AppEmptyView(
              title: 'No maintenance yet',
              subtitle: 'Record your first garage visit and track operations.',
              icon: Icons.build_outlined,
              action: ElevatedButton.icon(
                onPressed: () => context
                    .push('/vehicles/${widget.vehicleId}/maintenances/new'),
                icon: const Icon(Icons.add),
                label: const Text('Add maintenance'),
              ),
            ),
          ),
        ],
      );
    }

    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
      itemCount: provider.maintenances.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final maintenance = provider.maintenances[index];
        return AppCard(
          onTap: () => context.push('/maintenances/${maintenance.id}'),
          child: Row(
            children: [
              const IconBadge(icon: Icons.build_circle_outlined, size: 44),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppFormatters.date(maintenance.performedAt),
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${AppFormatters.mileage(maintenance.mileage)} · ${maintenance.items.length} operation(s)',
                      style: const TextStyle(color: AppTheme.textSecondary),
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
              Text(
                AppFormatters.currency(maintenance.totalCost),
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppTheme.primary,
                    ),
              ),
            ],
          ),
        );
      },
    );
  }
}
