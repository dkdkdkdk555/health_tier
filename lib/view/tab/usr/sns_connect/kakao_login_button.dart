import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:my_app/extension/cmu_invalidate_collect.dart' show CmuInvalidateCollect;
import 'package:my_app/model/usr/auth/token_response.dart';
import 'package:my_app/service/auth_api_service.dart';
import 'package:my_app/util/dialog_utils.dart';
import 'package:my_app/util/error_message_utils.dart';
import 'package:my_app/util/screen_ratio.dart' show ScreenRatio;
import 'package:my_app/util/user_prefs.dart';
import 'package:my_app/view/tab/usr/sign_progress/agreement_bottom_bar.dart';

class KakaoLoginButton extends ConsumerStatefulWidget {
  const KakaoLoginButton({super.key});

  @override
  ConsumerState<KakaoLoginButton> createState() => _KakaoLoginButtonState();
}

class _KakaoLoginButtonState extends ConsumerState<KakaoLoginButton> {
  final authApi = AuthApiService();
  
  String? accessToken;
  User? kakaoUserInfo;
  String? nickname;

  var htio = 0.0;
  var wtio = 0.0;
  
  Future<void> kakaoLoginButton(BuildContext context) async {
    OAuthToken? token;
    // 카카오톡 실행이 가능하면 카카오톡으로 로그인, 아니면 카카오계정으로 로그인
    if (await isKakaoTalkInstalled()) {
      try {
          token = await UserApi.instance.loginWithKakaoTalk();
          debugPrint('카카오톡으로 로그인 성공');
      } catch (error) {
        debugPrint('카카오톡으로 로그인 실패 $error');

        if(!context.mounted)return;
        // 사용자가 카카오톡 설치 후 디바이스 권한 요청 화면에서 로그인을 취소한 경우,
        // 의도적인 로그인 취소로 보고 카카오계정으로 로그인 시도 없이 로그인 취소로 처리 (예: 뒤로 가기)
        if (error is PlatformException && error.code == 'CANCELED') {
            showAppMessage(context, message: '카카오톡 연동 로그인 실패');
            return;
        }
        // 카카오톡에 연결된 카카오계정이 없는 경우, 카카오계정으로 로그인
        try {
            token = await UserApi.instance.loginWithKakaoAccount();
            debugPrint('카카오계정으로 로그인 성공');
        } catch (error) {
          if(!context.mounted)return;
          showAppMessage(context, message: '카카오톡 연동 로그인 실패');
            debugPrint('카카오계정으로 로그인 실패 $error');
          return;
        }
      }
    } else {
      try {
        token = await UserApi.instance.loginWithKakaoAccount();
      } catch (error) {
        if(!context.mounted)return;
        showAppMessage(context, message: '카카오톡 연동 로그인 실패');
        debugPrint('카카오계정으로 로그인 실패 $error');
        return;
      }
    }

      accessToken = token.accessToken;
      if(accessToken != null) {
        kakaoUserInfo = await UserApi.instance.me();
        debugPrint('토큰 : $accessToken}');
        debugPrint('회원번호 : ${kakaoUserInfo?.id}'); // 4358058783
      }

      try {
        final response = await authApi.verifySnsToken(
            accessToken: accessToken ?? '', 
            snsId:  kakaoUserInfo!.id.toString(),
            snsType: 'kakao'
        );

        if (response.statusCode == 200) {
        final tokenResponse = TokenResponse.fromJson(response.data);
        UserPrefs.settingLoginResponse(tokenResponse);

          if (!context.mounted) return; 
          CmuInvalidateCollect().cmuInvalidateCache(ref); // 캐시 날리기
          debugPrint('✅ 로그인 성공 → JWT 저장 및 홈 이동');
          context.go('/usr/info');
        } else if (response.statusCode == 204) {
          if (!context.mounted) return; 
          debugPrint('🟡 회원가입 필요 → 회원가입 화면 이동');
          _showAgreementBottomBar(context);
        } else { 
          // 기타 다른 http request code

        }

      } on DioException catch(e) {
        if (!context.mounted) return;

        debugPrint('DioException 발생');
        debugPrint('type: ${e.type}');
        debugPrint('message: ${e.message}');
        debugPrint('error: ${e.error}');
        debugPrint('response: ${e.response?.statusCode}');

        showAppDialog(context, message: '로그인 중 서버와의 통신에 실패했습니다.\n반복될 경우 관리자에게 문의 바랍니다.', confirmText: '확인');
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
      handleJoinAndLogin();
    }
  }

  Future<void> handleJoinAndLogin() async {

    try {
      final response = await authApi.joinAndLoginWithSns(
        snsId:  kakaoUserInfo!.id.toString(),
        snsType: 'kakao',
        nickname: nickname ?? '',
      );

      if (response.statusCode == 200) {
        final tokenResponse = TokenResponse.fromJson(response.data);
        UserPrefs.settingLoginResponse(tokenResponse);
        
        CmuInvalidateCollect().cmuInvalidateCache(ref); // 캐시 날리기
        debugPrint('🎉 회원가입 및 로그인 성공');

        if (!mounted) return;
        context.go('/usr/info');
      } else {
        debugPrint('⚠️ 회원가입 실패: ${response.statusCode}');
        if(!mounted)return;
        showAppMessage(context, message: '회원가입에 실패하였습니다.', type: AppMessageType.dialog);
      }
    } catch (e) {
      debugPrint('❌ 예외 발생: $e');
      if(!mounted)return;
      showAppMessage(context, message: '회원가입에 실패하였습니다.', type: AppMessageType.dialog);
    }
  }


  @override
  Widget build(BuildContext context) {
    htio = ScreenRatio(context).heightRatio;
    wtio = ScreenRatio(context).widthRatio;

    return GestureDetector(
      onTap: () {
        kakaoLoginButton(context);
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            'assets/widgets/login_btn_kakao.svg',
            width: 54 * wtio,
            height: 54 * wtio,
            fit: BoxFit.cover,
          ),
          SizedBox(height: 10 * htio,),
          Text(
            '카카오톡',
            style: TextStyle(
              color: Colors.white,
              fontSize: 11 * htio,
              fontFamily: 'Pretendard',
            ),
          )
        ],
      ),
    );
  }
}