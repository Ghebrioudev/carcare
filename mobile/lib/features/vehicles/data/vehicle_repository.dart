import '../../../core/network/api_client.dart';
import '../models/vehicle.dart';

class VehicleRepository {
  VehicleRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<List<Vehicle>> fetchAll() async {
    final data = await _apiClient.get('/vehicles');
    final items = data['data'] as List<dynamic>;

    return items
        .map((item) => Vehicle.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<Vehicle> fetchById(int id) async {
    final data = await _apiClient.get('/vehicles/$id');
    final vehicleJson = data['data'] as Map<String, dynamic>? ?? data;

    return Vehicle.fromJson(vehicleJson);
  }

  Future<Vehicle> create(Map<String, dynamic> payload) async {
    final data = await _apiClient.post('/vehicles', data: payload);
    final vehicleJson = data['data'] as Map<String, dynamic>;

    return Vehicle.fromJson(vehicleJson);
  }

  Future<Vehicle> update(int id, Map<String, dynamic> payload) async {
    final data = await _apiClient.put('/vehicles/$id', data: payload);
    final vehicleJson = data['data'] as Map<String, dynamic>? ?? data;

    return Vehicle.fromJson(vehicleJson);
  }

  Future<void> delete(int id) async {
    await _apiClient.delete('/vehicles/$id');
  }
}
