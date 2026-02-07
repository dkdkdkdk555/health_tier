import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:my_app/database/app_database.dart';
import 'package:my_app/model/body/doc_detail_model.dart';
import 'package:my_app/model/diet/doc_diet_model.dart';
import 'package:my_app/model/diet/doc_diet_total.dart';
import 'package:my_app/model/body/doc_main_model.dart';
import 'package:my_app/model/stc/day_range_param.dart';
import 'package:my_app/model/stc/stc_fat_model.dart';
import 'package:my_app/model/stc/stc_muscle_model.dart';
import 'package:my_app/model/stc/stc_stamp_model.dart';
import 'package:my_app/model/stc/stc_weight_model.dart';
import 'package:my_app/model/usr/user/notifications_model.dart';

AppDatabase? _dbInstance;

/// 1. AppDatabase 인스턴스를 제공하는 Provider
final databaseProvider = Provider<AppDatabase>((ref) {
  return _dbInstance ??= AppDatabase();
});

/*
 1-1 체중기록 조회 페이지 <캘린더뷰 & 테이블뷰> 목록조회
*/
final htDayDocOfMonth = FutureProvider.family<List<DocDayInfo>, String>((ref, yearMonth) async {
  final db = ref.watch(databaseProvider);
  final pattern = '$yearMonth%';

  final result = await db.customSelect(
    '''
    SELECT
      DAY,
      MAX(WEIGHT) AS WEIGHT,
      SUM(CALORIE) AS TOTAL_CALORIE,
      MAX(STAMP) AS STAMP
    FROM (
      SELECT
        DAY,
        WEIGHT,
        NULL AS CALORIE,
        STAMP
      FROM HT_DAY_BODY
      WHERE DAY LIKE ?
      UNION ALL
      SELECT
        DAY,
        NULL AS WEIGHT,
        CALORIE,
        NULL AS STAMP
      FROM HT_DAY_DIET
      WHERE DAY LIKE ?
    )
    GROUP BY DAY
    ORDER BY DAY
    ''',
    variables: [Variable.withString(pattern), Variable.withString(pattern)],
  ).get();

  return result.map((row) => DocDayInfo.fromRow(row)).toList();
});

/*
  1-1 체중기록 조회 페이지 상세조회
*/
final htDayDocDetail = FutureProvider.family<DocDayDetail?, String>((ref, day) async {
  final db = ref.watch(databaseProvider);

  final body = await (db.select(db.htDayBody)
    ..where((tbl) => tbl.day.equals(day))).getSingleOrNull();

  final diets = await (db.select(db.htDayDiet)
    ..where((tbl) => tbl.day.equals(day))).get();

  double truncateToOneDecimal(double value) {
    return (value * 10).truncateToDouble() / 10;
  }

  final totalCal = diets.fold<double>(0, (sum, e) => sum + (e.calorie ?? 0));
  final totalPro = diets.fold<double>(0, (sum, e) => sum + (e.protein ?? 0));

  final totalCalorie = totalCal == 0 ? null : truncateToOneDecimal(totalCal);
  final totalProtein = totalPro == 0 ? null : truncateToOneDecimal(totalPro);

  return DocDayDetail(
    id: body?.id ?? -1,
    day: day,
    workYn: body?.wkoutYn,
    drunYn: body?.drunkYn,
    weight: body?.weight,
    stamp: body?.stamp,
    memo: body?.memo,
    muscle: body?.muscle,
    totalCalorie: totalCalorie,
    totalProtein: totalProtein,
  );
});


/*
  1-1 체중기록 조회 페이지 직전 체중 기록 가져오기
*/
final getPreviousWeight = FutureProvider.family<double?, String>((ref, currDay) async {
  final db = ref.watch(databaseProvider);

  final previous = await (db.select(db.htDayBody)
        ..where((tbl) => tbl.day.isSmallerThanValue(currDay)) // 현재 날짜보다 작은 애들 중
        ..where((tbl) => tbl.weight.isNotNull())
        ..where((tbl) => tbl.weight.isNotValue(0))
        ..orderBy([(t) => OrderingTerm.desc(t.day)]) // 최신순으로 정렬하고
        ..limit(1) // 가장 최근 하나만 가져오기
    ).getSingleOrNull();

  return previous?.weight;
});

