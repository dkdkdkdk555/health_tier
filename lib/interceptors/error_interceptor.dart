import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_app/model/usr/auth/error_response.dart';
import 'package:my_app/providers/current_page_provider.dart' show currentPageProvider;
import 'package:my_app/providers/usr_auth_providers.dart';
import 'package:my_app/util/navigator_key.dart';
import 'package:my_app/view/tab/usr/get_started_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ErrorInterceptor extends InterceptorsWrapper {
  final Ref ref;
  final Dio dio;

  ErrorInterceptor(this.ref, this.dio);

  bool _isReloginDialogVisible = false;

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final originalRequest = err.requestOptions;

    // 서버 응답이 401 Unauthorized일 경우
    if (err.response?.statusCode == 401) {
      try {
        final errorResponse = ErrorResponse.fromJson(err.response?.data);

        // 'TOKEN_EXPIRED' 코드 처리: 리프레시 토큰으로 재발급 시도
        if (errorResponse.code == 'TOKEN_EXPIRED') {
          debugPrint('액세스 토큰이 만료되었습니다. 재발급을 시도합니다.');

          // 1. SharedPreferences에서 리프레시 토큰과 userId를 가져옵니다.
          final prefs = await SharedPreferences.getInstance();
          final refreshToken = prefs.getString('refreshToken');
          final userId = prefs.getInt('userId');
          
          if (refreshToken != null && userId != null) {

            try {
            // userId가 유효한 경우에만 프로바이더 호출
            // 2. accessTokenRefreshProvider를 호출하여 토큰 재발급
            final newTokenResponse = await ref.read(accessTokenRefreshProvider({
              'refreshToken': refreshToken,
              'userId': userId,
            }).future);

            // 3. 재발급된 토큰을 SharedPreferences에 저장합니다.
            await prefs.setString('accessToken', newTokenResponse.accessToken);
            await prefs.setString('refreshToken', newTokenResponse.refreshToken!);
            await prefs.setInt('userId', newTokenResponse.userId);

            // 4. 원래 요청의 헤더를 새 액세스 토큰으로 업데이트합니다.
            originalRequest.headers['Authorization'] = 'Bearer ${newTokenResponse.accessToken}';
            // Dio 기본 헤더도 갱신
            dio.options.headers['Authorization'] = 'Bearer ${newTokenResponse.accessToken}';

            // 5. 원래 요청을 다시 보냅니다.
            return handler.resolve(await dio.fetch(originalRequest));
            } on DioException catch(e) {
              debugPrint('토큰 재발급 실패: ${e.message}');
              return _showReloginDialog(originalRequest, handler);
            }
          }

          /// refreshToken이나 userId 없음 → 바로 로그인 다이얼로그
          return _showReloginDialog(originalRequest, handler);
        }
        // 'RELOGIN_REQUIRED' 코드 처리: 리프레시 토큰마저 만료
        else if (errorResponse.code == 'RELOGIN_REQUIRED' || errorResponse.code == 'INVALID_TOKEN') {
          debugPrint('리프레시 토큰이 유효하지 않습니다. 다시 로그인해주세요.');
          _showReloginDialog(originalRequest, handler);
        }
      } on Exception catch (e) {
        debugPrint('Error handling 401 response: $e');
      }
    }

    // 401이 아니거나, 401 처리 중 실패한 경우 다음 단계로 에러를 전달
    return handler.next(err);
  }

  Future<void> _showReloginDialog(
      RequestOptions originalRequest,
      ErrorInterceptorHandler handler,
  ) async {
    if (_isReloginDialogVisible) return;
    _isReloginDialogVisible = true;

    final context = navigatorKey.currentContext;
    if (context != null) {
      final currentPage = ref.read(currentPageProvider);
      if (currentPage != 3) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (ctx) {
              return AlertDialog(
                title: const Text('로그인 필요'),
                content: const Text('로그인이 필요한 기능입니다. 로그인해주세요.'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(ctx).pop();
                      _isReloginDialogVisible = false;
                      navigatorKey.currentState?.pushAndRemoveUntil(
                        MaterialPageRoute(builder: (_) => const GetStartedScreen()),
                        (route) => false,
                      );
                    },
                    child: const Text('확인'),
                  ),
                ],
              );
            },
          );
        });
      }

      // UI에서 의미 없는 값 반환
      handler.resolve(Response(
        requestOptions: originalRequest,
        statusCode: 200,
        data: null,
      ));
    }
  }

}