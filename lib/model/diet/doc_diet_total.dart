import 'package:drift/drift.dart';

class DayDietTotal {
  final String day;
  final double? totalCalorie;
  final double? totalProtein;

  DayDietTotal({
    required this.day,
    this.totalCalorie,
    this.totalProtein
  });

  factory DayDietTotal.fromRow(QueryRow row){
    return DayDietTotal(
      day: row.read<String>('day'),
      totalCalorie: row.readNullable<double>('totalcalorie'),
      totalProtein: row.readNullable<double>('totalprotein'),
    );
  }

  String get formattedTotalProtein {
    if (totalProtein == null) return '';
    final truncated = truncateToOneDecimal(totalProtein!);
    return truncated == truncated.toInt()
        ? truncated.toInt().toString()
        : truncated.toString();
  }

  String get formattedTotalCalorie {
    if (totalCalorie == null) return '';
    final truncated = truncateToOneDecimal(totalCalorie!);
    return truncated == truncated.toInt()
        ? truncated.toInt().toString()
        : truncated.toString();
  }

  double truncateToOneDecimal(double value) {
    return (value * 10).truncateToDouble() / 10;
  }

}