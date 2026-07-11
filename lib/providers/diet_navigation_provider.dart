import 'package:flutter_riverpod/flutter_riverpod.dart';

/*
  체중기록(바디) 화면에서 특정 날짜의 식단 화면으로 바로 이동하기 위한 요청 프로바이더.
  null이 아닌 날짜가 세팅되면
    - DocMain 은 식단 탭으로 전환하고
    - DocDietMain 은 해당 날짜로 focusedDay 를 이동시킨다.
  처리 후에는 다시 null 로 리셋된다.
 */
final dietNavigateRequestProvider = StateProvider<DateTime?>((ref) => null);
