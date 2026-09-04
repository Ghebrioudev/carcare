import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_states.dart';
import '../../../core/widgets/main_shell.dart';
import '../../../core/widgets/status_badge.dart';
import '../../maintenance/screens/maintenance_form_screen.dart';
import '../models/reminder_entry.dart';
import '../providers/reminders_provider.dart';

class RemindersScreen extends StatefulWidget {
  const RemindersScreen({super.key});

  @override
  State<RemindersScreen> createState() => _RemindersScreenState();
}

enum _ReminderTab { all, overdue, dueSoon, upcoming }

class _RemindersScreenState extends State<RemindersScreen> {
  _ReminderTab _currentTab = _ReminderTab.all;

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

    final overdueList = provider.reminders
        .where((r) => r.isOverdueByDate || r.isOverdueByMileage)
        .toList();
    final dueSoonList = provider.reminders
        .where((r) =>
            !r.isOverdueByDate &&
            !r.isOverdueByMileage &&
            (r.isDueSoonByDate || r.isDueSoonByMileage))
        .toList();
    final upcomingList = provider.reminders
        .where((r) =>
            !r.isOverdueByDate &&
            !r.isOverdueByMileage &&
            !r.isDueSoonByDate &&
            !r.isDueSoonByMileage)
        .toList();

    final List<ReminderEntry> displayedList;
    switch (_currentTab) {
      case _ReminderTab.all:
        displayedList = provider.reminders;
        break;
      case _ReminderTab.overdue:
        displayedList = overdueList;
        break;
      case _ReminderTab.dueSoon:
        displayedList = dueSoonList;
        break;
      case _ReminderTab.upcoming:
        displayedList = upcomingList;
        break;
    }

