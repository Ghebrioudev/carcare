import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_states.dart';
import '../data/maintenance_repository.dart';
import '../models/maintenance.dart';
import '../providers/maintenance_provider.dart';

class MaintenanceDetailScreen extends StatefulWidget {
  const MaintenanceDetailScreen({super.key, required this.maintenanceId});

  final int maintenanceId;

  @override
  State<MaintenanceDetailScreen> createState() =>
      _MaintenanceDetailScreenState();
}

class _MaintenanceDetailScreenState extends State<MaintenanceDetailScreen> {
  Maintenance? _maintenance;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadMaintenance();
  }

  Future<void> _loadMaintenance() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final maintenance = await context
          .read<MaintenanceRepository>()
          .fetchById(widget.maintenanceId);
      if (mounted) {
        setState(() {
          _maintenance = maintenance;
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

  Future<void> _deleteMaintenance() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete maintenance'),
        content: const Text(
          'This will permanently delete this maintenance visit and all its operations.',
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

    if (confirmed != true || !mounted) return;

    final success = await context
        .read<MaintenanceProvider>()
        .delete(widget.maintenanceId);

    if (success && mounted) {
      context.pop();
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.read<MaintenanceProvider>().errorMessage ??
                'Delete failed',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Maintenance details'),
        actions: [
          if (_maintenance != null)
            IconButton(
              onPressed: () =>
                  context.push('/maintenances/${widget.maintenanceId}/edit'),
              icon: const Icon(Icons.edit_outlined),
            ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const AppLoadingOverlay(message: 'Loading maintenance...');
    }

    if (_errorMessage != null) {
      return AppErrorView(message: _errorMessage!, onRetry: _loadMaintenance);
    }

    final maintenance = _maintenance!;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppFormatters.date(maintenance.performedAt),
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 8),
              if (maintenance.vehicle != null)
                Text(
                  maintenance.vehicle!.displayName,
                  style: const TextStyle(color: AppTheme.textSecondary),
                ),
              const SizedBox(height: 16),
              _DetailRow(
                label: 'Mileage',
                value: AppFormatters.mileage(maintenance.mileage),
              ),
              _DetailRow(
                label: 'Total cost',
                value: AppFormatters.currency(maintenance.totalCost),
              ),
              if (maintenance.garageName != null &&
                  maintenance.garageName!.isNotEmpty)
                _DetailRow(label: 'Garage', value: maintenance.garageName!),
              if (maintenance.notes != null && maintenance.notes!.isNotEmpty)
                _DetailRow(label: 'Notes', value: maintenance.notes!),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Operations',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: 12),
        ...maintenance.items.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.maintenanceType?.name ?? 'Operation',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  if (item.cost != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      AppFormatters.currency(item.cost),
                      style: const TextStyle(
                        color: AppTheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                  if (item.notes != null && item.notes!.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(item.notes!),
                  ],
                  if (item.nextDueDate != null || item.nextDueMileage != null) ...[
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      children: [
                        if (item.nextDueDate != null)
                          StatusChip(
                            label: 'Due ${AppFormatters.date(item.nextDueDate)}',
                            color: AppTheme.warning,
                          ),
                        if (item.nextDueMileage != null)
                          StatusChip(
                            label:
                                'At ${AppFormatters.mileage(item.nextDueMileage)}',
                            color: AppTheme.primary,
                          ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: _deleteMaintenance,
          style: OutlinedButton.styleFrom(
            foregroundColor: AppTheme.danger,
            side: const BorderSide(color: AppTheme.danger),
          ),
          icon: const Icon(Icons.delete_outline),
          label: const Text('Delete maintenance'),
        ),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: const TextStyle(color: AppTheme.textSecondary),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
