part of 'app_database.dart';

class HtDayBody extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get day => text()(); // 날짜 (yyyy-MM-dd 등)
  RealColumn get weight => real().nullable()();
  RealColumn get muscle => real().nullable()();
  RealColumn get fat => real().nullable()();
  TextColumn get memo => text().nullable()();
  IntColumn get wkoutYn => integer().withDefault(const Constant(0))();
  IntColumn get drunkYn => integer().withDefault(const Constant(0))();
  TextColumn get stamp => text().nullable()();

  @override
  List<Set<Column>> get uniqueKeys => [
    {day},
  ];
}