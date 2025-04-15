import 'package:drift/drift.dart';

class DocDayInfo {
  final String day;
  final double? weight;
  final double? totalCalorie;
  final String? stamp;

  DocDayInfo({
    required this.day,
    this.weight,
    this.totalCalorie,
    this.stamp,
  });

  factory DocDayInfo.fromRow(QueryRow row) {
    return DocDayInfo(
      day: row.read<String>('DAY'),
      weight: row.readNullable<double>('WEIGHT'),
      totalCalorie: row.readNullable<double>('TOTAL_CALORIE'),
      stamp: row.readNullable<String>('STAMP'),
    );
  }
}
