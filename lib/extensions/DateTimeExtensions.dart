import 'package:intl/intl.dart';

extension DateTimeExtension on DateTime {
  String toGermanDate() {
    return DateFormat('dd.MM.yyyy').format(this);
  }
}