    return Scaffold(
      backgroundColor: AppTheme.canvas,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          backgroundColor: AppTheme.surface2,
          color: AppTheme.primaryLight,
          onRefresh: provider.loadReminders,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              const SliverToBoxAdapter(
                child: ScreenHeader(
                  title: 'Reminders',
                  subtitle: 'Scheduled services based on odometer and due dates.',
                ),
              ),

              // Summary Alert Banner
              if (provider.reminders.isNotEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
                    child: overdueList.isNotEmpty
                        ? Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppTheme.dangerGlow,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: AppTheme.danger.withValues(alpha: 0.35),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.warning_amber_rounded,
                                  color: AppTheme.danger,
                                  size: 24,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${overdueList.length} Action(s) Overdue',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w800,
                                          fontSize: 14.5,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      const Text(
                                        'Maintenance interval exceeded. Immediate service recommended.',
                                        style: TextStyle(
                                          color: AppTheme.textSecondary,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          )
                        : Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppTheme.successGlow,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: AppTheme.primary.withValues(alpha: 0.35),
                                width: 1,
                              ),
                            ),
                            child: const Row(
                              children: [
                                Icon(
                                  Icons.verified_rounded,
                                  color: AppTheme.primaryLight,
                                  size: 24,
                                ),
                                SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'All Systems Nominal',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w800,
                                          fontSize: 14.5,
                                        ),
                                      ),
                                      SizedBox(height: 2),
                                      Text(
                                        'No overdue service intervals detected.',
                                        style: TextStyle(
                                          color: AppTheme.textSecondary,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                  ),
                ),

              // Segmented Tab Filter
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildTabPill(
                          tab: _ReminderTab.all,
                          label: 'All',
                          count: provider.reminders.length,
                          color: AppTheme.primaryLight,
                        ),
                        const SizedBox(width: 8),
                        _buildTabPill(
                          tab: _ReminderTab.overdue,
                          label: 'Overdue',
                          count: overdueList.length,
                          color: AppTheme.danger,
                        ),
                        const SizedBox(width: 8),
                        _buildTabPill(
                          tab: _ReminderTab.dueSoon,
                          label: 'Due Soon',
                          count: dueSoonList.length,
                          color: AppTheme.warning,
                        ),
                        const SizedBox(width: 8),
                        _buildTabPill(
                          tab: _ReminderTab.upcoming,
                          label: 'Upcoming',
                          count: upcomingList.length,
                          color: AppTheme.secondary,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              if (provider.isLoading && provider.reminders.isEmpty)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: AppLoadingOverlay(message: 'Analyzing vehicle schedules...'),
                )
              else if (provider.errorMessage != null && provider.reminders.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: AppErrorView(
                    message: provider.errorMessage!,
                    onRetry: provider.loadReminders,
                  ),
                )
              else if (displayedList.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: AppEmptyView(
                    title: 'No Reminders Found',
                    subtitle: _currentTab == _ReminderTab.all
                        ? 'When service intervals or due dates are scheduled, they will appear here.'
                        : 'No reminders found for the selected filter.',
                    icon: Icons.notifications_off_outlined,
                    action: ElevatedButton(
                      onPressed: () => context.go('/vehicles'),
                      child: const Text('View Vehicles'),
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
                  sliver: SliverList.separated(
                    itemCount: displayedList.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final reminder = displayedList[index];
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

  Widget _buildTabPill({
    required _ReminderTab tab,
    required String label,
    required int count,
    required Color color,
  }) {
    final isSelected = _currentTab == tab;

    return InkWell(
      onTap: () => setState(() => _currentTab = tab),
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.18) : AppTheme.surface1,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? color : AppTheme.border,
            width: 1.0,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : AppTheme.textSecondary,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                fontSize: 13,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: isSelected ? color : AppTheme.surface2,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '$count',
                style: TextStyle(
                  color: isSelected ? Colors.white : AppTheme.textMuted,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
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
    return AppTheme.primaryLight;
  }

  String _statusLabel() {
    if (reminder.isOverdueByDate || reminder.isOverdueByMileage) {
      return 'OVERDUE';
    }
    if (reminder.isDueSoonByDate || reminder.isDueSoonByMileage) {
      return 'DUE SOON';
    }
    return 'SCHEDULED';
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor();
    final statusLabel = _statusLabel();
    final icon = getOperationIcon(reminder.maintenanceTypeName);

    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(18),
      borderColor: (reminder.isOverdueByDate || reminder.isOverdueByMileage)
          ? AppTheme.danger.withValues(alpha: 0.3)
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: statusColor.withValues(alpha: 0.3),
                    width: 1.0,
                  ),
                ),
                child: Icon(icon, color: statusColor, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      reminder.maintenanceTypeName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textPrimary,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${reminder.vehicleName} · ${reminder.licensePlate}',
                      style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 12.5,
                      ),
                    ),
                  ],
                ),
              ),
              StatusBadge(
                label: statusLabel,
                color: statusColor,
                showDot: true,
              ),
            ],
          ),

          const SizedBox(height: 14),
          const Divider(),
          const SizedBox(height: 12),

          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (reminder.nextDueDate != null)
                _SchedulePill(
                  icon: Icons.calendar_today_rounded,
                  label: AppFormatters.date(reminder.nextDueDate),
                  color: (reminder.isOverdueByDate)
                      ? AppTheme.danger
                      : AppTheme.textSecondary,
                ),
              if (reminder.nextDueMileage != null)
                _SchedulePill(
                  icon: Icons.speed_rounded,
                  label: 'Due at ${AppFormatters.mileage(reminder.nextDueMileage)}',
                  color: (reminder.isOverdueByMileage)
                      ? AppTheme.danger
                      : AppTheme.textSecondary,
                ),
              if (reminder.mileageRemaining != null)
                _SchedulePill(
                  icon: Icons.route_rounded,
                  label: reminder.mileageRemaining! >= 0
                      ? '${AppFormatters.mileage(reminder.mileageRemaining)} remaining'
                      : 'Overdue by ${AppFormatters.mileage(reminder.mileageRemaining!.abs())}',
                  color: reminder.mileageRemaining! >= 0
                      ? AppTheme.primaryLight
                      : AppTheme.danger,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SchedulePill extends StatelessWidget {
  const _SchedulePill({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.surface2,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.border, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
