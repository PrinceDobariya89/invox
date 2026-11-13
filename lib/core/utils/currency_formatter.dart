import 'package:intl/intl.dart';

class CurrencyFormatter {
  static final NumberFormat _inrFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 2,
  );

  static final NumberFormat _inrNoDecimals = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 0,
  );

  /// Format double to ₹ 1,50,000.00
  static String format(num amount) {
    return _inrFormat.format(amount);
  }

  /// Format double to ₹ 1,50,000 (no decimal cents if whole)
  static String formatCompact(num amount) {
    if (amount % 1 == 0) {
      return _inrNoDecimals.format(amount);
    }
    return _inrFormat.format(amount);
  }

  /// Short formatted text: 1.5L, 25K, etc.
  static String formatShort(num amount) {
    if (amount >= 10000000) {
      return '₹${(amount / 10000000).toStringAsFixed(2)} Cr';
    } else if (amount >= 100000) {
      return '₹${(amount / 100000).toStringAsFixed(2)} L';
    } else if (amount >= 1000) {
      return '₹${(amount / 1000).toStringAsFixed(1)} K';
    } else {
      return '₹${amount.toStringAsFixed(0)}';
    }
  }
}

