import 'package:intl/intl.dart';

class Formatters {
  Formatters._();

  static final NumberFormat _currency =
      NumberFormat.currency(symbol: '\$', decimalDigits: 2);

  static String currency(double amount) => _currency.format(amount);

  static String signedCurrency(double amount) {
    final sign = amount < 0 ? '-' : '+';
    return '$sign${_currency.format(amount.abs())}';
  }
static String currencyShort(double amount) {
  final isWhole = amount == amount.roundToDouble();
  return NumberFormat.currency(symbol: '\$', decimalDigits: isWhole ? 0 : 2)
      .format(amount);
}

  static String monthYear(DateTime date) => DateFormat('MMM yyyy').format(date);
  static String transactionDate(DateTime date, {DateTime? now}) {
    final current = now ?? DateTime.now();
    final day = DateTime(date.year, date.month, date.day);
    final today = DateTime(current.year, current.month, current.day);
    final diff = today.difference(day).inDays;

    if (diff == 0) return 'Today, ${DateFormat.jm().format(date)}';
    if (diff == 1) return 'Yesterday';
    return DateFormat.MMMd().format(date);
  }

  static String greeting(DateTime now) {
    if (now.hour < 12) return 'Good morning';
    if (now.hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

static String fullDate(DateTime date, {DateTime? now}) {
  final current = now ?? DateTime.now();
  final formatted = DateFormat.yMMMd().format(date);
  final isToday = date.year == current.year &&
      date.month == current.month &&
      date.day == current.day;
  return isToday ? 'Today, $formatted' : formatted;
}

static String time(DateTime date) => DateFormat.jm().format(date);
}