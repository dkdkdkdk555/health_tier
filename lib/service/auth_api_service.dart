import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:my_app/api/api_routes.dart';
import 'package:my_app/api/configure_dio.dart';
import 'package:my_app/model/usr/auth/token_response.dart';
import 'package:my_app/model/usr/auth/token_verification_response.dart';
import 'package:shared_preferences/shared_preferences.dart';
class AuthApiService {
  final Dio dio;
   AuthApiService() : dio = DIOConfig().createNoneAuthDio();
   AuthApiService.createAuthDioService(this.dio);

  // 네이버 토큰 검증 및 응답 전체 반환
  Future<Response> verifySnsToken({
    required String accessToken,
    required String snsId,
    required String snsType,
  }) async {
    return await dio.post(
      AuthAPI.verifyValidTokenOrSigned,
      data: {
        'snsId': snsId,
        'snsType': snsType,
        'accessToken': accessToken,
      },
    );
  }

  // 네이버 회원가입 + 로그인 → JWT 발급
  Future<Response> joinAndLoginWithSns({
    required String snsId,
    required String snsType,
    String? email,
    String? name,
    String? birthday,
    required String nickname,
  }) async {
    return await dio.post(
      AuthAPI.joinAndLoginWithSns,
      data: {
        'snsId': snsId,
        'snsType': snsType,
        'email': email,
        'name': name,
        'birthday': birthday,
        'nickname': nickname,
      },
    );
  }

  // 회원가입 절차 - 닉네임 입력 시 중복방지 로직
  Future<bool> checkNicknameDuplicate(String nickname) async {
    try {
      final response = await dio.get(
        AuthAPI.checkNickname,
        queryParameters: {'nickname': nickname},
      );
      if (response.statusCode == 200) {
        return response.data as bool;
      } else {
        throw Exception('Nickname check failed');
      }
    } catch (e) {
      rethrow; // 예외를 다음계층(UI)에서 처리하도록 떠넘김
    }
  }

   // JWT 토큰 검증 메서드
  Future<TokenVerificationResponse> verifyToken() async {
    try {
      final response = await dio.post(AuthAPI.verifyToken);

      if (response.statusCode == 200) {
        return TokenVerificationResponse.fromJson(response.data);
      } else {
        throw Exception('Unexpected status code: ${response.statusCode}');
      }
    } catch (e) {
      // 네트워크 오류, Dio 자체 오류 등은 여기서 캐치됨
      throw Exception('Failed to verify token: $e');
    }
  }

  // accessToken 재발급요청 api
  Future<TokenResponse> refreshAccessToken({
    required String refreshToken,
    required int userId,
  }) async {
    final response = await dio.post(
      AuthAPI.refreshAccessToken,
      data: {
        "refreshToken": refreshToken,
        "userId": userId,
      },
    );

    debugPrint('코드 : ${response.statusCode}');
    debugPrint('${response.data}');
    
    return TokenResponse.fromJson(response.data);
  }

  // id, pw로 로그인요청
  Future<Response> loginWithIdAndPw({
    required String loginId,
    required String password,
  }) async {
    final response = await dio.post(
      AuthAPI.loginWithIdAndPw,
      data: {
        "loginId": loginId,
        "password": password,
      },
    );

    debugPrint('코드 : ${response.statusCode}');
    debugPrint('${response.data}');
    
    return response;
  }
}