/*
  1-1-3 상세조회
*/
final selectHtDayDoc = FutureProvider.family<DocDayDetail?, String>((ref, day) async {
  final db = ref.watch(databaseProvider);

  final doc = await (db.select(db.htDayBody)
    ..where((tbl) => tbl.day.equals(day))).getSingleOrNull();
  
  return DocDayDetail(
    id: doc?.id ?? -1,
    day: day,
    workYn: doc?.wkoutYn,
    drunYn: doc?.drunkYn,
    weight: doc?.weight,
    muscle: doc?.muscle,
    fat: doc?.fat,
    stamp: doc?.stamp,
    memo: doc?.memo,
  );
});

/*
  1-1-3 INSERT
*/ 
Future<void> insertHtDayDoc({required WidgetRef ref, required DocDayDetail doc}) async {
  final db = ref.read(databaseProvider);

  await db.into(db.htDayBody).insert(
    HtDayBodyCompanion.insert(
      day: doc.day,
      weight: Value(doc.weight),
      muscle: Value(doc.muscle),
      fat: Value(doc.fat),
      memo: Value(doc.memo),
      wkoutYn: Value(doc.workYn ?? 0),
      drunkYn: Value(doc.drunYn ?? 0),
      stamp: Value(doc.stamp),
    ),
  );
}

/*
  1-1-3 UPDATE
*/ 
Future<void> updateHtDayDoc({
  required WidgetRef ref,
  required DocDayDetail doc
}) async {
  final db = ref.read(databaseProvider);
  await (db.update(db.htDayBody)..where((tbl) => tbl.id.equals(doc.id))).write(
    HtDayBodyCompanion(
      weight: Value(doc.weight),
      muscle: Value(doc.muscle),
      fat: Value(doc.fat),
      memo: Value(doc.memo),
      wkoutYn: Value(doc.workYn ?? 0),
      drunkYn: Value(doc.drunYn ??0),
      stamp: Value(doc.stamp),
    ),
  );
}


/*
  1-2-1 식단 기록 페이지 상세조회
*/
final selectDietDocList = FutureProvider.family<List<DayDietModel>, String>((ref, day) async {
  final db = ref.watch(databaseProvider);

  final rows = await db.customSelect(
    '''
    SELECT 
      ID, DAY, TITLE, DIET, CALORIE, PROTEIN
    FROM 
      HT_DAY_DIET
    WHERE DAY = ?
    ORDER BY ID ASC
    ''',
    variables: [Variable.withString(day)],
    readsFrom: {db.htDayDiet},
  ).get();

  return rows.map(DayDietModel.fromRow).toList();
});

/*
  1-2-1 식단 기록 페이지 칼로리&단백질 총합
*/
final selectDayDietTotal = FutureProvider.family<DayDietTotal?, String>((ref, day) async {
  final db = ref.watch(databaseProvider);

  final rows = await db.customSelect(
    '''
    SELECT 
      DAY AS day,
      SUM(CALORIE) AS totalcalorie,
      SUM(PROTEIN) AS totalprotein
    FROM HT_DAY_DIET
    WHERE DAY = ?
    GROUP BY DAY
    ''',
    variables: [Variable.withString(day)],
    readsFrom: {db.htDayDiet},
  ).get();

  if (rows.isEmpty) return null;

  return DayDietTotal.fromRow(rows.first);
});

/*
  1-2-2 식단 기록 입력&수정 화면 조회
*/
final selectDietDayDoc = FutureProvider.family<List<DayDietModel>, String>((ref, day) async {
  final db = ref.watch(databaseProvider);

  final result = await (db.select(db.htDayDiet)
    ..where((tbl) => tbl.day.equals(day))
    ..orderBy([(tbl) => OrderingTerm(expression: tbl.id)])) // id 오름차순 정렬
    .get();

  return result.map((row) => DayDietModel(
    id: row.id,
    day: row.day,
    title: row.title,
    diet: row.diet,
    calorie: row.calorie,
    protein: row.protein,
  )).toList();
});

/*
  1-2-2 INSERT
*/ 
Future<void> insertHtDietDoc({
  required WidgetRef ref,
  required List<DayDietModel> list,
}) async {
  final db = ref.read(databaseProvider);

  for (final item in list) {
    await db.into(db.htDayDiet).insert(
      HtDayDietCompanion.insert(
        day: item.day,
        title: item.title ?? '',
        diet: Value(item.diet),
        calorie: Value(item.calorie),
        protein: Value(item.protein),
      ),
    );
  }
}

/*
  1-2-2 UPDATE
*/ 
Future<void> updateHtDietDoc({
  required WidgetRef ref,
  required List<DayDietModel> list,
}) async {
  final db = ref.read(databaseProvider);

  for (final item in list) {
    if (item.id == -1) continue; // ID 없는 경우 스킵

    await (db.update(db.htDayDiet)..where((tbl) => tbl.id.equals(item.id))).write(
      HtDayDietCompanion(
        title: Value(item.title ?? ''),
        diet: Value(item.diet),
        calorie: Value(item.calorie),
        protein: Value(item.protein),
      ),
    );
  }
}

