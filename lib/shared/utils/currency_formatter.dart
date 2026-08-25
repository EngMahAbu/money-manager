import 'package:intl/intl.dart';

class CurrencyFormatter {
  static String format(double amount, String currencyCode) {
    final formatter = NumberFormat.simpleCurrency(name: currencyCode);
    return formatter.format(amount);
  }
}
