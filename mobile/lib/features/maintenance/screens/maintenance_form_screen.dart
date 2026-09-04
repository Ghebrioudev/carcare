import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_states.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/glass_text_field.dart';
import '../../../core/widgets/primary_button.dart';
import '../data/maintenance_repository.dart';
import '../data/maintenance_type_repository.dart';
import '../models/maintenance_type.dart';
import '../providers/maintenance_provider.dart';

IconData getOperationIcon(String name) {
  final lower = name.toLowerCase();
  if (lower.contains('oil') || lower.contains('huile') || lower.contains('vidange')) {
    return Icons.water_drop_rounded;
  }
  if (lower.contains('filter') || lower.contains('filtre')) {
    return Icons.filter_alt_rounded;
  }
  if (lower.contains('brake') || lower.contains('frein')) {
    return Icons.disc_full_rounded;
  }
  if (lower.contains('tire') || lower.contains('pneu')) {
    return Icons.album_rounded;
  }
  if (lower.contains('battery') || lower.contains('batterie')) {
    return Icons.battery_charging_full_rounded;
  }
  if (lower.contains('ac') || lower.contains('clim') || lower.contains('air')) {
    return Icons.ac_unit_rounded;
  }
  if (lower.contains('inspection') || lower.contains('contrôle')) {
    return Icons.fact_check_rounded;
  }
  if (lower.contains('insurance') || lower.contains('assurance')) {
    return Icons.verified_user_rounded;
  }
  return Icons.build_circle_rounded;
}

class MaintenanceFormScreen extends StatefulWidget {
  const MaintenanceFormScreen({
    super.key,
    this.vehicleId,
    this.maintenanceId,
  });

  final int? vehicleId;
  final int? maintenanceId;

  bool get isEditing => maintenanceId != null;

  @override
  State<MaintenanceFormScreen> createState() => _MaintenanceFormScreenState();
}

