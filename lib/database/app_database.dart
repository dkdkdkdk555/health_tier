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
    final existing = await select(htDayDiet).get();
    if (existing.isNotEmpty) return; // 이미 데이터 있으면 생략

    ///////////식단

    await into(htDayDiet).insert(const HtDayDietCompanion(
      day: Value('2025-05-02'),
      title: Value('아침'),
      calorie: Value(201.0),
      protein: Value(21.0),
      diet: Value('군계란 3개')
    ));
    await into(htDayDiet).insert(const HtDayDietCompanion(
      day: Value('2025-05-02'),
      title: Value('점심'),
      calorie: Value(520.0),
      protein: Value(37.0),
      diet: Value('닭가슴채소볶음+밥190g\n군계란1개')
    ));
    await into(htDayDiet).insert(const HtDayDietCompanion(
      day: Value('2025-05-02'),
      title: Value('간식'),
      calorie: Value(651.0),
      protein: Value(52.5),
      diet: Value('닭가슴채소볶음+밥200g\n닭가슴살 스테이크\n군계란1개')
    ));
    await into(htDayDiet).insert(const HtDayDietCompanion(
      day: Value('2025-05-02'),
      title: Value('저녁삭사'),
      calorie: Value(977.0),
      protein: Value(62),
      diet: Value('- 간장계란닭가슴밥(밥300g/계란4/닭가슴1/참기름1큰술)')
    ));
    await into(htDayDiet).insert(const HtDayDietCompanion(
      day: Value('2025-05-02'),
      title: Value('친구약속'),
      calorie: Value(917.0),
      protein: Value(42),
      diet: Value('육회비빔밥, 녹두전, 청국장조금')
    ));

    await into(htDayDiet).insert(const HtDayDietCompanion(
      day: Value('2025-05-03'),
      title: Value('외식'),
      calorie: Value(241.8),
      protein: Value(39.8),
      diet: Value('닭가슴살, 닭가슴스테이크')
    ));
    await into(htDayDiet).insert(const HtDayDietCompanion(
      day: Value('2025-05-03'),
      title: Value('점심'),
      calorie: Value(495.0),
      protein: Value(37.0),
      diet: Value('- 민트초콜릿 50kcal\n- 그릭요거트 125kcal/11g\n- 닭가슴살 110kcal/24g\n바나나2개 : 210kcal/2g')
    ));
    await into(htDayDiet).insert(const HtDayDietCompanion(
      day: Value('2025-05-03'),
      title: Value('저녁'),
      calorie: Value(735.0),
      protein: Value(87),
      diet: Value('- 바나나1개 : 105kcal/1g\n- 프로틴그래놀라 시리얼(70g)\n: 248kcal/35g\n- 아몬드브리즈\n- 닭가슴살 110kcal/24g\n- 그릭요거트 125kcal/11g\n닭가슴스테이크 : 117kcal/15g')
    ));
    await into(htDayDiet).insert(const HtDayDietCompanion(
      day: Value('2025-05-03'),
      title: Value('저녁'),
      calorie: Value(441.0),
      protein: Value(61),
      diet: Value('- 서브웨이 폴드포크 바비큐\n: 327kcal/24.8g\n닭가슴살 : 114kcal/23g')
    ));
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
