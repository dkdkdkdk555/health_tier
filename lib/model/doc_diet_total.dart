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
}