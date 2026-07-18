import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_states.dart';
import '../providers/maintenance_provider.dart';

class MaintenanceListScreen extends StatefulWidget {
  const MaintenanceListScreen({super.key, required this.vehicleId});

  final int vehicleId;

  @override
  State<MaintenanceListScreen> createState() => _MaintenanceListScreenState();
}

class _MaintenanceListScreenState extends State<MaintenanceListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MaintenanceProvider>().loadByVehicle(widget.vehicleId);
    });
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
      body: RefreshIndicator(
        onRefresh: () => provider.loadByVehicle(widget.vehicleId),
        child: _buildBody(provider),
      ),
    );
  }

  Widget _buildBody(MaintenanceProvider provider) {
    if (provider.isLoading && provider.maintenances.isEmpty) {
      return  ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [
          SizedBox(
            height: 240,
            child: AppLoadingOverlay(message: 'Loading maintenances...'),
          ),
        ],
      );
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
