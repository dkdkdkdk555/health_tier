import 'package:drift/drift.dart';

class DocDayInfo {
  final String day;
  final double? weight;
  final double? totalCalorie;
  final String? stamp;
  final int? workYn; // 운동 여부 (1: 운동함)
  final int? drunYn; // 음주 여부 (1: 음주함)

  DocDayInfo({
    required this.day,
    this.weight,
    this.totalCalorie,
    this.stamp,
    this.workYn,
    this.drunYn,
  });

  factory DocDayInfo.fromRow(QueryRow row) {
    return DocDayInfo(
      day: row.read<String>('DAY'),
      weight: row.readNullable<double>('WEIGHT'),
      totalCalorie: row.readNullable<double>('TOTAL_CALORIE'),
      stamp: row.readNullable<String>('STAMP'),
      workYn: row.readNullable<int>('WKOUT_YN'),
      drunYn: row.readNullable<int>('DRUNK_YN'),
    );
  }
}
