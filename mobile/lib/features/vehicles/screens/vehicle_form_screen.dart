import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/fuel_types.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_states.dart';
import '../data/vehicle_repository.dart';
import '../providers/vehicle_provider.dart';

class VehicleFormScreen extends StatefulWidget {
  const VehicleFormScreen({super.key, this.vehicleId});

  final int? vehicleId;

  bool get isEditing => vehicleId != null;

  @override
  State<VehicleFormScreen> createState() => _VehicleFormScreenState();
}

class _VehicleFormScreenState extends State<VehicleFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _brandController = TextEditingController();
  final _modelController = TextEditingController();
  final _yearController = TextEditingController();
  final _plateController = TextEditingController();
  final _mileageController = TextEditingController();

  String _fuelType = fuelTypeOptions.first.value;
  bool _isLoading = false;
  bool _isFetching = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    if (widget.isEditing) {
      _loadVehicle();
    }
  }

  @override
  void dispose() {
    _brandController.dispose();
    _modelController.dispose();
    _yearController.dispose();
    _plateController.dispose();
    _mileageController.dispose();
    super.dispose();
  }

  Future<void> _loadVehicle() async {
    setState(() => _isFetching = true);

    try {
      final vehicle =
          await context.read<VehicleRepository>().fetchById(widget.vehicleId!);
      if (!mounted) return;

      _brandController.text = vehicle.brand;
      _modelController.text = vehicle.model;
      _yearController.text = '${vehicle.year}';
      _plateController.text = vehicle.licensePlate;
      _mileageController.text = '${vehicle.currentMileage}';
      _fuelType = vehicle.fuelType;
    } on ApiException catch (error) {
      _errorMessage = error.message;
    } finally {
      if (mounted) {
        setState(() => _isFetching = false);
      }
    }
  }

  Map<String, dynamic> _buildPayload() {
    return {
      'brand': _brandController.text.trim(),
      'model': _modelController.text.trim(),
      'year': int.parse(_yearController.text.trim()),
      'license_plate': _plateController.text.trim().toUpperCase(),
      'current_mileage': int.parse(_mileageController.text.trim()),
      'fuel_type': _fuelType,
    };
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final provider = context.read<VehicleProvider>();
      final payload = _buildPayload();

      if (widget.isEditing) {
        await provider.updateVehicle(widget.vehicleId!, payload);
        if (mounted) {
          context.pop();
        }
      } else {
        final vehicle = await provider.createVehicle(payload);
        if (mounted) {
          context.go('/vehicles/${vehicle!.id}');
        }
      }
    } on ApiException catch (error) {
      setState(() => _errorMessage = error.message);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Edit vehicle' : 'Add vehicle'),
      ),
      body: _isFetching
          ? const AppLoadingOverlay(message: 'Loading vehicle...')
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _brandController,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(
                        labelText: 'Brand',
                        prefixIcon: Icon(Icons.business_outlined),
                      ),
                      validator: (value) =>
                          value == null || value.trim().isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _modelController,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(
                        labelText: 'Model',
                        prefixIcon: Icon(Icons.directions_car_outlined),
                      ),
                      validator: (value) =>
                          value == null || value.trim().isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _yearController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: const InputDecoration(
                        labelText: 'Year',
                        prefixIcon: Icon(Icons.calendar_today_outlined),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Required';
                        }
                        final year = int.tryParse(value);
                        if (year == null) {
                          return 'Invalid year';
                        }
                        final maxYear = DateTime.now().year + 1;
                        if (year < 1900 || year > maxYear) {
                          return 'Year must be between 1900 and $maxYear';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _plateController,
                      textCapitalization: TextCapitalization.characters,
                      decoration: const InputDecoration(
                        labelText: 'License plate',
                        prefixIcon: Icon(Icons.pin_outlined),
                      ),
                      validator: (value) =>
                          value == null || value.trim().isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _mileageController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: const InputDecoration(
                        labelText: 'Current mileage (km)',
                        prefixIcon: Icon(Icons.speed_outlined),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Required';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Invalid mileage';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),
                    DropdownButtonFormField<String>(
                      initialValue: _fuelType,
                      decoration: const InputDecoration(
                        labelText: 'Fuel type',
                        prefixIcon: Icon(Icons.local_gas_station_outlined),
                      ),
                      items: fuelTypeOptions
                          .map(
                            (option) => DropdownMenuItem(
                              value: option.value,
                              child: Text(option.label),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _fuelType = value);
                        }
                      },
                    ),
                    if (_errorMessage != null) ...[
                      const SizedBox(height: 16),
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
                          : Text(widget.isEditing ? 'Save changes' : 'Create vehicle'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
