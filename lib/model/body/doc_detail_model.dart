import 'package:drift/drift.dart';

class DocDayDetail {
  final int id;
  final String day;
  final int? workYn;
  final int? drunYn;
  final double? weight;
  final double? muscle;
  final double? fat;
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
    this.muscle,
    this.fat,
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

  factory DocDayDetail.fromJson(Map<String, dynamic> json) {
    return DocDayDetail(
      id: json['id'] as int,
      day: json['day'] as String,
      workYn: json['workYn'] as int?,
      drunYn: json['drunYn'] as int?,
      weight: (json['weight'] as num?)?.toDouble(),
      muscle: (json['muscle'] as num?)?.toDouble(),
      fat: (json['fat'] as num?)?.toDouble(),
      stamp: json['stamp'] as String?,
      memo: json['memo'] as String?,
      totalCalorie: (json['totalCalorie'] as num?)?.toDouble(),
      totalProtein: (json['totalProtein'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'day': day,
      'workYn': workYn,
      'drunYn': drunYn,
      'weight': weight,
      'muscle': muscle,
      'fat': fat,
      'stamp': stamp,
      'memo': memo,
      'totalCalorie': totalCalorie,
      'totalProtein': totalProtein,
    };
  }
}
  


