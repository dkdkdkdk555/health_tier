import 'package:flutter_riverpod/flutter_riverpod.dart';
/*
  UsrMain 에서 엑세스토큰 유효 여부를 검사하는 api를 호출하고 
  최종 응답으로 RELOGIN_REQUIRED 를 받은 경우 로그인이 필요하다는 팝업을 띄우지 않고  
  바로 로그인 화면(시작하기화면)을 보여주기 위해 해당 프로바이더를 사용
 */
final currentPageProvider = StateProvider<int>((ref) => 0);
