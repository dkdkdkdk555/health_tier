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

    await into(htDayBody).insert(const HtDayBodyCompanion(
      day: Value('2025-04-15'),
      weight: Value(101.2),
      muscle: Value(48.0),
      fat: Value(20.0),
      memo: Value('테스트 기록입니다.'),
      wkoutYn: Value(1),
      drunkYn: Value(0),
      stamp: Value('PERFECT'),
    ));

    await into(htDayBody).insert(const HtDayBodyCompanion(
      day: Value('2025-04-12'),
      weight: Value(101.2),
      muscle: Value(48.2),
      fat: Value(20.0),
      memo: Value('초콜릿을 합리화해서 먹는 잘못이 있었지만, 운동도 잘 수행한 편이고, 칼로리도 2000을 넘지 않으면서 단백질은 200g이상 섭취했으므로 좋게생각,, 허나 초콜릿을 먹은건 매우 잘못됐다.. 자꾸 회사에서 이런 일이 반복되면 정말 현정씨한테 요청해야한다!'),
      wkoutYn: Value(1),
      drunkYn: Value(0),
      stamp: Value('GOOD'),
    ));

    await into(htDayBody).insert(const HtDayBodyCompanion(
      day: Value('2025-04-11'),
      weight: Value(91.2),
      muscle: Value(48.0),
      fat: Value(20.0),
      memo: Value('회사에서  군것질을 했다. 작년 바프준비때도 배고픔을 달랜다며 + 칼로리가 적다며 한두개씩 먹었는데, 과오를 반복할 순 없다. 만약 앞으로 오곡쿠키건 뭐 아주 작은 쌀과자 하나라도 먹는 순간엔 현정씨한테 다시 "과자안먹기내기"를 부탁하겠으니 그렇게알고, 다음부터는 산책나가는건 좋으나 절대 홈플러스 따라가지마라,,!'),
      wkoutYn: Value(1),
      drunkYn: Value(0),
      stamp: Value('NORMAL'),
    ));

    await into(htDayBody).insert(const HtDayBodyCompanion(
      day: Value('2025-04-10'),
      weight: Value(78),
      muscle: Value(48.7),
      fat: Value(20.0),
      memo: Value('일반식 안먹을 수 있으면 먹지마,, 이게 뭐하는 짓이야.'),
      wkoutYn: Value(1),
      drunkYn: Value(0),
      stamp: Value('BAD'),
    ));

    await into(htDayBody).insert(const HtDayBodyCompanion(
      day: Value('2025-04-01'),
      weight: Value(101.0),
      muscle: Value(37.0),
      fat: Value(20.0),
      memo: Value('매우 피곤한 상태임에도 운동 잘 수행함'),
      wkoutYn: Value(1),
      drunkYn: Value(0),
      stamp: Value('TERRIBLE'),
    ));

    ///////////식단

    await into(htDayDiet).insert(const HtDayDietCompanion(
      day: Value('2025-04-14'),
      title: Value('아침'),
      calorie: Value(300.0),
      protein: Value(35.0),
    ));
    await into(htDayDiet).insert(const HtDayDietCompanion(
      day: Value('2025-04-14'),
      title: Value('점심'),
      calorie: Value(1300.0),
      protein: Value(80.0),
    ));
    await into(htDayDiet).insert(const HtDayDietCompanion(
      day: Value('2025-04-14'),
      title: Value('저녁'),
      calorie: Value(200.0),
      protein: Value(12),
    ));

     await into(htDayDiet).insert(const HtDayDietCompanion(
      day: Value('2025-04-15'),
      title: Value('아침'),
      calorie: Value(300.0),
      protein: Value(35.0),
    ));
    await into(htDayDiet).insert(const HtDayDietCompanion(
      day: Value('2025-04-15'),
      title: Value('점심'),
      calorie: Value(1300.0),
      protein: Value(80.0),
    ));
    await into(htDayDiet).insert(const HtDayDietCompanion(
      day: Value('2025-04-15'),
      title: Value('저녁'),
      calorie: Value(200.0),
      protein: Value(12),
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
