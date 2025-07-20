import 'package:dio/dio.dart';
import 'package:my_app/api/api_routes.dart';
import 'package:my_app/api/configure_dio.dart';

class AuthApiService {
  final Dio dio;
   AuthApiService() : dio = DIOConfig().createNoneAuthDio();

  // 네이버 토큰 검증 및 응답 전체 반환
  Future<Response> verifyNaverToken({
    required String accessToken,
    required String snsId,
    required String name,
    required String birthday,
  }) async {
    return await dio.post(
      AuthAPI.verifyValidTokenOrSigned,
      data: {
        'accessToken': accessToken,
        'snsId': snsId,
        'snsType': 'naver',
        'name': name,
        'birthday': birthday,
      },
    );
  }

  // 네이버 회원가입 + 로그인 → JWT 발급
  Future<Response> joinAndLoginNaver({
    required String snsId,
    required String email,
    required String name,
    required String birthday,
    required String nickname,
  }) async {
    return await dio.post(
      '/auth/naver/join',
      data: {
        'snsId': snsId,
        'snsType': 'naver',
        'email': email,
        'name': name,
        'birthday': birthday,
        'nickname': nickname,
      },
    );
  }
}
