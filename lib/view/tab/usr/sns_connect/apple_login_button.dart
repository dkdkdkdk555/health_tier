import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_naver_login/interface/types/naver_account_result.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:my_app/extension/cmu_invalidate_collect.dart' show CmuInvalidateCollect;
import 'package:my_app/model/usr/auth/token_response.dart';
import 'package:my_app/providers/usr_auth_providers.dart' show jwtTokenVerificationProvider;
import 'package:my_app/service/auth_api_service.dart';
import 'package:my_app/util/dialog_utils.dart' show showAppDialog;
import 'package:my_app/util/error_message_utils.dart';
import 'package:my_app/util/screen_ratio.dart' show ScreenRatio;
import 'package:my_app/util/user_prefs.dart';
import 'package:my_app/view/tab/usr/sign_progress/agreement_bottom_bar.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class AppleLoginButton extends ConsumerStatefulWidget {
  const AppleLoginButton({
    super.key
  });

  @override
  ConsumerState<AppleLoginButton> createState() => _AppleLoginButtonState();
}

class _AppleLoginButtonState extends ConsumerState<AppleLoginButton> {
  final authApi = AuthApiService();
  
  bool isLogin = false;
  String? expiresAt;
  String? tokenType;
  String? name;
  String? refreshToken;
  AuthorizationCredentialAppleID? appleUser;
  String? nickname;

  var htio = 0.0;
  var wtio = 0.0;

  Future<void> appleLoginButton(BuildContext context) async {
    try {
      // 애플 로그인 -> 유저정보 가져오기
      appleUser = await SignInWithApple.getAppleIDCredential(
                  scopes: [
                    AppleIDAuthorizationScopes.email,
                    AppleIDAuthorizationScopes.fullName,
                  ],);

      debugPrint('Apple Credential : $appleUser');
      if(appleUser?.identityToken == null || appleUser?.userIdentifier == null) {
        if(!context.mounted)return;
        showAppMessage(context, message: 'Apple 연동 정보를 가져오지 못했습니다.');
        return;
      }

    } catch (error) {
      debugPrint(error.toString());
      if(!context.mounted)return;
      showAppMessage(context, message: 'Apple 계정으로 로그인 중 오류가 발생했습니다.');
    }

    try {
      final response = await authApi.verifySnsToken(
        accessToken: appleUser?.identityToken ?? '',
        snsId: appleUser?.userIdentifier ?? '',
        snsType: 'apple',
      );

      if (response.statusCode == 200) {
        final tokenResponse = TokenResponse.fromJson(response.data);
        UserPrefs.settingLoginResponse(tokenResponse);

        debugPrint('🎉 회원가입 및 로그인 성공');
        CmuInvalidateCollect().cmuInvalidateCache(ref); // 캐시 날리기

        if (!context.mounted) return; 
        debugPrint('✅ 로그인 성공 → JWT 저장 및 홈 이동');
        context.go('/usr/info');
      } else if (response.statusCode == 204) {
        if (!context.mounted) return; 
        debugPrint('🟡 회원가입 필요 → 회원가입 화면 이동');
        _showAgreementBottomBar(context);
      } else { 
        // 기타 다른 http request code

      }
    } on DioException catch (e) {
        if (!context.mounted) return;

        debugPrint('DioException 발생');
        debugPrint('type: ${e.type}');
        debugPrint('message: ${e.message}');
        debugPrint('error: ${e.error}');
        debugPrint('response: ${e.response?.statusCode}');

        showAppDialog(context, message: '로그인 중 서버와의 통신에 실패했습니다.\n반복될 경우 관리자에게 문의 바랍니다.', confirmText: '확인');
    }
  }

   Future<void> handleAppleJoinAndLogin() async {

    try {

      final response = await authApi.joinAndLoginWithSns(
        snsId: appleUser?.userIdentifier ?? '',
        snsType: 'apple',
        email: appleUser?.email ?? '',
        name: '${appleUser?.familyName ?? ''}${appleUser?.givenName ?? ''}',
        nickname: nickname ?? '',
      );

      if (response.statusCode == 200) {
        final tokenResponse = TokenResponse.fromJson(response.data);
        await UserPrefs.settingLoginResponse(tokenResponse);

        debugPrint('🎉 회원가입 및 로그인 성공');
        CmuInvalidateCollect().cmuInvalidateCache(ref); // 캐시 날리기

        if (!mounted) return;
        context.go('/usr/info');
      } else {
        if(!mounted)return;
        showAppMessage(context, message: '회원가입에 실패하였습니다.', type: AppMessageType.dialog);
        debugPrint('⚠️ 회원가입 실패: ${response.statusCode}');
      }
    } catch (e) {
      if(!mounted)return;
      showAppMessage(context, message: '회원가입에 실패하였습니다.', type: AppMessageType.dialog);
      debugPrint('❌ 예외 발생: $e');
    }
  }

  void _showAgreementBottomBar(BuildContext context) async {
    nickname = await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useRootNavigator: true, // 네비게이션바 가리기
      builder: (_) => const AgreementBottomBar(),
    );

    if (nickname != null) {
      handleAppleJoinAndLogin();
    }
  }

  @override
  Widget build(BuildContext context) {
    htio = ScreenRatio(context).heightRatio;
    wtio = ScreenRatio(context).widthRatio;
    
    return GestureDetector(
      onTap: () {
        appleLoginButton(context,);
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            'assets/widgets/login_btn_apple.svg',
            width: 54 * wtio,
            height: 54 * wtio,
            fit: BoxFit.cover,
          ),
          SizedBox(height: 10 * htio,),
          Text(
            '애플',
            style: TextStyle(
              color: Colors.white,
              fontSize: 11 * htio,
              fontFamily: 'Pretendard',
            ),
          )
        ],
      )
    );
  }
}