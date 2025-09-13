import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_app/model/usr/auth/error_response.dart';
import 'package:my_app/providers/current_page_provider.dart' show currentPageProvider;
import 'package:my_app/providers/usr_auth_providers.dart';
import 'package:my_app/util/error_message_utils.dart';
import 'package:my_app/util/user_prefs.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:my_app/main.dart' show rootNavigatorKey;

class ErrorInterceptor extends InterceptorsWrapper {
  final Ref ref;
  final Dio dio;

  ErrorInterceptor(this.ref, this.dio);


  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final originalRequest = err.requestOptions;
    final context = rootNavigatorKey.currentState?.overlay?.context;

    if (err.response?.statusCode == 401) { // 401 Unauthorized
      try {
        final errorResponse = ErrorResponse.fromJson(err.response?.data);
        // 'TOKEN_EXPIRED' 코드 처리: 리프레시 토큰으로 재발급 시도
        if (errorResponse.code == 'TOKEN_EXPIRED') {

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
            UserPrefs.settingLoginResponse(newTokenResponse);
            // 4. 원래 요청의 헤더를 새 액세스 토큰으로 업데이트합니다.
            originalRequest.headers['Authorization'] = 'Bearer ${newTokenResponse.accessToken}';
            // Dio 기본 헤더도 갱신
            dio.options.headers['Authorization'] = 'Bearer ${newTokenResponse.accessToken}';
            // 5. 원래 요청을 다시 보냅니다.
            return handler.resolve(await dio.fetch(originalRequest));
            } on DioException catch(e) {
              debugPrint('토큰 재발급 실패: ${e.message}');
              if(context!=null){
                final currentPage = ref.read(currentPageProvider);
                if (currentPage != 3) {
                  if(!context.mounted)return;
                  showAppMessage(context, title: '로그인이 필요해요', message: '로그인이 필요한 기능입니다. 로그인 후 이용해주세요.', type: AppMessageType.dialog, loginRequest: true);
                  _returnUiOkStatus(handler, originalRequest);
                }
              }
            }
          }
        }
        // 'RELOGIN_REQUIRED' 코드 처리: 리프레시 토큰마저 만료
        else if (errorResponse.code == 'RELOGIN_REQUIRED' || errorResponse.code == 'INVALID_TOKEN') {
          
          // _showReloginDialog(originalRequest, handler);
          final currentPage = ref.read(currentPageProvider);
            if (currentPage != 3) {
            if(context!=null){
              showAppMessage(context,title: '로그인이 필요해요', message: '로그인이 필요한 기능입니다. 로그인 후 이용해주세요.',type: AppMessageType.dialog, loginRequest: true);
              return _returnUiOkStatus(handler, originalRequest);
            }
          }
        }
      } on Exception catch (e) {
        debugPrint('Error handling 401 response: $e');
      }
    }  

    else if (err.response?.statusCode == 400) { // Bad Request
      // 서버 예외: NoCreationDataException, IllegalStateException, MultipartException 등
      // 코드명: BAD_REQUEST
      if(context!=null){
        showAppMessage(context, message: err.response?.data['message'] ?? '잘못된 요청입니다.', type: AppMessageType.dialog);
        return _returnUiOkStatus(handler, originalRequest);
      }
      
    } 

    else if (err.response?.statusCode == 404) { // Not Found
      // 서버 예외: NoFoundFeedException
      // 코드명: NOT_FOUND
      if(context!=null){
        showAppMessage(context, message: err.response?.data['message'] ?? '해당 요청을 찾을 수 없습니다.', type: AppMessageType.dialog);
        return _returnUiOkStatus(handler, originalRequest);
      }
    } 

    else if (err.response?.statusCode == 406) { // Not Acceptable
      // 서버 예외: FileUploadMissException
      // 코드명: NOT_ACCEPTABLE
      if(context!=null){
        showAppMessage(context, message: err.response?.data['message'] ?? '파일 업로드에 실패하였습니다.', type: AppMessageType.dialog);
        return _returnUiOkStatus(handler, originalRequest);
      }
    } 

    else if (err.response?.statusCode == 409) {  // Conflict
      // 서버 예외: DuplicateKeyException, PSQLException(ht_crtifi_usrs_pkey)
      // 코드명: CONFLICT
      if(context!=null){
        showAppMessage(context, message: err.response?.data['message'] ?? '요청 실패, 다시 시도해주세요.', type: AppMessageType.dialog);
        return _returnUiOkStatus(handler, originalRequest);
      }
    } 
    
    else if (err.response?.statusCode == 413) { // Payload Too Large
      // 서버 예외: MaxUploadSizeExceededException
      // 코드명: PAYLOAD_TOO_LARGE
      if(context!=null){
        showAppMessage(context, message: err.response?.data['message'] ?? '파일 크기가 제한(20MB)을 초과하였습니다.', type: AppMessageType.dialog);
        return _returnUiOkStatus(handler, originalRequest);
      }
    } 

    else if (err.response?.statusCode == 500) { // Internal Server Error
      // 서버 예외: Exception
      // 코드명: INTERNAL_SERVER_ERROR
      if(context!=null){
        showAppMessage(context, message: '알 수 없는 오류가 발생했습니다.\n반복될 경우 관리자에게 문의해주세요.', type: AppMessageType.dialog);
        return _returnUiOkStatus(handler, originalRequest);
      }
    } 
    
    else {
      // 처리하지 않은 기타 에러
    }


    // 위 에러코드들 처리 중 실패한 경우, 다루지 않는 에러코드의 경우 다음 단계로 에러를 전달
    return handler.next(err);
  }
  
  // UI에서 의미 없는 값 반환
  void _returnUiOkStatus(ErrorInterceptorHandler handler,  RequestOptions originalRequest,){
    handler.resolve(Response(
      requestOptions: originalRequest,
      statusCode: 200,
      data: null,
    ));
  }

}