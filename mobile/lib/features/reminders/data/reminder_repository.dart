import '../../../core/network/api_client.dart';
import '../models/reminder_entry.dart';

class ReminderRepository {
  ReminderRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<List<ReminderEntry>> fetchAll() async {
    final data = await _apiClient.get('/reminders');
    final items = data['data'] as List<dynamic>;

    return items
        .map((item) => ReminderEntry.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}