class _MaintenanceFormScreenState extends State<MaintenanceFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _garageController = TextEditingController();
  final _notesController = TextEditingController();
  final _mileageController = TextEditingController();
  final _totalCostController = TextEditingController();
  final _scrollController = ScrollController();

  DateTime _performedAt = DateTime.now();
  List<MaintenanceType> _types = [];
  List<_ItemFormState> _items = [_ItemFormState()];
  bool _isLoading = false;
  bool _isFetching = false;
  String? _errorMessage;
  int? _vehicleId;

  @override
  void initState() {
    super.initState();
    _vehicleId = widget.vehicleId;
    _loadInitialData();
  }

  @override
  void dispose() {
    _garageController.dispose();
    _notesController.dispose();
    _mileageController.dispose();
    _totalCostController.dispose();
    _scrollController.dispose();
    for (final item in _items) {
      item.dispose();
    }
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    setState(() => _isFetching = true);

    try {
      final typeRepo = context.read<MaintenanceTypeRepository>();
      final maintenanceRepo = context.read<MaintenanceRepository>();

      _types = await typeRepo.fetchAll();

      if (widget.isEditing) {
        final maintenance =
            await maintenanceRepo.fetchById(widget.maintenanceId!);
        _vehicleId = maintenance.vehicleId;
        _performedAt = maintenance.performedAt;
        _mileageController.text = '${maintenance.mileage}';
        _garageController.text = maintenance.garageName ?? '';
        _notesController.text = maintenance.notes ?? '';
        _totalCostController.text = '${maintenance.totalCost}';

        for (final item in _items) {
          item.dispose();
        }
        _items = maintenance.items
            .map(
              (item) => _ItemFormState(
                typeId: item.maintenanceTypeId,
                nextDueDate: item.nextDueDate,
                nextDueMileage: item.nextDueMileage?.toString(),
                notes: item.notes,
                cost: item.cost?.toString(),
              ),
            )
            .toList();
        if (_items.isEmpty) {
          _items = [_ItemFormState(typeId: _types.isNotEmpty ? _types.first.id : null)];
        }
      } else {
        _items = [_ItemFormState(typeId: _types.isNotEmpty ? _types.first.id : null)];
      }
    } on ApiException catch (error) {
      _errorMessage = error.message;
    } finally {
      if (mounted) setState(() => _isFetching = false);
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _performedAt,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppTheme.primaryLight,
              surface: AppTheme.surface1,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _performedAt = picked);
    }
  }

  void _calculateAutoTotal() {
    double sum = 0.0;
    bool hasAnyCost = false;
    for (final item in _items) {
      final c = double.tryParse(item.costController.text.trim());
      if (c != null) {
        sum += c;
        hasAnyCost = true;
      }
    }
    if (hasAnyCost && _totalCostController.text.trim().isEmpty) {
      _totalCostController.text = sum.toStringAsFixed(2);
    }
  }

  Map<String, dynamic> _buildPayload() {
    return {
      'performed_at': _performedAt.toIso8601String().split('T').first,
      'mileage': int.parse(_mileageController.text.trim()),
      if (_garageController.text.trim().isNotEmpty)
        'garage_name': _garageController.text.trim(),
      'total_cost': double.parse(_totalCostController.text.trim()),
      if (_notesController.text.trim().isNotEmpty)
        'notes': _notesController.text.trim(),
      'items': _items.map((item) => item.toPayload()).toList(),
    };
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final provider = context.read<MaintenanceProvider>();
      final payload = _buildPayload();

      if (widget.isEditing) {
        await provider.update(widget.maintenanceId!, payload);
        if (mounted) context.pop();
      } else {
        final maintenance =
            await provider.create(_vehicleId!, payload);
        if (mounted) {
          context.go('/maintenances/${maintenance!.id}');
        }
      }
    } on ApiException catch (error) {
      setState(() => _errorMessage = error.message);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.canvas,
      appBar: AppBar(
        backgroundColor: AppTheme.canvas,
        title: Text(widget.isEditing ? 'Edit Service Record' : 'Log Service Visit'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => context.pop(),
        ),
      ),
      body: _isFetching
          ? const AppLoadingOverlay(message: 'Loading service form...')
          : Form(
              key: _formKey,
              child: ListView(
                controller: _scrollController,
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 48),
                children: [
                  // Section 1: Visit Telemetry
                  GlassCard(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Visit Telemetry',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        InkWell(
                          onTap: _pickDate,
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 16,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.surface1,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: AppTheme.border,
                                width: 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.calendar_today_rounded,
                                  color: AppTheme.textSecondary,
                                  size: 19,
                                ),
                                const SizedBox(width: 14),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Service Date',
                                      style: TextStyle(
                                        color: AppTheme.textMuted,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      AppFormatters.date(_performedAt),
                                      style: const TextStyle(
                                        color: AppTheme.textPrimary,
                                        fontSize: 14.5,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        GlassTextField(
                          controller: _mileageController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          labelText: 'Odometer at Visit (km)',
                          hintText: 'e.g. 72000',
                          prefixIcon: const Icon(Icons.speed_rounded),
                          validator: (value) =>
                              value == null || value.isEmpty ? 'Required' : null,
                        ),
                        const SizedBox(height: 14),
                        GlassTextField(
                          controller: _garageController,
                          labelText: 'Garage / Service Center (Optional)',
                          hintText: 'e.g. Official Dealer, QuickLube',
                          prefixIcon: const Icon(Icons.store_rounded),
                        ),
                        const SizedBox(height: 14),
                        GlassTextField(
                          controller: _totalCostController,
                          keyboardType:
                              const TextInputType.numberWithOptions(decimal: true),
                          labelText: 'Total Cost (€)',
                          hintText: '0.00',
                          prefixIcon: const Icon(Icons.euro_rounded),
                          validator: (value) {
                            if (value == null || value.isEmpty) return 'Required';
                            if (double.tryParse(value) == null) return 'Invalid amount';
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),
                        GlassTextField(
                          controller: _notesController,
                          maxLines: 2,
                          labelText: 'General Service Notes (Optional)',
                          hintText: 'Summary of diagnostics and inspections...',
                          prefixIcon: const Icon(Icons.notes_rounded),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Section 2: Operations
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Operations & Parts',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.textPrimary,
                          letterSpacing: -0.3,
                        ),
                      ),
                      TextButton.icon(
                        onPressed: _types.isEmpty
                            ? null
                            : () {
                                setState(() {
                                  _items.add(
                                    _ItemFormState(typeId: _types.first.id),
                                  );
                                });
                                WidgetsBinding.instance.addPostFrameCallback((_) {
                                  _scrollController.animateTo(
                                    _scrollController.position.maxScrollExtent,
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeOut,
                                  );
                                });
                              },
                        icon: const Icon(Icons.add_rounded, size: 18),
                        label: const Text('Add Operation'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  ..._items.asMap().entries.map((entry) {
                    final index = entry.key;
                    final item = entry.value;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _OperationCard(
                        index: index,
                        item: item,
                        types: _types,
                        canRemove: _items.length > 1,
                        onRemove: () {
                          setState(() {
                            item.dispose();
                            _items.removeAt(index);
                          });
                        },
                        onChanged: () {
                          _calculateAutoTotal();
                          setState(() {});
                        },
                      ),
                    );
                  }),

                  if (_errorMessage != null) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppTheme.dangerGlow,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: AppTheme.danger.withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(
                          color: AppTheme.danger,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 24),
                  PrimaryButton(
                    onPressed: _isLoading ? null : _submit,
                    isLoading: _isLoading,
                    label: widget.isEditing ? 'Save Changes' : 'Record Service Visit',
                    icon: Icons.check_rounded,
                  ),
                ],
              ),
            ),
    );
  }
}

