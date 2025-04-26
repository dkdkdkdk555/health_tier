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


  /// 앱 시작 시 호출할 초기 데이터 삽입 함수
  Future<void> insertTestDataIfNeeded() async {
    final existing = await select(htDayBody).get();
    if (existing.isNotEmpty) return; // 이미 데이터 있으면 생략

    ///////////식단

    // await into(htDayDiet).insert(const HtDayDietCompanion(
    //   day: Value('2025-04-14'),
    //   title: Value('아침'),
    //   calorie: Value(300.0),
    //   protein: Value(35.0),
    // ));
    // await into(htDayDiet).insert(const HtDayDietCompanion(
    //   day: Value('2025-04-14'),
    //   title: Value('점심'),
    //   calorie: Value(1300.0),
    //   protein: Value(80.0),
    // ));
    // await into(htDayDiet).insert(const HtDayDietCompanion(
    //   day: Value('2025-04-14'),
    //   title: Value('저녁'),
    //   calorie: Value(200.0),
    //   protein: Value(12),
    // ));

    //  await into(htDayDiet).insert(const HtDayDietCompanion(
    //   day: Value('2025-04-15'),
    //   title: Value('아침'),
    //   calorie: Value(300.0),
    //   protein: Value(35.0),
    // ));
    // await into(htDayDiet).insert(const HtDayDietCompanion(
    //   day: Value('2025-04-15'),
    //   title: Value('점심'),
    //   calorie: Value(1300.0),
    //   protein: Value(80.0),
    // ));
    // await into(htDayDiet).insert(const HtDayDietCompanion(
    //   day: Value('2025-04-15'),
    //   title: Value('저녁'),
    //   calorie: Value(200.0),
    //   protein: Value(12),
    // ));


  }
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
