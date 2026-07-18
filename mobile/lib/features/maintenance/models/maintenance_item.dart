import 'maintenance_type.dart';

class MaintenanceItem {
  const MaintenanceItem({
    required this.id,
    required this.maintenanceTypeId,
    this.maintenanceType,
    this.nextDueDate,
    this.nextDueMileage,
    this.notes,
    this.cost,
  });

  final int id;
  final int maintenanceTypeId;
  final MaintenanceType? maintenanceType;
  final DateTime? nextDueDate;
  final int? nextDueMileage;
  final String? notes;
  final double? cost;

  factory MaintenanceItem.fromJson(Map<String, dynamic> json) {
    return MaintenanceItem(
      id: json['id'] as int,
      maintenanceTypeId: json['maintenance_type_id'] as int,
      maintenanceType: json['maintenance_type'] is Map<String, dynamic>
          ? MaintenanceType.fromJson(
              json['maintenance_type'] as Map<String, dynamic>,
            )
          : null,
      nextDueDate: json['next_due_date'] != null
          ? DateTime.tryParse(json['next_due_date'] as String)
          : null,
      nextDueMileage: json['next_due_mileage'] as int?,
      notes: json['notes'] as String?,
      cost: _parseDouble(json['cost']),
    );
  }

  Map<String, dynamic> toPayload() {
    return {
      'maintenance_type_id': maintenanceTypeId,
      if (nextDueDate != null)
        'next_due_date': nextDueDate!.toIso8601String().split('T').first,
      if (nextDueMileage != null) 'next_due_mileage': nextDueMileage,
      if (notes != null && notes!.isNotEmpty) 'notes': notes,
      if (cost != null) 'cost': cost,
    };
  }

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    return double.tryParse('$value');
  }
}
