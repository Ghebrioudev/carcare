import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_states.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/status_badge.dart';
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
        backgroundColor: AppTheme.surface1,
        title: const Text('Delete Service Record'),
        content: const Text(
          'This will permanently delete this service visit and all its recorded operations.',
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
      backgroundColor: AppTheme.canvas,
      appBar: AppBar(
        backgroundColor: AppTheme.canvas,
        title: const Text('Service Invoice'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => context.pop(),
        ),
        actions: [
          if (_maintenance != null)
            IconButton(
              onPressed: () =>
                  context.push('/maintenances/${widget.maintenanceId}/edit'),
              icon: const Icon(Icons.edit_outlined, size: 20),
            ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const AppLoadingOverlay(message: 'Loading service invoice...');
    }

    if (_errorMessage != null) {
      return AppErrorView(message: _errorMessage!, onRetry: _loadMaintenance);
    }

    final maintenance = _maintenance!;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 60),
      children: [
        // Executive Total & Vehicle Summary Card
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF1C1C22),
                Color(0xFF101013),
              ],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppTheme.borderHighlighted, width: 1.0),
            boxShadow: const [
              BoxShadow(
                color: Colors.black87,
                blurRadius: 24,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'TOTAL SERVICE COST',
                    style: TextStyle(
                      color: AppTheme.textMuted,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                    ),
                  ),
                  StatusBadge(
                    label: 'COMPLETED',
                    color: AppTheme.primaryLight,
                    showDot: true,
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                AppFormatters.currency(maintenance.totalCost),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (maintenance.vehicle != null)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          maintenance.vehicle!.displayName,
                          style: const TextStyle(
                            color: AppTheme.textPrimary,
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          maintenance.vehicle!.licensePlate,
                          style: const TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 12.5,
                          ),
                        ),
                      ],
                    ),
                  Text(
                    AppFormatters.date(maintenance.performedAt),
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 18),

        // Specs Telemetry Row
        Row(
          children: [
            Expanded(
              child: MetricTile(
                label: 'Odometer at Visit',
                value: AppFormatters.mileage(maintenance.mileage),
                icon: Icons.speed_rounded,
                accentColor: AppTheme.primaryLight,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: MetricTile(
                label: 'Garage Facility',
                value: (maintenance.garageName != null &&
                        maintenance.garageName!.isNotEmpty)
                    ? maintenance.garageName!
                    : 'Independent',
                icon: Icons.store_rounded,
                accentColor: AppTheme.secondary,
              ),
            ),
          ],
        ),

        if (maintenance.notes != null && maintenance.notes!.isNotEmpty) ...[
          const SizedBox(height: 16),
          GlassCard(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(
                      Icons.notes_rounded,
                      size: 16,
                      color: AppTheme.textSecondary,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Technician Notes',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  maintenance.notes!,
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],

        const SizedBox(height: 24),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Operations Performed',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppTheme.textPrimary,
                letterSpacing: -0.3,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppTheme.surface2,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppTheme.border, width: 1),
              ),
              child: Text(
                '${maintenance.items.length} items',
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        ...maintenance.items.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: AppCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        item.maintenanceType?.name ?? 'Operation',
                        style: const TextStyle(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      if (item.cost != null)
                        Text(
                          AppFormatters.currency(item.cost),
                          style: const TextStyle(
                            color: AppTheme.primaryLight,
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                          ),
                        ),
                    ],
                  ),
                  if (item.notes != null && item.notes!.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      item.notes!,
                      style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                  if (item.nextDueDate != null || item.nextDueMileage != null) ...[
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        if (item.nextDueDate != null)
                          StatusBadge(
                            label: 'Next: ${AppFormatters.date(item.nextDueDate)}',
                            color: AppTheme.warning,
                            icon: Icons.event_rounded,
                            showDot: false,
                          ),
                        if (item.nextDueMileage != null)
                          StatusBadge(
                            label: 'At: ${AppFormatters.mileage(item.nextDueMileage)}',
                            color: AppTheme.secondary,
                            icon: Icons.speed_rounded,
                            showDot: false,
                          ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),

        const SizedBox(height: 24),

        OutlinedButton.icon(
          onPressed: _deleteMaintenance,
          style: OutlinedButton.styleFrom(
            foregroundColor: AppTheme.danger,
            side: const BorderSide(color: AppTheme.danger, width: 1),
            minimumSize: const Size.fromHeight(48),
          ),
          icon: const Icon(Icons.delete_outline_rounded, size: 18),
          label: const Text('Delete Service Record'),
        ),
      ],
    );
  }
}
