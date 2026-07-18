class MaintenanceType {
  const MaintenanceType({required this.id, required this.name});

  final int id;
  final String name;

  factory MaintenanceType.fromJson(Map<String, dynamic> json) {
    return MaintenanceType(
      id: json['id'] as int,
      name: json['name'] as String,
    );
  }
}
