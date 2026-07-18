import 'package:intl/intl.dart';

class AppFormatters {
  static final _currency = NumberFormat.currency(symbol: '€', decimalDigits: 2);
  static final _date = DateFormat('dd MMM yyyy');
  static final _shortDate = DateFormat('dd/MM/yyyy');

  static String currency(dynamic value) {
    if (value == null) return '—';
    final parsed = value is num ? value.toDouble() : double.tryParse('$value');
    if (parsed == null) return '—';
    return _currency.format(parsed);
  }

  static String date(DateTime? value) {
    if (value == null) return '—';
    return _date.format(value);
  }

  static String shortDate(DateTime? value) {
    if (value == null) return '—';
    return _shortDate.format(value);
  }

  static String mileage(int? value) {
    if (value == null) return '—';
    return '${NumberFormat.decimalPattern().format(value)} km';
  }
}
