import 'package:drift/drift.dart';

class DocDayDetail {
  final int id;
  final String day;
  final int? workYn;
  final int? drunYn;
  final double? weight;
  final String? stamp;
  final String? memo;
  final double? totalCalorie;
  final double? totalProtein;

  DocDayDetail({
    required this.id,
    required this.day,
    this.workYn,
    this.drunYn,
    this.weight,
    this.stamp,
    this.memo,
    this.totalCalorie,
    this.totalProtein
  });

  factory DocDayDetail.fromRow(QueryRow row) {
    return DocDayDetail(
      id: row.read<int>('ID'),
      day: row.read<String>('DAY'),
      workYn: row.readNullable<int>('WKOUT_YN'),
      drunYn: row.readNullable<int>('DRUNK_YN'),
      weight: row.readNullable<double>('WEIGHT'),
      stamp: row.readNullable<String>('STAMP'),
      memo: row.readNullable<String>('MEMO'),
      totalCalorie: row.readNullable<double>('TOTAL_CALORIE'),
      totalProtein: row.readNullable<double>('TOTAL_PROTEIN'),
    );
  }
}
  


