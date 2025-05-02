part of 'app_database.dart';


class HtDayDiet extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get day => text()();       // 날짜
  TextColumn get title => text()();     // 예: 아침/점심/저녁
  TextColumn get diet => text().nullable()();
  RealColumn get calorie => real().nullable()();
  RealColumn get protein => real().nullable()();
}