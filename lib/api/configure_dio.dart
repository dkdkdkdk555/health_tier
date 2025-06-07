import 'package:dio/dio.dart';
import 'package:my_app/api/api_routes.dart';

class DIOConfig {
// dio 설정 클래스
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
  
}