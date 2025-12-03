

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_app/api/configure_dio.dart';
import 'package:my_app/model/usr/auth/token_response.dart';
import 'package:my_app/model/usr/auth/token_verification_response.dart';
import 'package:my_app/service/auth_api_service.dart';

final authDioProvider = FutureProvider<Dio>((ref){
  return DIOConfig().createAuthDio(ref);
});

final userAuthService = Provider<AuthApiService>((ref){ // accessToken이 필요없는 요청일 경우 해당 프로바이더를 이용
  return AuthApiService();
});

final userAuthServiceAuthDioProvider = FutureProvider<AuthApiService>((ref) async {
  // authDioProvider가 제공하는 Dio 인스턴스가 준비될 때까지 기다립니다.
  final dio = await ref.watch(authDioProvider.future);
  return AuthApiService.createAuthDioService(dio);
});


// 가입시 닉네임 중복여부 검사
final isUserNicknameDupliateProvider = FutureProvider.family<bool, String>((ref, nickname) async {
  final service = ref.watch(userAuthService);
  return service.checkNicknameDuplicate(nickname);
});

/*
 * 토큰검증 프로바이더
 * => verify-token 컨트롤러는 잘못된 설계의 결과물이다. 해당 api로 로그인 여부를 검증하는 경우, 요청할때 토큰검증여부를 false로 
 * 두었기 때문에 액세스 토큰이 만료되고 나면 리프레시토큰의 만료여부와 상관없이 무조건 로그아웃 상태로 판별한 결과 {"isValid":false}
 * 만을 가지고 클라이언트에서 로그인 요청 팝업을 띄워 처리했다. 액세스토큰 유효기간을 무려 24시간으로 뒀었기 때문에 이걸 출시하고도 여태 눈치채지 
 * 못했던것이다. -> @Authentication(required = true) 으로 토큰검증여부를 필수로 두면서 자연스레 액세스-리프레시 토큰 검증 로직을
 * 타게하여 리프레시 토큰이 유효함에도 로그아웃 상태로 판별하는 문제를 개선하였지만, 컨트롤러를 없에면 기배포된 앱들에서 오류가 발생하고 
 * 해당 컨트롤러를 핵심 로직으로 사용하는 화면(유저메인 분기화면)이 있기때문에 이렇게 기술부채로 남겨두었다.
 * 
 * *왜 기술부채인가?
 * : 엄연한 기술부채의 뜻(확장에 있어 버그/오류 가능성을 내포한 설계 또는 코드)에 부합하는지 모르겠지만,
 *  엑세스 토큰의 유효/만료 여부에 상관없이 verify-token에 요청해도 토큰검증로직이 가로채 결국 무조건 {"isValid":true} 로 만든다.
 *  리프레시 토큰까지 만료된 경우도 재로그인을 요청하는 화면으로 이동시키기에 {"isValid":false}를 볼 수 없다.
 *  그래서 클라이언트 측에서 {"isValid":false} 인 경우 로그인 알림창을 띄우는 로직은 중복 로직이된다.
 * 
 * *사용화면
 * - router.dart : 커뮤탭에서 피드 작성 페이지 이동 버튼 클릭 시 (피드 작성을 마친다음 로그인해야해서 작성물이 날려야 하는 상황을 방지하기 위해)
 * - feed_detail_app_bar.dart : 피드상세 햄버거 버튼 클릭 시 (신고하기 작성 후 로그인해야해서 신고사유가 날라가는 상황을 방지하기 위해)
 * - doc_diet_write.dart : AI연동기능 사용 시 (AI이미지 분석 요청이 사진을 고른 뒤 발생하기 때문에 이때 로그인 여부를 검증하면 리소스가 낭비되고 사용자가 번거로워진다.)
 * - usr_main.dart : 로그인화면 과 유저화면 분기 시 (분기를 위해 검증만을 사용하는 컨트롤러는 필요하긴 하다.)
 * 
 */
final jwtTokenVerificationProvider = FutureProvider.autoDispose<TokenVerificationResponse>((ref) async {
  final service = await ref.watch(userAuthServiceAuthDioProvider.future);
  return await service.verifyToken();
});

/// 리프레시 토큰으로 액세스 토큰을 재발급하는 프로바이더
/// { refreshToken: 리프레시 토큰, userId: 사용자 ID } Map을 인자로 받습니다
final accessTokenRefreshProvider = FutureProvider.family<TokenResponse, Map<String, dynamic>>((ref, args) async {
  final authService = ref.watch(userAuthService);
  final String refreshToken = args['refreshToken'];
  final int userId = args['userId'];

  final TokenResponse response = await authService.refreshAccessToken(
    refreshToken: refreshToken,
    userId: userId,
  );
  
  debugPrint('액세스 토큰 재발급 성공: ${response.accessToken}');
  return response;
});