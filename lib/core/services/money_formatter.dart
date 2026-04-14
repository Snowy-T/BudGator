import 'package:intl/intl.dart';

String formatEuroSmart(num value) {
  final asDouble = value.toDouble();
  final absolute = asDouble.abs();
  final hasFraction = (absolute - absolute.truncateToDouble()).abs() > 0.000001;
  final formatter = NumberFormat(hasFraction ? '#,##0.##' : '#,##0', 'de_DE');
  final sign = asDouble < 0 ? '-' : '';
  return '$sign€${formatter.format(absolute)}';
}

String formatInputAmount(num value) {
  final asDouble = value.toDouble();
  final absolute = asDouble.abs();
  final hasFraction = (absolute - absolute.truncateToDouble()).abs() > 0.000001;
  final formatter = NumberFormat(hasFraction ? '0.##' : '0', 'de_DE');
  return formatter.format(asDouble);
}
