import 'package:drift/drift.dart';
import 'package:drift_sqflite/drift_sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

// 테이블 파일과 연결
part 'app_database.g.dart';
part 'ht_day_diet.dart';
part 'ht_day_body.dart';
part 'notifications.dart';

@DriftDatabase(tables: [HtDayBody, HtDayDiet, Notifications])
class AppDatabase extends _$AppDatabase {
  AppDatabase._internal() : super(_openConnection());

  static final AppDatabase _instance = AppDatabase._internal();

  factory AppDatabase() => _instance;

  @override
  int get schemaVersion => 1;

  // 필요 시 migration, onUpgrade 등을 여기에 추가 가능


  /// 앱 시작 시 호출할 초기 데이터 삽입 함수
  Future<void> insertTestDataIfNeeded() async {
    final existing = await select(htDayBody).get();
    if (existing.isNotEmpty) return; // 이미 데이터 있으면 생략

    
    await into(htDayBody).insert(const HtDayBodyCompanion(
      day: Value('2025-05-01'),
      weight: Value(90.0),
      muscle: Value(45.0),
      fat: Value(13.2),
      stamp: Value('perfect'),
    ));
    await into(htDayBody).insert(const HtDayBodyCompanion(day: Value('2025-05-03'), weight: Value(81.1), muscle: Value(49.8), fat: Value(12.5), stamp: Value('perfect')));
    await into(htDayBody).insert(const HtDayBodyCompanion(day: Value('2025-05-04'), weight: Value(91.5), muscle: Value(50.5), fat: Value(15.1), stamp: Value('perfect')));
    await into(htDayBody).insert(const HtDayBodyCompanion(day: Value('2025-05-05'), weight: Value(98.3), muscle: Value(47.7), fat: Value(8.1), stamp: Value('bad')));
    await into(htDayBody).insert(const HtDayBodyCompanion(day: Value('2025-05-06'), weight: Value(98.7), muscle: Value(53.8), fat: Value(5.2), stamp: Value('normal')));
    await into(htDayBody).insert(const HtDayBodyCompanion(day: Value('2025-05-07'), weight: Value(84.9), muscle: Value(38.7), fat: Value(7.6), stamp: Value('perfect')));
    await into(htDayBody).insert(const HtDayBodyCompanion(day: Value('2025-05-08'), weight: Value(90.4), muscle: Value(38.9), fat: Value(11.2), stamp: Value('good')));
    await into(htDayBody).insert(const HtDayBodyCompanion(day: Value('2025-05-09'), weight: Value(91.2), muscle: Value(39.6), fat: Value(8.4), stamp: Value('normal')));
    await into(htDayBody).insert(const HtDayBodyCompanion(day: Value('2025-05-10'), weight: Value(85.9), muscle: Value(35.4), fat: Value(11.9), stamp: Value('perfect')));
    await into(htDayBody).insert(const HtDayBodyCompanion(day: Value('2025-05-11'), weight: Value(89.7), muscle: Value(41.9), fat: Value(12.7), stamp: Value('normal')));
    await into(htDayBody).insert(const HtDayBodyCompanion(day: Value('2025-05-12'), weight: Value(92.5), muscle: Value(37.5), fat: Value(22.3), stamp: Value('terrible')));
    await into(htDayBody).insert(const HtDayBodyCompanion(day: Value('2025-05-13'), weight: Value(81.8), muscle: Value(49.3), fat: Value(4.2), stamp: Value('terrible')));
    await into(htDayBody).insert(const HtDayBodyCompanion(day: Value('2025-05-14'), weight: Value(87.1), muscle: Value(54.3), fat: Value(18.3), stamp: Value('bad')));
    await into(htDayBody).insert(const HtDayBodyCompanion(day: Value('2025-05-15'), weight: Value(83.8), muscle: Value(47.1), fat: Value(4.3), stamp: Value('good')));
    await into(htDayBody).insert(const HtDayBodyCompanion(day: Value('2025-05-16'), weight: Value(90.8), muscle: Value(50.0), fat: Value(9.1), stamp: Value('good')));
    await into(htDayBody).insert(const HtDayBodyCompanion(day: Value('2025-05-17'), weight: Value(88.2), muscle: Value(43.2), fat: Value(16.4), stamp: Value('perfect')));
    await into(htDayBody).insert(const HtDayBodyCompanion(day: Value('2025-05-18'), weight: Value(88.3), muscle: Value(52.8), fat: Value(10.4), stamp: Value('perfect')));
    await into(htDayBody).insert(const HtDayBodyCompanion(day: Value('2025-05-19'), weight: Value(91.5), muscle: Value(51.0), fat: Value(12.1), stamp: Value('terrible')));
    await into(htDayBody).insert(const HtDayBodyCompanion(day: Value('2025-05-20'), weight: Value(82.6), muscle: Value(42.4), fat: Value(11.5), stamp: Value('perfect')));
    await into(htDayBody).insert(const HtDayBodyCompanion(day: Value('2025-05-21'), weight: Value(97.4), muscle: Value(50.2), fat: Value(10.2), stamp: Value('terrible')));
    await into(htDayBody).insert(const HtDayBodyCompanion(day: Value('2025-05-22'), weight: Value(100.0), muscle: Value(39.6), fat: Value(8.7), stamp: Value('terrible')));
    await into(htDayBody).insert(const HtDayBodyCompanion(day: Value('2025-05-23'), weight: Value(97.0), muscle: Value(39.2), fat: Value(19.6), stamp: Value('perfect')));
    await into(htDayBody).insert(const HtDayBodyCompanion(day: Value('2025-05-24'), weight: Value(82.5), muscle: Value(48.4), fat: Value(22.4), stamp: Value('perfect')));
    await into(htDayBody).insert(const HtDayBodyCompanion(day: Value('2025-05-25'), weight: Value(80.6), muscle: Value(44.5), fat: Value(22.8), stamp: Value('bad')));
    await into(htDayBody).insert(const HtDayBodyCompanion(day: Value('2025-05-26'), weight: Value(91.5), muscle: Value(44.2), fat: Value(13.7), stamp: Value('normal')));
    await into(htDayBody).insert(const HtDayBodyCompanion(day: Value('2025-05-27'), weight: Value(92.0), muscle: Value(42.6), fat: Value(17.8), stamp: Value('terrible')));
    await into(htDayBody).insert(const HtDayBodyCompanion(day: Value('2025-05-28'), weight: Value(97.5), muscle: Value(54.0), fat: Value(21.0), stamp: Value('terrible')));
    await into(htDayBody).insert(const HtDayBodyCompanion(day: Value('2025-05-29'), weight: Value(86.1), muscle: Value(37.7), fat: Value(16.4), stamp: Value('perfect')));
    await into(htDayBody).insert(const HtDayBodyCompanion(day: Value('2025-05-30'), weight: Value(89.1), muscle: Value(40.2), fat: Value(9.2), stamp: Value('bad')));
    await into(htDayBody).insert(const HtDayBodyCompanion(day: Value('2025-05-31'), weight: Value(86.7), muscle: Value(43.0), fat: Value(13.6), stamp: Value('bad')));
    await into(htDayBody).insert(const HtDayBodyCompanion(day: Value('2025-06-01'), weight: Value(86.2), muscle: Value(39.6), fat: Value(9.1), stamp: Value('good')));
    await into(htDayBody).insert(const HtDayBodyCompanion(day: Value('2025-06-02'), weight: Value(98.8), muscle: Value(35.4), fat: Value(17.3), stamp: Value('bad')));
    await into(htDayBody).insert(const HtDayBodyCompanion(day: Value('2025-06-03'), weight: Value(81.3), muscle: Value(43.0), fat: Value(13.9), stamp: Value('terrible')));
    await into(htDayBody).insert(const HtDayBodyCompanion(day: Value('2025-06-04'), weight: Value(84.2), muscle: Value(36.4), fat: Value(23.1), stamp: Value('perfect')));
    await into(htDayBody).insert(const HtDayBodyCompanion(day: Value('2025-06-05'), weight: Value(84.3), muscle: Value(47.5), fat: Value(5.5), stamp: Value('bad')));
    await into(htDayBody).insert(const HtDayBodyCompanion(day: Value('2025-06-06'), weight: Value(83.9), muscle: Value(37.0), fat: Value(21.6), stamp: Value('perfect')));
    await into(htDayBody).insert(const HtDayBodyCompanion(day: Value('2025-06-07'), weight: Value(94.6), muscle: Value(36.2), fat: Value(3.9), stamp: Value('normal')));
    await into(htDayBody).insert(const HtDayBodyCompanion(day: Value('2025-06-08'), weight: Value(93.4), muscle: Value(54.9), fat: Value(20.3), stamp: Value('bad')));
    await into(htDayBody).insert(const HtDayBodyCompanion(day: Value('2025-06-09'), weight: Value(86.5), muscle: Value(43.6), fat: Value(20.0), stamp: Value('good')));
    await into(htDayBody).insert(const HtDayBodyCompanion(day: Value('2025-06-10'), weight: Value(87.5), muscle: Value(52.7), fat: Value(9.1), stamp: Value('good')));
    await into(htDayBody).insert(const HtDayBodyCompanion(day: Value('2025-06-11'), weight: Value(97.4), muscle: Value(43.4), fat: Value(22.6), stamp: Value('perfect')));
    await into(htDayBody).insert(const HtDayBodyCompanion(day: Value('2025-06-12'), weight: Value(84.4), muscle: Value(48.7), fat: Value(6.0), stamp: Value('bad')));
    await into(htDayBody).insert(const HtDayBodyCompanion(day: Value('2025-06-13'), weight: Value(81.0), muscle: Value(42.8), fat: Value(5.1), stamp: Value('perfect')));
    await into(htDayBody).insert(const HtDayBodyCompanion(day: Value('2025-06-14'), weight: Value(85.7), muscle: Value(40.5), fat: Value(3.8), stamp: Value('normal')));
    await into(htDayBody).insert(const HtDayBodyCompanion(day: Value('2025-06-15'), weight: Value(84.6), muscle: Value(53.0), fat: Value(23.1), stamp: Value('normal')));
    await into(htDayBody).insert(const HtDayBodyCompanion(day: Value('2025-06-16'), weight: Value(85.1), muscle: Value(41.4), fat: Value(16.0), stamp: Value('normal')));
    await into(htDayBody).insert(const HtDayBodyCompanion(day: Value('2025-06-17'), weight: Value(90.8), muscle: Value(53.1), fat: Value(19.6), stamp: Value('bad')));
    await into(htDayBody).insert(const HtDayBodyCompanion(day: Value('2025-06-18'), weight: Value(98.7), muscle: Value(47.3), fat: Value(16.8), stamp: Value('perfect')));
    await into(htDayBody).insert(const HtDayBodyCompanion(day: Value('2025-06-19'), weight: Value(85.7), muscle: Value(51.8), fat: Value(10.7), stamp: Value('terrible')));
    await into(htDayBody).insert(const HtDayBodyCompanion(day: Value('2025-06-20'), weight: Value(80.7), muscle: Value(39.0), fat: Value(20.9), stamp: Value('perfect')));
    await into(htDayBody).insert(const HtDayBodyCompanion(day: Value('2025-06-21'), weight: Value(83.3), muscle: Value(49.8), fat: Value(21.0), stamp: Value('good')));
    await into(htDayBody).insert(const HtDayBodyCompanion(day: Value('2025-06-22'), weight: Value(94.3), muscle: Value(51.3), fat: Value(17.1), stamp: Value('terrible')));
    await into(htDayBody).insert(const HtDayBodyCompanion(day: Value('2025-06-23'), weight: Value(99.1), muscle: Value(51.4), fat: Value(7.9), stamp: Value('good')));
    await into(htDayBody).insert(const HtDayBodyCompanion(day: Value('2025-06-24'), weight: Value(83.7), muscle: Value(44.6), fat: Value(13.6), stamp: Value('normal')));
    await into(htDayBody).insert(const HtDayBodyCompanion(day: Value('2025-06-25'), weight: Value(80.2), muscle: Value(50.7), fat: Value(15.9), stamp: Value('terrible')));
    await into(htDayBody).insert(const HtDayBodyCompanion(day: Value('2025-06-26'), weight: Value(86.7), muscle: Value(36.3), fat: Value(21.0), stamp: Value('good')));
    await into(htDayBody).insert(const HtDayBodyCompanion(day: Value('2025-06-27'), weight: Value(97.3), muscle: Value(42.3), fat: Value(14.2), stamp: Value('normal')));
    await into(htDayBody).insert(const HtDayBodyCompanion(day: Value('2025-06-28'), weight: Value(82.2), muscle: Value(50.4), fat: Value(7.4), stamp: Value('bad')));
    await into(htDayBody).insert(const HtDayBodyCompanion(day: Value('2025-06-29'), weight: Value(86.9), muscle: Value(42.1), fat: Value(13.3), stamp: Value('bad')));
    await into(htDayBody).insert(const HtDayBodyCompanion(day: Value('2025-06-30'), weight: Value(95.9), muscle: Value(43.6), fat: Value(21.7), stamp: Value('terrible')));
    await into(htDayBody).insert(const HtDayBodyCompanion(day: Value('2025-07-01'), weight: Value(82.5), muscle: Value(42.8), fat: Value(9.3), stamp: Value('perfect')));
    await into(htDayBody).insert(const HtDayBodyCompanion(day: Value('2025-07-02'), weight: Value(95.0), muscle: Value(45.7), fat: Value(11.3), stamp: Value('bad')));
    await into(htDayBody).insert(const HtDayBodyCompanion(day: Value('2025-07-03'), weight: Value(84.8), muscle: Value(40.7), fat: Value(16.2), stamp: Value('terrible')));
    await into(htDayBody).insert(const HtDayBodyCompanion(day: Value('2025-07-04'), weight: Value(91.7), muscle: Value(42.6), fat: Value(17.0), stamp: Value('bad')));
    await into(htDayBody).insert(const HtDayBodyCompanion(day: Value('2025-07-05'), weight: Value(86.2), muscle: Value(49.6), fat: Value(19.2), stamp: Value('terrible')));
    await into(htDayBody).insert(const HtDayBodyCompanion(day: Value('2025-07-06'), weight: Value(98.5), muscle: Value(51.5), fat: Value(3.9), stamp: Value('good')));
    await into(htDayBody).insert(const HtDayBodyCompanion(day: Value('2025-07-07'), weight: Value(91.5), muscle: Value(40.7), fat: Value(12.8), stamp: Value('normal')));
    await into(htDayBody).insert(const HtDayBodyCompanion(day: Value('2025-07-08'), weight: Value(90.7), muscle: Value(49.2), fat: Value(13.5), stamp: Value('normal')));
    await into(htDayBody).insert(const HtDayBodyCompanion(day: Value('2025-07-09'), weight: Value(92.1), muscle: Value(38.9), fat: Value(10.3), stamp: Value('good')));
    await into(htDayBody).insert(const HtDayBodyCompanion(day: Value('2025-07-10'), weight: Value(87.8), muscle: Value(37.8), fat: Value(20.8), stamp: Value('normal')));
    await into(htDayBody).insert(const HtDayBodyCompanion(day: Value('2025-07-11'), weight: Value(91.6), muscle: Value(38.4), fat: Value(10.0), stamp: Value('bad')));
    await into(htDayBody).insert(const HtDayBodyCompanion(day: Value('2025-07-12'), weight: Value(82.5), muscle: Value(54.7), fat: Value(14.6), stamp: Value('bad')));
    await into(htDayBody).insert(const HtDayBodyCompanion(day: Value('2025-07-13'), weight: Value(89.6), muscle: Value(52.8), fat: Value(22.3), stamp: Value('terrible')));
    await into(htDayBody).insert(const HtDayBodyCompanion(day: Value('2025-07-14'), weight: Value(94.6), muscle: Value(37.0), fat: Value(13.0), stamp: Value('terrible')));
    await into(htDayBody).insert(const HtDayBodyCompanion(day: Value('2025-07-15'), weight: Value(94.4), muscle: Value(54.5), fat: Value(23.1), stamp: Value('terrible')));
    await into(htDayBody).insert(const HtDayBodyCompanion(day: Value('2025-07-16'), weight: Value(83.9), muscle: Value(46.4), fat: Value(6.4), stamp: Value('normal')));
    await into(htDayBody).insert(const HtDayBodyCompanion(day: Value('2025-07-17'), weight: Value(99.6), muscle: Value(52.3), fat: Value(6.4), stamp: Value('good')));
    await into(htDayBody).insert(const HtDayBodyCompanion(day: Value('2025-07-18'), weight: Value(82.8), muscle: Value(52.2), fat: Value(15.2), stamp: Value('normal')));
    await into(htDayBody).insert(const HtDayBodyCompanion(day: Value('2025-07-19'), weight: Value(93.0), muscle: Value(36.8), fat: Value(17.3), stamp: Value('normal')));
    await into(htDayBody).insert(const HtDayBodyCompanion(day: Value('2025-07-20'), weight: Value(97.1), muscle: Value(42.6), fat: Value(18.6), stamp: Value('bad')));
    await into(htDayBody).insert(const HtDayBodyCompanion(day: Value('2025-07-21'), weight: Value(92.9), muscle: Value(44.8), fat: Value(20.4), stamp: Value('terrible')));
    await into(htDayBody).insert(const HtDayBodyCompanion(day: Value('2025-07-22'), weight: Value(89.1), muscle: Value(39.8), fat: Value(20.5), stamp: Value('perfect')));
    await into(htDayBody).insert(const HtDayBodyCompanion(day: Value('2025-07-23'), weight: Value(94.5), muscle: Value(52.6), fat: Value(22.9), stamp: Value('good')));
    await into(htDayBody).insert(const HtDayBodyCompanion(day: Value('2025-07-24'), weight: Value(94.2), muscle: Value(50.3), fat: Value(13.5), stamp: Value('normal')));
    await into(htDayBody).insert(const HtDayBodyCompanion(day: Value('2025-07-25'), weight: Value(97.3), muscle: Value(44.5), fat: Value(15.7), stamp: Value('terrible')));
    await into(htDayBody).insert(const HtDayBodyCompanion(day: Value('2025-07-26'), weight: Value(92.5), muscle: Value(46.1), fat: Value(4.3), stamp: Value('perfect')));
    await into(htDayBody).insert(const HtDayBodyCompanion(day: Value('2025-07-27'), weight: Value(93.2), muscle: Value(41.7), fat: Value(7.0), stamp: Value('terrible')));
    await into(htDayBody).insert(const HtDayBodyCompanion(day: Value('2025-07-28'), weight: Value(98.2), muscle: Value(50.5), fat: Value(19.2), stamp: Value('perfect')));
    await into(htDayBody).insert(const HtDayBodyCompanion(day: Value('2025-07-29'), weight: Value(83.2), muscle: Value(50.4), fat: Value(21.7), stamp: Value('good')));
    await into(htDayBody).insert(const HtDayBodyCompanion(day: Value('2025-07-30'), weight: Value(87.7), muscle: Value(53.8), fat: Value(17.6), stamp: Value('terrible')));
    await into(htDayBody).insert(const HtDayBodyCompanion(day: Value('2025-07-31'), weight: Value(86.3), muscle: Value(54.4), fat: Value(21.7), stamp: Value('perfect')));
    await into(htDayBody).insert(const HtDayBodyCompanion(day: Value('2025-08-01'), weight: Value(95.0), muscle: Value(54.5), fat: Value(17.6), stamp: Value('bad')));
    await into(htDayBody).insert(const HtDayBodyCompanion(day: Value('2025-08-02'), weight: Value(94.1), muscle: Value(46.8), fat: Value(20.3), stamp: Value('bad')));
    await into(htDayBody).insert(const HtDayBodyCompanion(day: Value('2025-08-03'), weight: Value(84.1), muscle: Value(41.5), fat: Value(11.9), stamp: Value('perfect')));
    await into(htDayBody).insert(const HtDayBodyCompanion(day: Value('2025-08-04'), weight: Value(88.4), muscle: Value(41.4), fat: Value(4.2), stamp: Value('bad')));
    await into(htDayBody).insert(const HtDayBodyCompanion(day: Value('2025-08-05'), weight: Value(85.9), muscle: Value(44.8), fat: Value(7.1), stamp: Value('normal')));
    await into(htDayBody).insert(const HtDayBodyCompanion(day: Value('2025-08-06'), weight: Value(81.8), muscle: Value(36.6), fat: Value(10.4), stamp: Value('good')));
    await into(htDayBody).insert(const HtDayBodyCompanion(day: Value('2025-08-07'), weight: Value(82.4), muscle: Value(47.5), fat: Value(12.1), stamp: Value('terrible')));
    await into(htDayBody).insert(const HtDayBodyCompanion(day: Value('2025-08-08'), weight: Value(85.7), muscle: Value(43.1), fat: Value(19.3), stamp: Value('perfect')));
    await into(htDayBody).insert(const HtDayBodyCompanion(day: Value('2025-08-09'), weight: Value(99.9), muscle: Value(47.0), fat: Value(5.9), stamp: Value('normal')));
    await into(htDayBody).insert(const HtDayBodyCompanion(day: Value('2025-08-10'), weight: Value(81.7), muscle: Value(54.9), fat: Value(23.0), stamp: Value('bad')));
    await into(htDayBody).insert(const HtDayBodyCompanion(day: Value('2025-08-11'), weight: Value(98.9), muscle: Value(39.4), fat: Value(22.9), stamp: Value('normal')));
    await into(htDayBody).insert(const HtDayBodyCompanion(day: Value('2025-08-12'), weight: Value(89.6), muscle: Value(43.9), fat: Value(16.7), stamp: Value('good')));
    await into(htDayBody).insert(const HtDayBodyCompanion(day: Value('2025-08-13'), weight: Value(82.6), muscle: Value(48.5), fat: Value(10.3), stamp: Value('normal')));
    await into(htDayBody).insert(const HtDayBodyCompanion(day: Value('2025-08-14'), weight: Value(81.3), muscle: Value(52.4), fat: Value(14.9), stamp: Value('good')));
    await into(htDayBody).insert(const HtDayBodyCompanion(day: Value('2025-08-15'), weight: Value(92.0), muscle: Value(37.0), fat: Value(13.0), stamp: Value('bad')));
    await into(htDayBody).insert(const HtDayBodyCompanion(day: Value('2025-08-16'), weight: Value(88.0), muscle: Value(52.2), fat: Value(17.4), stamp: Value('good')));
    await into(htDayBody).insert(const HtDayBodyCompanion(day: Value('2025-08-17'), weight: Value(82.3), muscle: Value(37.6), fat: Value(19.4), stamp: Value('bad')));
    await into(htDayBody).insert(const HtDayBodyCompanion(day: Value('2025-08-18'), weight: Value(86.2), muscle: Value(48.0), fat: Value(11.8), stamp: Value('good')));
    await into(htDayBody).insert(const HtDayBodyCompanion(day: Value('2025-08-19'), weight: Value(98.6), muscle: Value(38.6), fat: Value(14.5), stamp: Value('good')));
    await into(htDayBody).insert(const HtDayBodyCompanion(day: Value('2025-08-20'), weight: Value(83.7), muscle: Value(38.8), fat: Value(21.4), stamp: Value('terrible')));
    await into(htDayBody).insert(const HtDayBodyCompanion(day: Value('2025-08-21'), weight: Value(86.8), muscle: Value(39.9), fat: Value(22.9), stamp: Value('bad')));
    await into(htDayBody).insert(const HtDayBodyCompanion(day: Value('2025-08-22'), weight: Value(82.9), muscle: Value(44.7), fat: Value(9.9), stamp: Value('perfect')));
    await into(htDayBody).insert(const HtDayBodyCompanion(day: Value('2025-08-23'), weight: Value(87.0), muscle: Value(49.7), fat: Value(11.4), stamp: Value('bad')));
    await into(htDayBody).insert(const HtDayBodyCompanion(day: Value('2025-08-24'), weight: Value(92.3), muscle: Value(43.0), fat: Value(22.0), stamp: Value('good')));
    await into(htDayBody).insert(const HtDayBodyCompanion(day: Value('2025-08-25'), weight: Value(80.4), muscle: Value(45.7), fat: Value(10.7), stamp: Value('normal')));
    await into(htDayBody).insert(const HtDayBodyCompanion(day: Value('2025-08-26'), weight: Value(92.4), muscle: Value(48.8), fat: Value(18.2), stamp: Value('bad')));
    await into(htDayBody).insert(const HtDayBodyCompanion(day: Value('2025-08-27'), weight: Value(86.8), muscle: Value(51.5), fat: Value(21.4), stamp: Value('terrible')));
    await into(htDayBody).insert(const HtDayBodyCompanion(day: Value('2025-08-28'), weight: Value(97.5), muscle: Value(35.1), fat: Value(18.9), stamp: Value('terrible')));
    await into(htDayBody).insert(const HtDayBodyCompanion(day: Value('2025-08-29'), weight: Value(83.5), muscle: Value(48.0), fat: Value(22.9), stamp: Value('bad')));
    await into(htDayBody).insert(const HtDayBodyCompanion(day: Value('2025-08-30'), weight: Value(98.7), muscle: Value(52.0), fat: Value(21.5), stamp: Value('good')));
    await into(htDayBody).insert(const HtDayBodyCompanion(day: Value('2025-08-31'), weight: Value(85.9), muscle: Value(43.5), fat: Value(7.4), stamp: Value('terrible')));
    await into(htDayBody).insert(const HtDayBodyCompanion(day: Value('2025-09-01'), weight: Value(90.9), muscle: Value(35.2), fat: Value(21.9), stamp: Value('good')));
    await into(htDayBody).insert(const HtDayBodyCompanion(day: Value('2025-09-02'), weight: Value(98.3), muscle: Value(40.9), fat: Value(12.9), stamp: Value('bad')));
    await into(htDayBody).insert(const HtDayBodyCompanion(day: Value('2025-09-03'), weight: Value(85.7), muscle: Value(43.9), fat: Value(10.9), stamp: Value('good')));
    await into(htDayBody).insert(const HtDayBodyCompanion(day: Value('2025-09-04'), weight: Value(85.5), muscle: Value(37.9), fat: Value(18.8), stamp: Value('good')));
    await into(htDayBody).insert(const HtDayBodyCompanion(day: Value('2025-09-05'), weight: Value(92.6), muscle: Value(43.2), fat: Value(14.2), stamp: Value('good')));
    await into(htDayBody).insert(const HtDayBodyCompanion(day: Value('2025-09-06'), weight: Value(97.4), muscle: Value(40.9), fat: Value(19.7), stamp: Value('good')));

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
