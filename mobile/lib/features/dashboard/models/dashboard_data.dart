import '../../maintenance/models/maintenance.dart';

class DashboardData {
  const DashboardData({
    required this.vehiclesCount,
    required this.totalCost,
    this.nextReminder,
    this.recentMaintenances = const [],
    this.monthlyCosts = const [],
    this.categoryCosts = const [],
  });

  final int vehiclesCount;
  final double totalCost;
  final NextReminder? nextReminder;
  final List<Maintenance> recentMaintenances;
  final List<MonthlyCost> monthlyCosts;
  final List<CategoryCost> categoryCosts;

  factory DashboardData.fromJson(Map<String, dynamic> json) {
    final rawRecent = json['recent_maintenances'];
    final rawMonthly = json['monthly_costs'];
    final rawCategory = json['category_costs'];
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
      monthlyCosts: rawMonthly is List
          ? rawMonthly
              .map((item) => MonthlyCost.fromJson(item as Map<String, dynamic>))
              .toList()
          : const [],
      categoryCosts: rawCategory is List
          ? rawCategory
              .map((item) => CategoryCost.fromJson(item as Map<String, dynamic>))
              .toList()
          : const [],
    );
  }
}

class MonthlyCost {
  const MonthlyCost({required this.month, required this.cost});

  final String month;
  final double cost;

  factory MonthlyCost.fromJson(Map<String, dynamic> json) {
    return MonthlyCost(
      month: json['month'] as String? ?? '',
      cost: double.tryParse('${json['cost']}') ?? 0.0,
    );
  }
}

class CategoryCost {
  const CategoryCost({required this.category, required this.cost});

  final String category;
  final double cost;

  factory CategoryCost.fromJson(Map<String, dynamic> json) {
    return CategoryCost(
      category: json['category'] as String? ?? '',
      cost: double.tryParse('${json['cost']}') ?? 0.0,
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
