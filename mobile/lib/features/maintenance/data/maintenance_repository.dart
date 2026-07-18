import '../../../core/network/api_client.dart';
import '../models/maintenance.dart';

class MaintenanceRepository {
  MaintenanceRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<List<Maintenance>> fetchByVehicle(int vehicleId) async {
    final data = await _apiClient.get('/vehicles/$vehicleId/maintenances');
    final items = data['data'] as List<dynamic>;

    return items
        .map((item) => Maintenance.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<Maintenance> fetchById(int id) async {
    final data = await _apiClient.get('/maintenances/$id');
    final maintenanceJson =
        data['data'] as Map<String, dynamic>? ?? data;

    return Maintenance.fromJson(maintenanceJson);
  }

  Future<Maintenance> create(int vehicleId, Map<String, dynamic> payload) async {
    final data =
        await _apiClient.post('/vehicles/$vehicleId/maintenances', data: payload);
    final maintenanceJson = data['data'] as Map<String, dynamic>;

    return Maintenance.fromJson(maintenanceJson);
  }

  Future<Maintenance> update(int id, Map<String, dynamic> payload) async {
    final data = await _apiClient.put('/maintenances/$id', data: payload);
    final maintenanceJson =
        data['data'] as Map<String, dynamic>? ?? data;

    return Maintenance.fromJson(maintenanceJson);
  }

  Future<void> delete(int id) async {
    await _apiClient.delete('/maintenances/$id');
  }
}
