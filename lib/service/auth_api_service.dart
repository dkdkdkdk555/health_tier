import 'package:dio/dio.dart';
import 'package:my_app/api/api_routes.dart';
import 'package:my_app/api/configure_dio.dart';
import 'package:my_app/exceptions/api_error_exception.dart';
import 'package:my_app/exceptions/relogin_required_exception.dart';
import 'package:my_app/model/usr/auth/error_response.dart';
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
      rethrow;
    }
  }

   // JWT 토큰 검증 메서드
  Future<TokenVerificationResponse> verifyToken() async {
    try {
      final response = await dio.post(
        AuthAPI.verifyToken,
      );

      // 상태 코드 200, 401, 500 등 모두 DioError를 발생시키지 않고 response.data에 결과가 담김
      if (response.statusCode == 200) {
        return TokenVerificationResponse.fromJson(response.data);
      } else {
        // 200 외의 다른 성공 코드 (예: 201)가 올 수도 있으나,
        // 서버 코드에 따르면 success는 200, 나머지는 에러 상태 코드를 반환
        // 만약 서버에서 200이 아닌 다른 성공 코드를 보낸다면 여기서 처리
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          error: 'Unexpected status code: ${response.statusCode}',
          type: DioExceptionType.badResponse,
        );
      }
    } on DioException catch (e) {
      // DioError (네트워크 오류, 타임아웃, 4xx/5xx 상태 코드 등) 처리
      if (e.response != null) {
        // 서버로부터 응답은 왔으나 에러 상태 코드인 경우
        // 서버 컨트롤러에 따라 400, 401, 500 등이 발생할 수 있음
        return TokenVerificationResponse.fromJson(e.response!.data);
      } else {
        // 네트워크 연결 문제 또는 요청 전 발생한 에러
        throw Exception('Failed to connect to the server or unknown Dio error: ${e.message}');
      }
    } catch (e) {
      // 그 외 알 수 없는 에러
      throw Exception('An unexpected error occurred: $e');
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
    return TokenResponse.fromJson(response.data);
  }
}
