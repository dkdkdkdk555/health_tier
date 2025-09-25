// 기록탭-하위탭 선택정보 보존을 위한 캐시
import 'package:intl/intl.dart';
import 'package:my_app/model/stc/day_range_param.dart';

int cachedDocTabIndex = 0;

// 통계탭-하위탭 선택정보 보존을 위한 캐시
int cachedStcTabIndex = 0;

// 커뮤탭-하위탭 선택정보 보존을 위한 캐시
int cachedCmuTabIndex = 0;

// 유저탭-하위탭 선택정보 보존을 위한 캐시
int cachedUsrTabIndex = 0;

/// 통계탭의 날짜 검색조건 캐싱
DateTime startDate = DateTime.now().subtract(const Duration(days: 7));
DateTime endDate = DateTime.now();
DayRange cachedDayRange = DayRange(
      DateFormat('yyyy-MM-dd').format(startDate),
      DateFormat('yyyy-MM-dd').format(endDate),
    );

int cachedStcBtnPushed = 0;

String osType = '';

/*
T #FF5656
B #FF9900
P #249DFF
N #FFDE23
G #95D33E
*/