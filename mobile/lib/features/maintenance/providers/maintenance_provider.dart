import 'package:flutter/foundation.dart';

import '../../../core/network/api_exception.dart';
import '../data/maintenance_repository.dart';
import '../models/maintenance.dart';

class MaintenanceProvider extends ChangeNotifier {
  MaintenanceProvider(this._repository);

  final MaintenanceRepository _repository;

  List<Maintenance> maintenances = [];
  bool isLoading = false;
  String? errorMessage;

  Future<void> loadByVehicle(
    int vehicleId, {
    String? search,
    String? type,
    String? sort,
  }) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      maintenances = await _repository.fetchByVehicle(
        vehicleId,
        search: search,
        type: type,
        sort: sort,
      );
    } on ApiException catch (error) {
      errorMessage = error.message;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<Maintenance?> create(int vehicleId, Map<String, dynamic> payload) async {
    try {
      final maintenance = await _repository.create(vehicleId, payload);
      maintenances = [maintenance, ...maintenances];
      notifyListeners();
      return maintenance;
    } on ApiException catch (error) {
      errorMessage = error.message;
      notifyListeners();
      rethrow;
    }
  }

  Future<Maintenance?> update(int id, Map<String, dynamic> payload) async {
    try {
      final maintenance = await _repository.update(id, payload);
      maintenances = maintenances
          .map((item) => item.id == id ? maintenance : item)
          .toList(growable: false);
      notifyListeners();
      return maintenance;
    } on ApiException catch (error) {
      errorMessage = error.message;
      notifyListeners();
      rethrow;
    }
  }

  Future<bool> delete(int id) async {
    try {
      await _repository.delete(id);
      maintenances =
          maintenances.where((maintenance) => maintenance.id != id).toList();
      notifyListeners();
      return true;
    } on ApiException catch (error) {
      errorMessage = error.message;
      notifyListeners();
      return false;
    }
  }
}
