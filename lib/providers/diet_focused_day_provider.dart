import 'package:flutter_riverpod/flutter_riverpod.dart';

/*
  식단 화면의 포커스 날짜를 위한 단일 출처(source of truth).

  식단 탭(DocMain 내부 PageView) 인스턴스와, 체중기록 '식단 기록' 버튼으로
  진입하는 /doc/diet 라우트 인스턴스가 이 값을 공유한다.
  덕분에 어느 경로로 날짜를 선택하든, 탭 전환/라우트 종료 후에도 선택 날짜가 보존된다.
 */
final dietFocusedDayProvider = StateProvider<DateTime>((ref) => DateTime.now());
