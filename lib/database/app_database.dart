import 'package:drift/drift.dart';
import 'package:drift_sqflite/drift_sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

// 테이블 파일과 연결
part 'app_database.g.dart';
part 'ht_day_diet.dart';
part 'ht_day_body.dart';

@DriftDatabase(tables: [HtDayBody, HtDayDiet])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  // 필요 시 migration, onUpgrade 등을 여기에 추가 가능
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final dbPath = p.join(dir.path, 'health_tracker.db');
    return SqfliteQueryExecutor(
      path: dbPath,
      logStatements: true, // 쿼리 로그 보고 싶을 때 (개발용)
    );
  });
}
