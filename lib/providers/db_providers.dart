import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_app/database/app_database.dart';
import 'package:my_app/model/doc_detail_model.dart' show DocDayDetail;
import 'package:my_app/model/doc_main_model.dart';

/// 1. AppDatabase 인스턴스를 제공하는 Provider
final databaseProvider = Provider<AppDatabase>((ref) {
  return AppDatabase();
});

/*
 1-1 체중기록 조회 페이지 <캘린더뷰 & 테이블뷰> 목록조회
*/
final htDayDocOfMonth = FutureProvider.family<List<DocDayInfo>, String>((ref, yearMonth) async {
  final db = ref.watch(databaseProvider);
  final pattern = '$yearMonth%'; //ref.watch(htDayDocOfMonth('2025-04')) // 이렇게만 넘겨주면 됨!

  final result = await db.customSelect(
    '''
    SELECT
      DAY,
      MAX(WEIGHT) AS WEIGHT,
      SUM(CALORIE) AS TOTAL_CALORIE,
      STAMP
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

  final totalCalorie = diets.fold<double>(0, (sum, e) => sum + (e.calorie ?? 0));
  final totalProtein = diets.fold<double>(0, (sum, e) => sum + (e.protein ?? 0));

  debugPrint('totalCalorie: $totalCalorie');

  return DocDayDetail(
    id: body?.id ?? -1, // htDayBody에 기록이 없을경우, -1을 리턴,
    day: day,
    workYn: body?.wkoutYn,
    drunYn: body?.drunkYn,
    weight: body?.weight,
    stamp: body?.stamp,
    memo: body?.memo,
    totalCalorie: totalCalorie == 0 ? null : totalCalorie,
    totalProtein: totalProtein == 0 ? null : totalProtein,
  );
});

/*
  1-1 체중기록 조회 페이지 직전 체중 기록 가져오기
*/
final getPreviousWeight = FutureProvider.family<double?, int>((ref, currentId) async {
  final db = ref.watch(databaseProvider);

  final previous = await (db.select(db.htDayBody)
        ..where((tbl) => tbl.id.equals(currentId - 1)))
      .getSingleOrNull();

  return previous?.weight;
});
