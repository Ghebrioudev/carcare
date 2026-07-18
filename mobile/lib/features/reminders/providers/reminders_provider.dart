import 'package:flutter/foundation.dart';

import '../../../core/network/api_exception.dart';
import '../data/reminder_repository.dart';
import '../models/reminder_entry.dart';

class RemindersProvider extends ChangeNotifier {
  RemindersProvider({
    required ReminderRepository reminderRepository,
  })  : _reminderRepository = reminderRepository;

  final ReminderRepository _reminderRepository;

  List<ReminderEntry> reminders = [];
  bool isLoading = false;
  String? errorMessage;

  Future<void> loadReminders() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final entries = await _reminderRepository.fetchAll();
      entries.sort((a, b) => a.urgencyScore.compareTo(b.urgencyScore));
      reminders = entries;
    } on ApiException catch (error) {
      errorMessage = error.message;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