class _ItemFormState {
  _ItemFormState({
    this.typeId,
    this.nextDueDate,
    String? nextDueMileage,
    String? notes,
    String? cost,
  })  : nextDueMileageController =
            TextEditingController(text: nextDueMileage ?? ''),
        notesController = TextEditingController(text: notes ?? ''),
        costController = TextEditingController(text: cost ?? '');

  int? typeId;
  DateTime? nextDueDate;
  final TextEditingController nextDueMileageController;
  final TextEditingController notesController;
  final TextEditingController costController;

  void dispose() {
    nextDueMileageController.dispose();
    notesController.dispose();
    costController.dispose();
  }

  Map<String, dynamic> toPayload() {
    return {
      'maintenance_type_id': typeId,
      if (nextDueDate != null)
        'next_due_date': nextDueDate!.toIso8601String().split('T').first,
      if (nextDueMileageController.text.trim().isNotEmpty)
        'next_due_mileage':
            int.parse(nextDueMileageController.text.trim()),
      if (notesController.text.trim().isNotEmpty)
        'notes': notesController.text.trim(),
      if (costController.text.trim().isNotEmpty)
        'cost': double.parse(costController.text.trim()),
    };
  }
}

class _OperationCard extends StatelessWidget {
  const _OperationCard({
    required this.index,
    required this.item,
    required this.types,
    required this.canRemove,
    required this.onRemove,
    required this.onChanged,
  });

  final int index;
  final _ItemFormState item;
  final List<MaintenanceType> types;
  final bool canRemove;
  final VoidCallback onRemove;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final selectedType = types.cast<MaintenanceType?>().firstWhere(
          (t) => t?.id == item.typeId,
          orElse: () => null,
        );
    final icon = getOperationIcon(selectedType?.name ?? '');

    return GlassCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppTheme.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: AppTheme.primaryLight, size: 18),
              ),
              const SizedBox(width: 10),
              Text(
                'Operation #${index + 1}',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
              const Spacer(),
              if (canRemove)
                IconButton(
                  onPressed: onRemove,
                  icon: const Icon(
                    Icons.close_rounded,
                    color: AppTheme.danger,
                    size: 20,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),

          // Dropdown type selector
          DropdownButtonFormField<int>(
            initialValue: item.typeId,
            dropdownColor: AppTheme.surface2,
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 14.5,
              fontWeight: FontWeight.w500,
            ),
            decoration: const InputDecoration(
              labelText: 'Service Category',
              prefixIcon: Icon(Icons.category_rounded),
            ),
            items: types
                .map(
                  (type) => DropdownMenuItem(
                    value: type.id,
                    child: Text(type.name),
                  ),
                )
                .toList(),
            onChanged: (value) {
              item.typeId = value;
              onChanged();
            },
            validator: (value) => value == null ? 'Required' : null,
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: GlassTextField(
                  controller: item.costController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  labelText: 'Cost (€)',
                  hintText: '0.00',
                  prefixIcon: const Icon(Icons.euro_rounded),
                  onChanged: (_) => onChanged(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GlassTextField(
                  controller: item.notesController,
                  labelText: 'Part / Brand',
                  hintText: 'e.g. Castrol 5W30',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Next Due Reminders section
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.surface1,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppTheme.border, width: 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Next Due Reminder',
                  style: TextStyle(
                    color: AppTheme.textMuted,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: item.nextDueDate ??
                                DateTime.now().add(const Duration(days: 90)),
                            firstDate: DateTime.now().add(const Duration(days: 1)),
                            lastDate: DateTime.now().add(const Duration(days: 3650)),
                            builder: (context, child) {
                              return Theme(
                                data: Theme.of(context).copyWith(
                                  colorScheme: const ColorScheme.dark(
                                    primary: AppTheme.primaryLight,
                                    surface: AppTheme.surface1,
                                  ),
                                ),
                                child: child!,
                              );
                            },
                          );
                          if (picked != null) {
                            item.nextDueDate = picked;
                            onChanged();
                          }
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.surface2,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppTheme.border, width: 1),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.calendar_today_rounded,
                                size: 15,
                                color: AppTheme.warning,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  item.nextDueDate == null
                                      ? 'Due Date'
                                      : AppFormatters.shortDate(item.nextDueDate),
                                  style: TextStyle(
                                    color: item.nextDueDate == null
                                        ? AppTheme.textMuted
                                        : AppTheme.textPrimary,
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: GlassTextField(
                        controller: item.nextDueMileageController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        labelText: 'Due Mileage',
                        hintText: '85000',
                        prefixIcon: const Icon(Icons.speed_rounded, size: 16),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