/*
  1-2-2 DELETE
*/
Future<void> deleteHtDietDoc({required WidgetRef ref, required int id,}) async {
  final db = ref.read(databaseProvider);
  await (db.delete(db.htDayDiet)..where((tbl) => tbl.id.equals(id))).go();
}

/*
  2-1-1 체중 그래프
*/
final selectWeightList = FutureProvider.family<List<WeightModel>, DayRange>((ref, range) async {
  final db = ref.watch(databaseProvider);

  final result = await db.customSelect(
    '''
    SELECT ID, DAY, WEIGHT
    FROM HT_DAY_BODY
    WHERE DAY BETWEEN ? AND ?
      AND DAY IS NOT NULL
      AND WEIGHT IS NOT NULL
      AND WEIGHT > 0
    ORDER BY DAY;
    ''',
    variables: [Variable.withString(range.startDay), Variable.withString(range.endDay)],
  ).get();

  final fullList = result.map((e) => WeightModel(
    day: e.readNullable<String>('day') ?? '',
    weight: e.readNullable<double>('weight') ?? 0,
  )).toList();

  final length = fullList.length;

  if (length <= 60) {
    return fullList; // 모든 데이터 반환
  }

  // 간격 계산
  int step;
  if (length > 360) {
    step = 7; // 일주일에 1번
  } else {
    // 91 ~ 360 사이: 2 ~ 7 사이의 가중 간격 (선형 보간)
    final t = (length - 60) / (360 - 60); // 0.0 ~ 1.0
    step = (2 + (5 * t)).round(); // 2 ~ 7 사이
  }

  // 간격 기반 필터링
  final filtered = <WeightModel>[];
  for (int i = 0; i < fullList.length; i += step) {
    filtered.add(fullList[i]);
  }

  return filtered;
});


/*
  2-1-1 골격근량 그래프
*/
final selectMuscleList = FutureProvider.family<List<MuscleModel>, DayRange>((ref, range) async {
  final db = ref.watch(databaseProvider);

  final result = await db.customSelect(
    '''
    SELECT ID, DAY, MUSCLE
    FROM HT_DAY_BODY
    WHERE DAY BETWEEN ? AND ?
      AND MUSCLE IS NOT NULL
      AND MUSCLE > 0
    ORDER BY DAY;
    ''',
    variables: [Variable.withString(range.startDay), Variable.withString(range.endDay)],
  ).get();

  final fullList = result.map((e) => MuscleModel(
    day: e.read<String>('day'),
    muscle: e.readNullable<double>('muscle') ?? 0,
  )).toList();

  final length = fullList.length;

  if (length <= 60) {
    return fullList; // 모든 데이터 반환
  }

  // 간격 계산
  int step;
  if (length > 360) {
    step = 7; // 일주일에 1번
  } else {
    // 91 ~ 360 사이: 2 ~ 7 사이의 가중 간격 (선형 보간)
    final t = (length - 60) / (360 - 60); // 0.0 ~ 1.0
    step = (2 + (5 * t)).round(); // 2 ~ 7 사이
  }

  return [
    for (int i = 0; i < fullList.length; i += step) fullList[i]
  ];
});

/*
  2-1-1 체지방량 그래프
*/
final selectFatList = FutureProvider.family<List<FatModel>, DayRange>((ref, range) async {
  final db = ref.watch(databaseProvider);

  final result = await db.customSelect(
    '''
    SELECT ID, DAY, FAT
    FROM HT_DAY_BODY
    WHERE DAY BETWEEN ? AND ?
      AND FAT IS NOT NULL
      AND FAT > 0
    ORDER BY DAY;
    ''',
    variables: [Variable.withString(range.startDay), Variable.withString(range.endDay)],
  ).get();

  final fullList = result.map((e) => FatModel(
    day: e.read<String>('day'),
    fat: e.readNullable<double>('fat') ?? 0,
  )).toList();

  final length = fullList.length;

  if (length <= 60) {
    return fullList; // 모든 데이터 반환
  }

  // 간격 계산
  int step;
  if (length > 360) {
    step = 7; // 일주일에 1번
  } else {
    // 91 ~ 360 사이: 2 ~ 7 사이의 가중 간격 (선형 보간)
    final t = (length - 60) / (360 - 60); // 0.0 ~ 1.0
    step = (2 + (5 * t)).round(); // 2 ~ 7 사이
  }

  return [
    for (int i = 0; i < fullList.length; i += step) fullList[i]
  ];
});

