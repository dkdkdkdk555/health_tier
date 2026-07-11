import 'package:flutter_riverpod/flutter_riverpod.dart';

/*
  DocMain 내부 PageView 탭 전환 요청 (0: 체중기록, 1: 식단).

  체중기록 화면의 '식단 기록' 버튼처럼, 자식 위젯에서 상위 DocMain 의 탭을
  전환해야 할 때 사용한다. DocMain 이 값을 소비한 뒤 다시 null 로 리셋한다.
 */
final docTabSwitchRequestProvider = StateProvider<int?>((ref) => null);
