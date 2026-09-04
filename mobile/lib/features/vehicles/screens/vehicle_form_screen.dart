import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/fuel_types.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_states.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/glass_text_field.dart';
import '../../../core/widgets/primary_button.dart';
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
  File? _selectedImage;
  String? _existingImageUrl;
  DateTime? _existingUpdatedAt;
  bool _removeImage = false;

  final ImagePicker _picker = ImagePicker();

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
      _existingImageUrl = vehicle.photoUrl;
      _existingUpdatedAt = vehicle.updatedAt;
    } on ApiException catch (error) {
      _errorMessage = error.message;
    } finally {
      if (mounted) {
        setState(() => _isFetching = false);
      }
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1400,
        maxHeight: 1400,
      );
      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
          _removeImage = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to select image: $e')),
        );
      }
    }
  }

  void _clearImage() {
    setState(() {
      _selectedImage = null;
      _removeImage = true;
    });
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
        await provider.updateVehicle(
          widget.vehicleId!,
          payload,
          photo: _selectedImage,
          removePhoto: _removeImage,
        );
        if (mounted) {
          context.pop();
        }
      } else {
        final vehicle = await provider.createVehicle(
          payload,
          photo: _selectedImage,
        );
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
      backgroundColor: AppTheme.canvas,
      appBar: AppBar(
        backgroundColor: AppTheme.canvas,
        title: Text(widget.isEditing ? 'Edit Vehicle' : 'New Vehicle'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => context.pop(),
        ),
      ),
      body: _isFetching
          ? const AppLoadingOverlay(message: 'Loading vehicle...')
          : SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 48),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildImagePicker(),
                    const SizedBox(height: 20),

                    // Primary Specs Glass Container
                    GlassCard(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Vehicle Identity',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 16),
                          GlassTextField(
                            controller: _brandController,
                            textCapitalization: TextCapitalization.words,
                            labelText: 'Brand / Make',
                            hintText: 'e.g. Porsche, Audi, BMW',
                            prefixIcon: const Icon(Icons.business_rounded),
                            validator: (value) =>
                                value == null || value.trim().isEmpty ? 'Required' : null,
                          ),
                          const SizedBox(height: 14),
                          GlassTextField(
                            controller: _modelController,
                            textCapitalization: TextCapitalization.words,
                            labelText: 'Model',
                            hintText: 'e.g. 911 Carrera, RS6, M3',
                            prefixIcon: const Icon(Icons.directions_car_rounded),
                            validator: (value) =>
                                value == null || value.trim().isEmpty ? 'Required' : null,
                          ),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              Expanded(
                                child: GlassTextField(
                                  controller: _yearController,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                  labelText: 'Model Year',
                                  hintText: '2024',
                                  prefixIcon: const Icon(Icons.calendar_today_rounded),
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'Required';
                                    }
                                    final year = int.tryParse(value);
                                    if (year == null) {
                                      return 'Invalid';
                                    }
                                    final maxYear = DateTime.now().year + 1;
                                    if (year < 1900 || year > maxYear) {
                                      return '1900 - $maxYear';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: GlassTextField(
                                  controller: _plateController,
                                  textCapitalization: TextCapitalization.characters,
                                  labelText: 'License Plate',
                                  hintText: 'AB-123-CD',
                                  prefixIcon: const Icon(Icons.pin_rounded),
                                  validator: (value) =>
                                      value == null || value.trim().isEmpty ? 'Required' : null,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Telemetry & Engineering Glass Container
                    GlassCard(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Engineering & Telemetry',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 16),
                          GlassTextField(
                            controller: _mileageController,
                            keyboardType: TextInputType.number,
                            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                            labelText: 'Current Mileage (km)',
                            hintText: '75000',
                            prefixIcon: const Icon(Icons.speed_rounded),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Required';
                              }
                              if (int.tryParse(value) == null) {
                                return 'Invalid odometer';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 14),
                          DropdownButtonFormField<String>(
                            initialValue: _fuelType,
                            dropdownColor: AppTheme.surface2,
                            style: const TextStyle(
                              color: AppTheme.textPrimary,
                              fontSize: 14.5,
                              fontWeight: FontWeight.w500,
                            ),
                            decoration: const InputDecoration(
                              labelText: 'Fuel & Powertrain System',
                              prefixIcon: Icon(Icons.local_gas_station_rounded),
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
                        ],
                      ),
                    ),

                    if (_errorMessage != null) ...[
                      const SizedBox(height: 16),
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
                      label: widget.isEditing ? 'Save Vehicle Specs' : 'Add to Garage',
                      icon: Icons.check_circle_outline_rounded,
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildImagePicker() {
    bool hasImage = _selectedImage != null ||
        (_existingImageUrl != null && !_removeImage);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          height: 180,
          decoration: BoxDecoration(
            color: const Color(0xFF101014),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: AppTheme.borderHighlighted,
              width: 1.0,
            ),
          ),
          child: hasImage
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(22),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (_selectedImage != null)
                        Image.file(_selectedImage!, fit: BoxFit.cover)
                      else if (_existingImageUrl != null)
                        CachedNetworkImage(
                          imageUrl: _existingImageUrl!,
                          cacheKey:
                              '$_existingImageUrl-${_existingUpdatedAt?.millisecondsSinceEpoch ?? ''}',
                          fit: BoxFit.cover,
                          placeholder: (context, url) => const Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppTheme.primaryLight,
                            ),
                          ),
                          errorWidget: (context, url, error) => const Icon(
                            Icons.error_outline_rounded,
                            size: 44,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      Positioned(
                        top: 10,
                        right: 10,
                        child: CircleAvatar(
                          backgroundColor: Colors.black87,
                          child: IconButton(
                            icon: const Icon(
                              Icons.close_rounded,
                              color: Colors.white,
                              size: 18,
                            ),
                            onPressed: _clearImage,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 54,
                        height: 54,
                        decoration: BoxDecoration(
                          color: AppTheme.surface2,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppTheme.border, width: 1),
                        ),
                        child: const Icon(
                          Icons.add_a_photo_outlined,
                          size: 26,
                          color: AppTheme.primaryLight,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Upload Vehicle Photo',
                        style: TextStyle(
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'JPG or PNG from camera or gallery',
                        style: TextStyle(
                          color: AppTheme.textMuted,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _pickImage(ImageSource.gallery),
                icon: const Icon(Icons.photo_library_outlined, size: 18),
                label: const Text('Gallery'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _pickImage(ImageSource.camera),
                icon: const Icon(Icons.camera_alt_outlined, size: 18),
                label: const Text('Camera'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
