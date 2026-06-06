import 'package:intl/intl.dart';

class CurrencyFormatter {
  CurrencyFormatter._();

  static String formatMRU(double amount) {
    return '${NumberFormat('#,##0', 'fr').format(amount)} MRU';
  }

  static String formatUSD(double amount) {
    return NumberFormat.currency(symbol: '\$', decimalDigits: 2).format(amount);
  }

  static String formatEUR(double amount) {
    return NumberFormat.currency(symbol: '€', decimalDigits: 2).format(amount);
  }

  static String format(double amount, String currency) {
    switch (currency.toUpperCase()) {
      case 'MRU':
        return formatMRU(amount);
      case 'USD':
        return formatUSD(amount);
      case 'EUR':
        return formatEUR(amount);
      default:
        return '${NumberFormat('#,##0.00').format(amount)} $currency';
    }
  }

  static double mruToUSD(double mru) => mru / 37.0;
  static double usdToMRU(double usd) => usd * 37.0;
}
