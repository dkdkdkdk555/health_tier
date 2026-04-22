import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_app/api/api_routes.dart';
import 'package:my_app/interceptors/error_interceptor.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DIOConfig {

  Dio createNoneAuthDio() {
    final dio = Dio();

    dio.options = BaseOptions(
      baseUrl: APIServer.baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 6),
      contentType: 'application/json',
      // headers, contentType, responseType 등도 여기서 설정 가능
    );

    return dio;
  }

  Future<Dio> createAuthDio(Ref ref) async {
    final dio = Dio(BaseOptions(
      baseUrl: APIServer.baseUrl,
      connectTimeout: const Duration(seconds: 1000),
      receiveTimeout: const Duration(seconds: 600),
      contentType: 'application/json',
      // 초기 Authorization 헤더는 비워두거나 기본값 설정
      headers: {'Authorization': 'Bearer '},
    ));

    // ErrorInterceptor 추가 (401 등 에러 처리)
    dio.interceptors.add(ErrorInterceptor(ref, dio));

    // 요청마다 최신 토큰 반영
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final prefs = await SharedPreferences.getInstance();
        final jwtToken = prefs.getString('accessToken');
        options.headers['Authorization'] = 'Bearer ${jwtToken ?? ''}';
        handler.next(options); // 요청 진행
      },
    ));

    return dio;
  }

  Dio createDioWithAuth(String? accessToken) {
    final dio = Dio();
    dio.options = BaseOptions(
      baseUrl: APIServer.baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 6),
      contentType: 'application/json',
      headers: {
        'Authorization': 'Bearer ${accessToken ?? ''}',
      },
    );
    return dio;
  }
  
}