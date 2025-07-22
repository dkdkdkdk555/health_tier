import 'package:dio/dio.dart';
import 'package:my_app/api/api_routes.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DIOConfig {

  Dio createNoneAuthDio() {
    final dio = Dio();

    dio.options = BaseOptions(
      baseUrl: APIServer.baseUrl,
      connectTimeout: const Duration(seconds: 100),
      receiveTimeout: const Duration(seconds: 106),
      contentType: 'application/json',
      // headers, contentType, responseType 등도 여기서 설정 가능
    );

    return dio;
  }

  Future<Dio> createAuthDio(String contentType) async {
    final dio = Dio();
    final prefs = await SharedPreferences.getInstance();
    final jwtToken = prefs.getString('jwt_token');

    dio.options = BaseOptions(
      baseUrl: APIServer.baseUrl,
      connectTimeout: const Duration(seconds: 100),
      receiveTimeout: const Duration(seconds: 106),
      contentType: contentType,
      headers: {
        if (jwtToken != null) 'Authorization': 'Bearer $jwtToken',
      },
    );

    return dio;
  }
  
}