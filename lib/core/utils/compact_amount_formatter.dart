class CompactAmountFormatter {
  static String format(
    double amount, {
    bool signed = false,
    String? prefix, 
  }) {
    final isNegative = amount < 0;
    final abs = amount.abs();

    String compact;

    if (abs >= 1e9) {
      compact = _formatCompact(abs / 1e9, 'B');
    } else if (abs >= 1e6) {
      compact = _formatCompact(abs / 1e6, 'M');
    } else if (abs >= 1e3) {
      compact = _formatCompact(abs / 1e3, 'k');
    } else {
      compact = abs % 1 == 0
          ? abs.toInt().toString()
          : abs.toStringAsFixed(1);
    }

    if (prefix != null) {
      compact = '$prefix$compact';
    }

    if (!signed || amount == 0) return compact;

    return isNegative ? '-$compact' : '+$compact';
  }

  static String formatSigned(double amount, {String? prefix}) {
    return format(amount, signed: true, prefix: prefix);
  }

  static String _formatCompact(double value, String suffix) {
    final formatted = value % 1 == 0
        ? value.toInt().toString()
        : value.toStringAsFixed(1);

    return '$formatted$suffix';
  }
}