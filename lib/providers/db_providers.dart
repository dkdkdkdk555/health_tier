import 'package:drift/drift.dart';
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

  final result = await db.customSelect(
    '''
    SELECT
      B.ID AS ID,
      B.DAY AS DAY,
      B.WKOUT_YN AS WKOUT_YN,
      B.DRUNK_YN AS DRUNK_YN,
      B.WEIGHT AS WEIGHT,
      B.STAMP AS STAMP,
      IFNULL(SUM(D.CALORIE), 0) AS TOTAL_CALORIE,
      IFNULL(SUM(D.PROTEIN), 0) AS TOTAL_PROTEIN
    FROM HT_DAY_BODY B
    LEFT JOIN HT_DAY_DIET D ON B.DAY = D.DAY
    WHERE B.DAY = ?
    GROUP BY B.ID, B.DAY, B.WKOUT_YN, B.DRUNK_YN, B.WEIGHT, B.STAMP
    ''',
    variables: [Variable.withString(day)],
  ).getSingleOrNull();

  return result == null ? null : DocDayDetail.fromRow(result);
});
