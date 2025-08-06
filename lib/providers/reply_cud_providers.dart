
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_app/api/configure_dio.dart';
import 'package:my_app/service/reply_cud_api_service.dart';

// 토큰 정보를 헤더에 둔 요청객체
final authDioProvider = FutureProvider<Dio>((ref){
  return DIOConfig().createAuthDio();
});

final replyCudServiceProvider = FutureProvider<ReplyCudService>((ref) async {
  final dio = await ref.watch(authDioProvider.future);
  return ReplyCudService(dio);
});