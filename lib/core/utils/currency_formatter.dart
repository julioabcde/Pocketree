import 'package:intl/intl.dart';

class CurrencyFormatter {
  static final Map<String, NumberFormat> _cache = {};

  static const String defaultCurrency = 'IDR';

  static const Map<String, CurrencyConfig> _configs = {
    'IDR': CurrencyConfig(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0),
    'USD': CurrencyConfig(locale: 'en_US', symbol: '\$', decimalDigits: 2),
    'SGD': CurrencyConfig(locale: 'en_SG', symbol: 'S\$', decimalDigits: 2),
    'MYR': CurrencyConfig(locale: 'ms_MY', symbol: 'RM ', decimalDigits: 2),
    'JPY': CurrencyConfig(locale: 'ja_JP', symbol: '¥', decimalDigits: 0),
  };

  static String format(double amount, [String currencyCode = defaultCurrency]) {
    final formatter = _getFormatter(currencyCode);
    return formatter.format(amount);
  }

  static NumberFormat _getFormatter(String currencyCode) {
    if (_cache.containsKey(currencyCode)) {
      return _cache[currencyCode]!;
    }

    final config = _configs[currencyCode];

    if (config == null) {
      final formatter = NumberFormat.currency(
        locale: 'en_US',
        symbol: '$currencyCode ',
        decimalDigits: 2,
      );
      _cache[currencyCode] = formatter;
      return formatter;
    }

    final formatter = NumberFormat.currency(
      locale: config.locale,
      symbol: config.symbol,
      decimalDigits: config.decimalDigits,
    );
    _cache[currencyCode] = formatter;
    return formatter;
  }
}

class CurrencyConfig {
  final String locale;
  final String symbol;
  final int decimalDigits;

  const CurrencyConfig({
    required this.locale,
    required this.symbol,
    required this.decimalDigits,
  });
}