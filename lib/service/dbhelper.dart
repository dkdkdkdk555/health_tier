import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static Future<Database> initDB() async {
    final dbPath = await getDatabasesPath(); // DB 저장 경로 가져오기
    final path = join(dbPath, 'health_tracker.db'); // 안전하게 경로 조합

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        // 체중 기록 테이블
        await db.execute('''
          CREATE TABLE HT_DAY_BODY (
            ID INTEGER PRIMARY KEY AUTOINCREMENT,
            DAY TEXT NOT NULL,
            WEIGHT REAL,
            MUSCLE REAL,
            FAT REAL,
            MEMO TEXT,
            WKOUT_YN INTEGER DEFAULT 0,
            DRUNK_YN INTEGER DEFAULT 0,
            STAMP TEXT
            UNIQUE (DAY)
          )
        ''');

        // 식단 기록 테이블
        await db.execute('''
          CREATE TABLE HT_DAY_DIET (
            ID INTEGER PRIMARY KEY AUTOINCREMENT,
            DAY TEXT NOT NULL,
            TITLE TEXT NOT NULL,
            DIET TEXT,
            CALORIE REAL,
            PROTEIN REAL,
            UNIQUE (DAY, TITLE)
          )
        ''');
      },
    );
  }
}
