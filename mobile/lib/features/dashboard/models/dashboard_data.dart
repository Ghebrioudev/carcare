import '../../maintenance/models/maintenance.dart';
import '../../vehicles/models/vehicle.dart';

class DashboardData {
  const DashboardData({
    required this.vehiclesCount,
    required this.totalCost,
    this.nextReminder,
    this.recentMaintenances = const [],
  });

  final int vehiclesCount;
  final double totalCost;
  final NextReminder? nextReminder;
  final List<Maintenance> recentMaintenances;

  factory DashboardData.fromJson(Map<String, dynamic> json) {
    final rawRecent = json['recent_maintenances'];
    return DashboardData(
      vehiclesCount: json['vehicles_count'] as int? ?? 0,
      totalCost: double.tryParse('${json['total_cost']}') ?? 0,
      nextReminder: json['next_reminder'] is Map<String, dynamic>
          ? NextReminder.fromJson(json['next_reminder'] as Map<String, dynamic>)
          : null,
      recentMaintenances: rawRecent is List
          ? rawRecent
              .map((item) =>
                  Maintenance.fromJson(item as Map<String, dynamic>))
              .toList()
          : const [],
    );
  }
}

class NextReminder {
  const NextReminder({
    required this.maintenanceType,
    this.nextDueDate,
    this.nextDueMileage,
    required this.vehicle,
  });

  final String maintenanceType;
  final DateTime? nextDueDate;
  final int? nextDueMileage;
  final VehicleSummary vehicle;

  factory NextReminder.fromJson(Map<String, dynamic> json) {
    return NextReminder(
      maintenanceType: json['maintenance_type'] as String,
      nextDueDate: json['next_due_date'] != null
          ? DateTime.tryParse(json['next_due_date'] as String)
          : null,
      nextDueMileage: json['next_due_mileage'] as int?,
      vehicle: VehicleSummary.fromJson(json['vehicle'] as Map<String, dynamic>),
    );
  }
}

class VehicleSummary {
  const VehicleSummary({
    required this.id,
    required this.brand,
    required this.model,
    required this.licensePlate,
  });

  final int id;
  final String brand;
  final String model;
  final String licensePlate;

  String get displayName => '$brand $model';

  factory VehicleSummary.fromJson(Map<String, dynamic> json) {
    return VehicleSummary(
      id: json['id'] as int,
      brand: json['brand'] as String,
      model: json['model'] as String,
      licensePlate: json['license_plate'] as String,
    );
  }
}
