import '../../../core/network/api_client.dart';
import '../models/dashboard_data.dart';

class DashboardRepository {
  DashboardRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<DashboardData> fetch() async {
    final data = await _apiClient.get('/dashboard');
    final dashboardJson = data['data'] as Map<String, dynamic>;

    return DashboardData.fromJson(dashboardJson);
  }
}
