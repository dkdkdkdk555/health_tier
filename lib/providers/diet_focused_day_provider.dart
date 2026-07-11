import 'package:flutter_riverpod/flutter_riverpod.dart';

/*
  식단 화면(DocDietMain)의 포커스 날짜를 위한 단일 출처(source of truth).

  캘린더에서 직접 고르든, 체중기록 '식단 기록' 버튼으로 식단 탭에 진입하든
  이 값을 공유하므로, 탭 전환 후에도 선택 날짜가 보존된다.
 */
final dietFocusedDayProvider = StateProvider<DateTime>((ref) => DateTime.now());
