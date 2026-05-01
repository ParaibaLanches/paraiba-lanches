import 'package:intl/intl.dart';

class CurrencyFormatter {
  CurrencyFormatter._();

  static final _formatter = NumberFormat.currency(
    locale: 'pt_BR',
    symbol: 'R\$',
  );

  static String format(double value) => _formatter.format(value);

  static String formatCompact(double value) {
    if (value == value.roundToDouble()) {
      return 'R\$ ${value.toStringAsFixed(0)}';
    }
    return format(value);
  }
}
