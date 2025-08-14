

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_app/api/configure_dio.dart';
import 'package:my_app/exceptions/api_error_exception.dart';
import 'package:my_app/exceptions/relogin_required_exception.dart';
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

// 토큰검증 프로바이더
final jwtTokenVerificationProvider = FutureProvider<TokenVerificationResponse>((ref) async {
  final service = await ref.watch(userAuthServiceAuthDioProvider.future);
  try {
    return await service.verifyToken();
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

  try {
    final TokenResponse response = await authService.refreshAccessToken(
      refreshToken: refreshToken,
      userId: userId,
    );
    debugPrint('액세스 토큰 재발급 성공: ${response.accessToken}');
    return response;
  } on ReLoginRequiredException catch (e) {
    debugPrint('재로그인 필요: ${e.message}');
    rethrow;
  } on ApiErrorException catch (e) {
    debugPrint('API 에러: ${e.errorResponse.code} - ${e.errorResponse.message}');
    rethrow;
  } catch (e) {
    debugPrint('토큰 재발급 중 예상치 못한 에러 발생: $e');
    rethrow;
  }
});