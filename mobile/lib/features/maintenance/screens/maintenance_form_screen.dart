import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_states.dart';
import '../data/maintenance_repository.dart';
import '../data/maintenance_type_repository.dart';
import '../models/maintenance.dart';
import '../models/maintenance_type.dart';
import '../providers/maintenance_provider.dart';

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
    for (final item in _items) {
      item.dispose();
    }
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    setState(() => _isFetching = true);

    try {
      _types = await context.read<MaintenanceTypeRepository>().fetchAll();

      if (widget.isEditing) {
        final maintenance = await context
            .read<MaintenanceRepository>()
            .fetchById(widget.maintenanceId!);
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
          _items = [_ItemFormState(typeId: _types.first.id)];
        }
      } else {
        _items = [_ItemFormState(typeId: _types.first.id)];
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
    );
    if (picked != null) {
      setState(() => _performedAt = picked);
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
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Edit maintenance' : 'Add maintenance'),
      ),
      body: _isFetching
          ? const AppLoadingOverlay(message: 'Loading form...')
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Text(
                    'Visit details',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 12),
                  InkWell(
                    onTap: _pickDate,
                    borderRadius: BorderRadius.circular(14),
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Date performed',
                        prefixIcon: Icon(Icons.calendar_today_outlined),
                      ),
                      child: Text(
                        '${_performedAt.day.toString().padLeft(2, '0')}/'
                        '${_performedAt.month.toString().padLeft(2, '0')}/'
                        '${_performedAt.year}',
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _mileageController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: const InputDecoration(
                      labelText: 'Mileage at visit (km)',
                      prefixIcon: Icon(Icons.speed_outlined),
                    ),
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _garageController,
                    decoration: const InputDecoration(
                      labelText: 'Garage name (optional)',
                      prefixIcon: Icon(Icons.store_outlined),
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _totalCostController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Total cost (€)',
                      prefixIcon: Icon(Icons.euro),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Required';
                      if (double.tryParse(value) == null) return 'Invalid amount';
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _notesController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Visit notes (optional)',
                      prefixIcon: Icon(Icons.notes_outlined),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Operations',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                        ),
                      ),
                      TextButton.icon(
                        onPressed: _types.isEmpty
                            ? null
                            : () {
                                setState(() {
                                  _items.add(_ItemFormState(typeId: _types.first.id));
                                });
                              },
                        icon: const Icon(Icons.add),
                        label: const Text('Add'),
                      ),
                    ],
                  ),
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
                        onChanged: () => setState(() {}),
                      ),
                    );
                  }),
                  if (_errorMessage != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      _errorMessage!,
                      style: const TextStyle(color: AppTheme.danger),
                    ),
                  ],
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _submit,
                    child: _isLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(widget.isEditing ? 'Save changes' : 'Create maintenance'),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
    );
  }
}

class _ItemFormState {
  _ItemFormState({
    int? typeId,
    this.nextDueDate,
    String? nextDueMileage,
    String? notes,
    String? cost,
  })  : typeId = typeId,
        nextDueMileageController =
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
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Operation ${index + 1}',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const Spacer(),
                if (canRemove)
                  IconButton(
                    onPressed: onRemove,
                    icon: const Icon(Icons.close, color: AppTheme.danger),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<int>(
              value: item.typeId,
              decoration: const InputDecoration(labelText: 'Type'),
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
            TextFormField(
              controller: item.costController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Cost (optional)',
                prefixIcon: Icon(Icons.euro),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: item.notesController,
              decoration: const InputDecoration(
                labelText: 'Notes (optional)',
              ),
            ),
            const SizedBox(height: 12),
            InkWell(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate:
                      item.nextDueDate ?? DateTime.now().add(const Duration(days: 30)),
                  firstDate: DateTime.now().add(const Duration(days: 1)),
                  lastDate: DateTime.now().add(const Duration(days: 3650)),
                );
                if (picked != null) {
                  item.nextDueDate = picked;
                  onChanged();
                }
              },
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Next due date (optional)',
                  prefixIcon: Icon(Icons.event_outlined),
                ),
                child: Text(
                  item.nextDueDate == null
                      ? 'Not set'
                      : '${item.nextDueDate!.day.toString().padLeft(2, '0')}/'
                          '${item.nextDueDate!.month.toString().padLeft(2, '0')}/'
                          '${item.nextDueDate!.year}',
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: item.nextDueMileageController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(
                labelText: 'Next due mileage (optional)',
                prefixIcon: Icon(Icons.route_outlined),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
