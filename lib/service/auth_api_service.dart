import 'package:dio/dio.dart';
import 'package:my_app/api/api_routes.dart';
import 'package:my_app/api/configure_dio.dart';

class AuthApiService {
  final Dio dio;
   AuthApiService() : dio = DIOConfig().createNoneAuthDio();

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
}
