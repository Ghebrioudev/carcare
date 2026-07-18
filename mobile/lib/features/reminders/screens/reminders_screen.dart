import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_states.dart';
import '../../../core/widgets/main_shell.dart';
import '../models/reminder_entry.dart';
import '../providers/reminders_provider.dart';

class RemindersScreen extends StatefulWidget {
  const RemindersScreen({super.key});

  @override
  State<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends State<RemindersScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RemindersProvider>().loadReminders();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RemindersProvider>();

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: provider.loadReminders,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              const SliverToBoxAdapter(
                child: ScreenHeader(
                  title: 'Reminders',
                  subtitle: 'Upcoming maintenance based on date and mileage.',
                ),
              ),
              if (provider.isLoading && provider.reminders.isEmpty)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: AppLoadingOverlay(message: 'Loading reminders...'),
                )
              else if (provider.errorMessage != null &&
                  provider.reminders.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: AppErrorView(
                    message: provider.errorMessage!,
                    onRetry: provider.loadReminders,
                  ),
                )
              else if (provider.reminders.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: AppEmptyView(
                    title: 'No reminders yet',
                    subtitle:
                        'When you add maintenance operations with next due date or mileage, they will appear here.',
                    icon: Icons.notifications_none,
                    action: ElevatedButton(
                      onPressed: () => context.go('/vehicles'),
                      child: const Text('Go to vehicles'),
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  sliver: SliverList.separated(
                    itemCount: provider.reminders.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final reminder = provider.reminders[index];
                      return _ReminderCard(
                        reminder: reminder,
                        onTap: () => context.push(
                          '/maintenances/${reminder.maintenanceId}',
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReminderCard extends StatelessWidget {
  const _ReminderCard({required this.reminder, required this.onTap});

  final ReminderEntry reminder;
  final VoidCallback onTap;

  Color _statusColor() {
    if (reminder.isOverdueByDate || reminder.isOverdueByMileage) {
      return AppTheme.danger;
    }
    if (reminder.isDueSoonByDate || reminder.isDueSoonByMileage) {
      return AppTheme.warning;
    }
    return AppTheme.success;
  }

  String _statusLabel() {
    if (reminder.isOverdueByDate || reminder.isOverdueByMileage) {
      return 'Overdue';
    }
    if (reminder.isDueSoonByDate || reminder.isDueSoonByMileage) {
      return 'Due soon';
    }
    return 'Scheduled';
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor();

    return AppCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconBadge(icon: Icons.notifications_active, color: statusColor, size: 44),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      reminder.maintenanceTypeName,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${reminder.vehicleName} · ${reminder.licensePlate}',
                      style: const TextStyle(color: AppTheme.textSecondary),
                    ),
                  ],
                ),
              ),
              StatusChip(label: _statusLabel(), color: statusColor),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (reminder.nextDueDate != null)
                _InfoChip(
                  icon: Icons.calendar_today,
                  label: AppFormatters.date(reminder.nextDueDate),
                ),
              if (reminder.nextDueMileage != null)
                _InfoChip(
                  icon: Icons.speed,
                  label: 'Due at ${AppFormatters.mileage(reminder.nextDueMileage)}',
                ),
              if (reminder.mileageRemaining != null)
                _InfoChip(
                  icon: Icons.route,
                  label: reminder.mileageRemaining! >= 0
                      ? '${AppFormatters.mileage(reminder.mileageRemaining)} remaining'
                      : 'Overdue by ${AppFormatters.mileage(reminder.mileageRemaining!.abs())}',
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppTheme.textSecondary),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}
