import 'package:flutter/foundation.dart';

import '../../../core/network/api_exception.dart';
import '../../maintenance/data/maintenance_repository.dart';
import '../../maintenance/models/maintenance.dart';
import '../../vehicles/data/vehicle_repository.dart';
import '../../vehicles/models/vehicle.dart';
import '../models/reminder_entry.dart';

class RemindersProvider extends ChangeNotifier {
  RemindersProvider({
    required VehicleRepository vehicleRepository,
    required MaintenanceRepository maintenanceRepository,
  })  : _vehicleRepository = vehicleRepository,
        _maintenanceRepository = maintenanceRepository;

  final VehicleRepository _vehicleRepository;
  final MaintenanceRepository _maintenanceRepository;

  List<ReminderEntry> reminders = [];
  bool isLoading = false;
  String? errorMessage;

  Future<void> loadReminders() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final vehicles = await _vehicleRepository.fetchAll();
      final entries = <ReminderEntry>[];

      await Future.wait(
        vehicles.map((vehicle) async {
          final maintenances =
              await _maintenanceRepository.fetchByVehicle(vehicle.id);
          entries.addAll(_extractReminders(vehicle, maintenances));
        }),
      );

      entries.sort((a, b) => a.urgencyScore.compareTo(b.urgencyScore));
      reminders = entries;
    } on ApiException catch (error) {
      errorMessage = error.message;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  List<ReminderEntry> _extractReminders(
    Vehicle vehicle,
    List<Maintenance> maintenances,
  ) {
    final entries = <ReminderEntry>[];

    for (final maintenance in maintenances) {
      for (final item in maintenance.items) {
        if (item.nextDueDate == null && item.nextDueMileage == null) {
          continue;
        }

        entries.add(
          ReminderEntry(
            itemId: item.id,
            maintenanceId: maintenance.id,
            vehicleId: vehicle.id,
            vehicleName: vehicle.displayName,
            licensePlate: vehicle.licensePlate,
            currentMileage: vehicle.currentMileage,
            maintenanceTypeName:
                item.maintenanceType?.name ?? 'Maintenance',
            nextDueDate: item.nextDueDate,
            nextDueMileage: item.nextDueMileage,
          ),
        );
      }
    }

    return entries;
  }
}
