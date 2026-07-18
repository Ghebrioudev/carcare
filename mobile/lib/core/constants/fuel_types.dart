class FuelTypeOption {
  const FuelTypeOption({required this.value, required this.label});

  final String value;
  final String label;
}

const fuelTypeOptions = [
  FuelTypeOption(value: 'gasoline', label: 'Essence'),
  FuelTypeOption(value: 'diesel', label: 'Diesel'),
  FuelTypeOption(value: 'electric', label: 'Électrique'),
  FuelTypeOption(value: 'hybrid', label: 'Hybride'),
  FuelTypeOption(value: 'lpg', label: 'GPL'),
];

String fuelTypeLabel(String value) {
  for (final option in fuelTypeOptions) {
    if (option.value == value) {
      return option.label;
    }
  }
  return value;
}
