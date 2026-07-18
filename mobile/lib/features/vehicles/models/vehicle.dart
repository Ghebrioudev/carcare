class Vehicle {
  const Vehicle({
    required this.id,
    required this.brand,
    required this.model,
    required this.year,
    required this.licensePlate,
    required this.currentMileage,
    required this.fuelType,
    this.photoPath,
    this.maintenancesCount,
    this.createdAt,
    this.updatedAt,
  });

  final int id;
  final String brand;
  final String model;
  final int year;
  final String licensePlate;
  final int currentMileage;
  final String fuelType;
  final String? photoPath;
  final int? maintenancesCount;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  String get displayName => '$brand $model';

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      id: json['id'] as int,
      brand: json['brand'] as String,
      model: json['model'] as String,
      year: json['year'] as int,
      licensePlate: json['license_plate'] as String,
      currentMileage: json['current_mileage'] as int,
      fuelType: json['fuel_type'] as String,
      photoPath: json['photo_path'] as String?,
      maintenancesCount: json['maintenances_count'] as int?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'brand': brand,
      'model': model,
      'year': year,
      'license_plate': licensePlate,
      'current_mileage': currentMileage,
      'fuel_type': fuelType,
      if (photoPath != null) 'photo_path': photoPath,
    };
  }

  Vehicle copyWith({
    String? brand,
    String? model,
    int? year,
    String? licensePlate,
    int? currentMileage,
    String? fuelType,
    String? photoPath,
  }) {
    return Vehicle(
      id: id,
      brand: brand ?? this.brand,
      model: model ?? this.model,
      year: year ?? this.year,
      licensePlate: licensePlate ?? this.licensePlate,
      currentMileage: currentMileage ?? this.currentMileage,
      fuelType: fuelType ?? this.fuelType,
      photoPath: photoPath ?? this.photoPath,
      maintenancesCount: maintenancesCount,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
