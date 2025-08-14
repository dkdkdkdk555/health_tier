

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_app/model/usr/auth/token_response.dart';
import 'package:my_app/model/usr/auth/token_verification_response.dart';
import 'package:my_app/service/auth_api_service.dart';

final userAuthService = Provider<AuthApiService>((ref){
  return AuthApiService();
});

// 가입시 닉네임 중복여부 검사
final isUserNicknameDupliateProvider = FutureProvider.family<bool, String>((ref, nickname) async {
  final service = ref.watch(userAuthService);
  return service.checkNicknameDuplicate(nickname);
});

// 토큰검증 프로바이더
final jwtTokenVerificationProvider = FutureProvider<TokenVerificationResponse>((ref) async {
  final authService = ref.watch(userAuthService);
  try {
    return await authService.verifyToken();
  } catch (e) {
    return TokenVerificationResponse(isValid: false, error: e.toString());
  }
});

/// 리프레시 토큰으로 액세스 토큰을 재발급하는 프로바이더
/// { refreshToken: 리프레시 토큰, userId: 사용자 ID } Map을 인자로 받습니다
final accessTokenRefreshProvider = FutureProvider.family<TokenResponse, Map<String, dynamic>>((ref, args) async {
  final authService = ref.watch(userAuthService);
  final String refreshToken = args['refreshToken'];
  final int userId = args['userId'];

  // try {
    final TokenResponse response = await authService.refreshAccessToken(
      refreshToken: refreshToken,
      userId: userId,
    );
    print('액세스 토큰 재발급 성공: ${response.accessToken}');
    return response;
  // } on ReLoginRequiredException catch (e) {
  //   print('재로그인 필요: ${e.message}');
  //   rethrow;
  // } on ApiErrorException catch (e) {
  //   print('API 에러: ${e.errorResponse.code} - ${e.errorResponse.message}');
  //   rethrow;
  // } catch (e) {
  //   print('토큰 재발급 중 예상치 못한 에러 발생: $e');
  //   rethrow;
  // }
});