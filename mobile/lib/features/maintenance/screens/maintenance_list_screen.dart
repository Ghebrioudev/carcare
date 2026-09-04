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
    _debounce = Timer(const Duration(milliseconds: 400), () {
      if (mounted) {
        _loadData();
      }
    });
  }

  void _showFilterSortSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.surface1,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return DraggableScrollableSheet(
              initialChildSize: 0.65,
              minChildSize: 0.4,
              maxChildSize: 0.9,
              expand: false,
              builder: (context, scrollController) {
                return SafeArea(
                  child: ListView(
                    controller: scrollController,
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Filters & Sorting',
                            style: TextStyle(
                              color: AppTheme.textPrimary,
                              fontSize: 19,
                              fontWeight: FontWeight.w800,
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
                      const SizedBox(height: 16),
                      const Text(
                        'Sort Records',
                        style: TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _buildSortChip(setSheetState, 'date_desc', 'Newest Date'),
                          _buildSortChip(setSheetState, 'date_asc', 'Oldest Date'),
                          _buildSortChip(setSheetState, 'cost_desc', 'Highest Cost'),
                          _buildSortChip(setSheetState, 'cost_asc', 'Lowest Cost'),
                          _buildSortChip(setSheetState, 'mileage_desc', 'Highest Mileage'),
                          _buildSortChip(setSheetState, 'mileage_asc', 'Lowest Mileage'),
                        ],
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Service Category',
                        style: TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 10),
                      if (_types.isEmpty)
                        const Text(
                          'No categories found',
                          style: TextStyle(color: AppTheme.textMuted),
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
                              selectedColor: AppTheme.primary.withValues(alpha: 0.25),
                              backgroundColor: AppTheme.surface2,
                              labelStyle: TextStyle(
                                color: isSelected
                                    ? AppTheme.primaryLight
                                    : AppTheme.textPrimary,
                                fontWeight: isSelected
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                              ),
                              side: BorderSide(
                                color: isSelected
                                    ? AppTheme.primaryLight
                                    : AppTheme.border,
                              ),
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
                        child: const Text('Apply Filters'),
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
      selectedColor: AppTheme.primary.withValues(alpha: 0.25),
      backgroundColor: AppTheme.surface2,
      labelStyle: TextStyle(
        color: isSelected ? AppTheme.primaryLight : AppTheme.textPrimary,
        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
      ),
      side: BorderSide(
        color: isSelected ? AppTheme.primaryLight : AppTheme.border,
      ),
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
    final hasActiveFilters =
        _selectedTypeId != null || _selectedSort != 'date_desc';

    return Scaffold(
      backgroundColor: AppTheme.canvas,
      appBar: AppBar(
        backgroundColor: AppTheme.canvas,
        title: const Text('Service History'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => context.pop(),
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: FloatingActionButton.extended(
          onPressed: () =>
              context.push('/vehicles/${widget.vehicleId}/maintenances/new'),
          backgroundColor: AppTheme.primary,
          foregroundColor: Colors.white,
          icon: const Icon(Icons.add_rounded),
          label: const Text(
            'Log Service Visit',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
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
                        hintText: 'Search notes, garage...',
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
                  onTap: _showFilterSortSheet,
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: hasActiveFilters
                          ? AppTheme.primary.withValues(alpha: 0.15)
                          : AppTheme.surface1,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: hasActiveFilters
                            ? AppTheme.primaryLight
                            : AppTheme.border,
                        width: 1.0,
                      ),
                    ),
                    child: Icon(
                      Icons.tune_rounded,
                      color: hasActiveFilters
                          ? AppTheme.primaryLight
                          : AppTheme.textPrimary,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              backgroundColor: AppTheme.surface2,
              color: AppTheme.primaryLight,
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
            height: 320,
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
            height: 380,
            child: AppEmptyView(
              title: 'No Service Records',
              subtitle: 'Log your first garage visit to track repairs and parts.',
              icon: Icons.build_circle_outlined,
              action: ElevatedButton.icon(
                onPressed: () => context
                    .push('/vehicles/${widget.vehicleId}/maintenances/new'),
                icon: const Icon(Icons.add_rounded),
                label: const Text('Log First Visit'),
              ),
            ),
          ),
        ],
      );
    }

    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 100),
      itemCount: provider.maintenances.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final maintenance = provider.maintenances[index];
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
                      AppFormatters.date(maintenance.performedAt),
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${AppFormatters.mileage(maintenance.mileage)} · ${maintenance.items.length} operation(s)',
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
                      fontSize: 15.5,
                      fontWeight: FontWeight.w800,
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
      },
    );
  }
}
