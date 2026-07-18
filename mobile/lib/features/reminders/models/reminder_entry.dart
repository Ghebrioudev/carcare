class ReminderEntry {
  const ReminderEntry({
    required this.itemId,
    required this.maintenanceId,
    required this.vehicleId,
    required this.vehicleName,
    required this.licensePlate,
    required this.currentMileage,
    required this.maintenanceTypeName,
    this.nextDueDate,
    this.nextDueMileage,
  });

  final int itemId;
  final int maintenanceId;
  final int vehicleId;
  final String vehicleName;
  final String licensePlate;
  final int currentMileage;
  final String maintenanceTypeName;
  final DateTime? nextDueDate;
  final int? nextDueMileage;

  factory ReminderEntry.fromJson(Map<String, dynamic> json) {
    return ReminderEntry(
      itemId: json['item_id'] as int,
      maintenanceId: json['maintenance_id'] as int,
      vehicleId: json['vehicle_id'] as int,
      vehicleName: json['vehicle_name'] as String,
      licensePlate: json['license_plate'] as String,
      currentMileage: json['current_mileage'] as int,
      maintenanceTypeName: json['maintenance_type_name'] as String,
      nextDueDate: json['next_due_date'] != null
          ? DateTime.tryParse(json['next_due_date'] as String)
          : null,
      nextDueMileage: json['next_due_mileage'] as int?,
    );
  }

  bool get hasDateReminder => nextDueDate != null;
  bool get hasMileageReminder => nextDueMileage != null;

  bool get isOverdueByDate {
    if (nextDueDate == null) return false;
    final today = DateTime.now();
    final due = DateTime(nextDueDate!.year, nextDueDate!.month, nextDueDate!.day);
    final now = DateTime(today.year, today.month, today.day);
    return due.isBefore(now);
  }

  bool get isDueSoonByDate {
    if (nextDueDate == null || isOverdueByDate) return false;
    final days = nextDueDate!.difference(DateTime.now()).inDays;
    return days <= 30;
  }

  bool get isOverdueByMileage =>
      nextDueMileage != null && currentMileage >= nextDueMileage!;

  bool get isDueSoonByMileage {
    if (nextDueMileage == null || isOverdueByMileage) return false;
    return nextDueMileage! - currentMileage <= 1000;
  }

  int? get mileageRemaining =>
      nextDueMileage != null ? nextDueMileage! - currentMileage : null;

  int get urgencyScore {
    var score = 1000;
    if (isOverdueByDate) score -= 500;
    if (isOverdueByMileage) score -= 500;
    if (nextDueDate != null) {
      score += nextDueDate!.difference(DateTime.now()).inDays;
    }
    if (mileageRemaining != null) {
      score += mileageRemaining!.clamp(-500, 500);
    }
    return score;
  }
}
