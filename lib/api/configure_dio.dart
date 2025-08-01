import 'package:dio/dio.dart';
import 'package:my_app/api/api_routes.dart';
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

  Future<Dio> createAuthDio() async {
    final dio = Dio();
    final prefs = await SharedPreferences.getInstance();
    final jwtToken = prefs.getString('jwt_token');

    dio.options = BaseOptions(
      baseUrl: APIServer.baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 6),
      contentType: 'application/json',
      headers: {
       'Authorization': 'Bearer ${jwtToken ?? ''}',
      },
    );

    return dio;
  }
  
}