/*
  2-1-1 하루평가 그래프
*/
final selectStampList = FutureProvider.family<List<StampModel>, DayRange>((ref, range) async {
  final db = ref.watch(databaseProvider);

  // 1. 날짜 리스트 생성
  final start = DateTime.parse(range.startDay);
  final end = DateTime.parse(range.endDay);
  final allDays = List.generate(end.difference(start).inDays + 1,
      (i) => DateFormat('yyyy-MM-dd').format(start.add(Duration(days: i))));

  // 2. DB에서 해당 날짜 범위의 평가 데이터 가져오기
  final result = await db.customSelect(
    '''
    SELECT DAY, STAMP
    FROM HT_DAY_BODY
    WHERE DAY BETWEEN ? AND ?
      AND STAMP IS NOT NULL
      AND STAMP != ''
    ORDER BY DAY;
    ''',
    variables: [Variable.withString(range.startDay), Variable.withString(range.endDay)],
  ).get();

  // 3. Map으로 변환하여 빠른 조회
  final stampMap = {
    for (var row in result)
      row.read<String>('day'): row.read<String>('stamp'),
  };

  // 4. 모든 날짜를 포함한 결과로 변환
  final fullList = allDays.map((day) {
    return StampModel(day: day, stamp: stampMap[day] ?? '');
  }).toList();

  return fullList;
});

/*
  4-2. 가장 최근의 체중을 가져오기
*/
final getLatestWeightProvider = FutureProvider.autoDispose<double?>((ref) async {
  final db = ref.watch(databaseProvider);

  // htDayBody 테이블에서 체중(weight) 기록이 있는 가장 최근의 데이터를 조회
  final latestBody = await (db.select(db.htDayBody)
    ..where((tbl) => tbl.weight.isNotNull()) // 체중 값이 null이 아닌 경우
    ..where((tbl) => tbl.weight.isNotValue(0)) // 체중 값이 0이 아닌 경우
    ..orderBy([(tbl) => OrderingTerm.desc(tbl.day)]) // 날짜를 내림차순(최신순)으로 정렬
    ..limit(1) // 가장 최신 데이터 하나만 가져옴
  ).getSingleOrNull();

  // 조회된 데이터가 있다면 체중 값을, 없다면 null을 반환
  return latestBody?.weight;
});

/*
  4-2-1. 내 정보관리 > 데이터 백업 시 모든 식단기록 가져오기
*/
final getAllHtDayDietProvider = FutureProvider<List<DayDietModel>>((ref) async {
  final db = ref.watch(databaseProvider);

  final rows = await db.select(db.htDayDiet).get();

  return rows.map((row) => DayDietModel(
    id: row.id,
    day: row.day,
    title: row.title,
    diet: row.diet,
    calorie: row.calorie,
    protein: row.protein,
  )).toList();
});

/*
  4-2-1. 내 정보관리 > 데이터 백업 시 모든 체중기록 가져오기
*/
final getAllHtDayBodyProvider = FutureProvider<List<DocDayDetail>>((ref) async {
  final db = ref.watch(databaseProvider);

  final rows = await db.select(db.htDayBody).get();

  return rows.map((row) => DocDayDetail(
    id: row.id,
    day: row.day,
    workYn: row.wkoutYn,
    drunYn: row.drunkYn,
    weight: row.weight,
    muscle: row.muscle,
    fat: row.fat,
    stamp: row.stamp,
    memo: row.memo,
  )).toList();
});


/*
  4-2-1. 내 정보관리 > 체중 데이터 복원
*/
Future<void> insertRestoreDayDetailList({
  required WidgetRef ref,
  required List<DocDayDetail> list,
}) async {
  final db = ref.read(databaseProvider);

  // 1. 기존 데이터 삭제
  await db.delete(db.htDayBody).go();

  // 2. 새 데이터 insert (id는 auto increment이므로 제외하고 삽입)
  for (final item in list) {
    await db.into(db.htDayBody).insert(
      HtDayBodyCompanion.insert(
        day: item.day,
        weight: Value(item.weight),
        muscle: Value(item.muscle),
        fat: Value(item.fat),
        memo: Value(item.memo),
        wkoutYn: Value(item.workYn ?? 0),
        drunkYn: Value(item.drunYn ?? 0),
        stamp: Value(item.stamp),
      ),
    );
  }
}

