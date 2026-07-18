import 'package:flutter/foundation.dart';

import '../../../core/network/api_exception.dart';
import '../data/vehicle_repository.dart';
import '../models/vehicle.dart';

class VehicleProvider extends ChangeNotifier {
  VehicleProvider(this._vehicleRepository);

  final VehicleRepository _vehicleRepository;

  List<Vehicle> vehicles = [];
  bool isLoading = false;
  String? errorMessage;

  Future<void> loadVehicles() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      vehicles = await _vehicleRepository.fetchAll();
    } on ApiException catch (error) {
      errorMessage = error.message;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<Vehicle?> createVehicle(Map<String, dynamic> payload) async {
    try {
      final vehicle = await _vehicleRepository.create(payload);
      vehicles = [vehicle, ...vehicles];
      notifyListeners();
      return vehicle;
    } on ApiException catch (error) {
      errorMessage = error.message;
      notifyListeners();
      rethrow;
    }
  }

  Future<Vehicle?> updateVehicle(int id, Map<String, dynamic> payload) async {
    try {
      final vehicle = await _vehicleRepository.update(id, payload);
      vehicles = vehicles
          .map((item) => item.id == id ? vehicle : item)
          .toList(growable: false);
      notifyListeners();
      return vehicle;
    } on ApiException catch (error) {
      errorMessage = error.message;
      notifyListeners();
      rethrow;
    }
  }

  Future<bool> deleteVehicle(int id) async {
    try {
      await _vehicleRepository.delete(id);
      vehicles = vehicles.where((vehicle) => vehicle.id != id).toList();
      notifyListeners();
      return true;
    } on ApiException catch (error) {
      errorMessage = error.message;
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    errorMessage = null;
    notifyListeners();
  }
}
