import '../../vehicles/models/vehicle.dart';
import 'maintenance_item.dart';

class Maintenance {
  const Maintenance({
    required this.id,
    required this.vehicleId,
    required this.performedAt,
    required this.mileage,
    required this.totalCost,
    this.garageName,
    this.notes,
    this.items = const [],
    this.vehicle,
  });

  final int id;
  final int vehicleId;
  final DateTime performedAt;
  final int mileage;
  final double totalCost;
  final String? garageName;
  final String? notes;
  final List<MaintenanceItem> items;
  final Vehicle? vehicle;

  factory Maintenance.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'];
    return Maintenance(
      id: json['id'] as int,
      vehicleId: json['vehicle_id'] as int,
      performedAt: DateTime.parse(json['performed_at'] as String),
      mileage: json['mileage'] as int,
      totalCost: _parseDouble(json['total_cost']) ?? 0,
      garageName: json['garage_name'] as String?,
      notes: json['notes'] as String?,
      items: rawItems is List
          ? rawItems
              .map((item) =>
                  MaintenanceItem.fromJson(item as Map<String, dynamic>))
              .toList()
          : const [],
      vehicle: json['vehicle'] is Map<String, dynamic>
          ? Vehicle.fromJson(json['vehicle'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toPayload({required List<Map<String, dynamic>> items}) {
    return {
      'performed_at': performedAt.toIso8601String().split('T').first,
      'mileage': mileage,
      if (garageName != null && garageName!.isNotEmpty) 'garage_name': garageName,
      'total_cost': totalCost,
      if (notes != null && notes!.isNotEmpty) 'notes': notes,
      'items': items,
    };
  }

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    return double.tryParse('$value');
  }
}