/*
  4-2-1. 내 정보관리 > 식단 데이터 복원
*/
Future<void> insertRestoreDietList({
  required WidgetRef ref,
  required List<DayDietModel> list,
}) async {
  final db = ref.read(databaseProvider);

  // 1. 기존 데이터 삭제
  await db.delete(db.htDayDiet).go();

  // 2. 새 데이터 insert (id는 auto increment이므로 제외하고 삽입)
  for (final item in list) {
    await db.into(db.htDayDiet).insert(
      HtDayDietCompanion.insert(
        day: item.day,
        title: item.title ?? '',
        diet: Value(item.diet),
        calorie: Value(item.calorie),
        protein: Value(item.protein),
      ),
    );
  }
}

/*
  Notifications 테이블 관련 CRUD & helper
*/

/// 전체 조회
final selectAllNotifications = FutureProvider.autoDispose.family<
    List<NotificationModel>, int>((ref, userId) async {
  final db = ref.watch(databaseProvider);

  final result = await (db.select(db.notifications)
        ..where((tbl) => tbl.userId.equals(userId)))
      .get();

  return result
      .map((row) => NotificationModel(
            id: row.id!,
            prefix: row.prefix,
            title: row.title,
            body: row.body,
            feedId: row.feedId,
            type: row.type,
            receivedAt: row.receivedAt,
            isRead: row.isRead,
            userId: row.userId,
          ))
      .toList();
});

/// 특정 알림 삭제
Future<void> deleteNotification({
  required WidgetRef ref,
  required int id,
}) async {
  final db = ref.read(databaseProvider);
  await (db.delete(db.notifications)..where((tbl) => tbl.id.equals(id))).go();
}

/// 전체 삭제
Future<void> deleteAllNotifications({required WidgetRef ref}) async {
  final db = ref.read(databaseProvider);
  await db.delete(db.notifications).go();
}

/// 읽음 처리 (isRead = 'true')
Future<void> markNotificationRead({
  required WidgetRef ref,
  required int id,
}) async {
  final db = ref.read(databaseProvider);
  await (db.update(db.notifications)..where((tbl) => tbl.id.equals(id))).write(
    const NotificationsCompanion(
      isRead: Value('true'),
    ),
  );
}

/// isRead = 'false'인 알림 존재 여부
final hasUnreadNotification = FutureProvider.autoDispose<bool>((ref) async {
  final db = ref.watch(databaseProvider);
  final count = await (db.select(db.notifications)
        ..where((tbl) => tbl.isRead.equals('false')))
      .get()
      .then((rows) => rows.length);
  return count > 0;
});

/*
  식사유형(title) 검색 - 중복 제거하여 반환
  검색어가 포함된 title을 가진 식단 기록을 반환
*/
final searchDietByTitleProvider = FutureProvider.autoDispose
    .family<List<DayDietModel>, String>((ref, query) async {
  if (query.trim().isEmpty) return [];

  final db = ref.watch(databaseProvider);

  final result = await db.customSelect(
    '''
    SELECT
      MIN(ID) AS id,
      DAY AS day,
      TITLE AS title,
      DIET AS diet,
      CALORIE AS calorie,
      PROTEIN AS protein
    FROM HT_DAY_DIET
    WHERE TITLE LIKE ?
    GROUP BY TITLE, DIET, CALORIE, PROTEIN
    ORDER BY MAX(ID) DESC
    LIMIT 10
    ''',
    variables: [Variable.withString('%$query%')],
    readsFrom: {db.htDayDiet},
  ).get();

  return result.map(DayDietModel.fromRow).toList();
});

/*
  푸시 알림 필터링용: 오늘 날짜의 체중 및 식단 기록 존재 여부 확인
  - htDayBody(체중)와 htDayDiet(식단) 기록이 '모두' 있는 경우 true 반환
*/
Future<bool> checkTodayRecordComplete(AppDatabase db) async {
  final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

  // 1. 체중 기록 확인 (0이 아닌 유효한 값)
  final bodyRecord = await (db.select(db.htDayBody)
        ..where((tbl) => tbl.day.equals(today))
        ..where((tbl) => tbl.weight.isNotNull())
        ..where((tbl) => tbl.weight.isNotValue(0)))
      .getSingleOrNull();

  // 2. 식단 기록 확인 (하나라도 있으면 기록한 것으로 간주)
  final dietRecord = await (db.select(db.htDayDiet)
        ..where((tbl) => tbl.day.equals(today))
        ..limit(1))
      .getSingleOrNull();

  // 두 기록이 모두 존재해야 함
  return bodyRecord != null && dietRecord != null;
}
