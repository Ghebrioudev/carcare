import '../../../core/network/api_client.dart';
import '../models/maintenance_type.dart';

class MaintenanceTypeRepository {
  MaintenanceTypeRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<List<MaintenanceType>> fetchAll() async {
    final data = await _apiClient.get('/maintenance-types');
    final items = data['data'] as List<dynamic>;

    return items
        .map((item) => MaintenanceType.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}
