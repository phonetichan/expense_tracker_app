class CurrencyUtils {
  /// Formats raw double amounts into a readable currency string (e.g. 1.2M, 50K, 500).
  ///
  /// [showPrefix] adds '+ ' or '- ' based on [isIncome].
  /// [symbol] defaults to 'Ks'.
  static String formatAmount(
    double amount, {
    bool showPrefix = false,
    bool isIncome = true,
    String symbol = 'Ks',
  }) {
    String formatted;
    if (amount >= 1000000) {
      final value = amount / 1000000;
      formatted =
          '${value.toStringAsFixed(value.truncateToDouble() == value ? 0 : 1)}M';
    } else if (amount >= 1000) {
      final value = amount / 1000;
      formatted =
          '${value.toStringAsFixed(value.truncateToDouble() == value ? 0 : 1)}K';
    } else {
      formatted = amount.toStringAsFixed(0);
    }

    final prefix = showPrefix ? (isIncome ? '+ ' : '- ') : '';
    return '$prefix$symbol $formatted';
  }
}
