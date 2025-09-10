import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_naver_login/flutter_naver_login.dart';
import 'package:flutter_naver_login/interface/types/naver_account_result.dart';
import 'package:flutter_naver_login/interface/types/naver_login_result.dart';
import 'package:flutter_naver_login/interface/types/naver_login_status.dart';
import 'package:flutter_naver_login/interface/types/naver_token.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:my_app/model/usr/auth/token_response.dart';
import 'package:my_app/service/auth_api_service.dart';
import 'package:my_app/util/dialog_utils.dart' show showAppDialog;
import 'package:my_app/util/error_message_utils.dart';
import 'package:my_app/util/screen_ratio.dart' show ScreenRatio;
import 'package:my_app/util/user_prefs.dart';
import 'package:my_app/view/tab/usr/sign_progress/agreement_bottom_bar.dart';
import 'package:my_app/view/tab/usr/usr_info_screen.dart';

class NaverLoginButton extends StatefulWidget {
  const NaverLoginButton({
    super.key
  });

  @override
  State<NaverLoginButton> createState() => _NaverLoginButtonState();
}

class _NaverLoginButtonState extends State<NaverLoginButton> {
  final authApi = AuthApiService();
  
  bool isLogin = false;
  String? accessToken;
  String? expiresAt;
  String? tokenType;
  String? name;
  String? refreshToken;
  NaverAccountResult? userInfo;
  String? nickname;

  var htio = 0.0;
  var wtio = 0.0;

  Future<void> naverLoginButton(BuildContext context) async {
    try {
      final NaverLoginResult res = await FlutterNaverLogin.logIn();
      setState(() {
        isLogin = res.status == NaverLoginStatus.loggedIn;
        if (res.account != null) {
          accessToken = res.accessToken?.accessToken;
          userInfo = res.account;
        }
      });

      debugPrint('${userInfo?.name}');
    } catch (error) {
      debugPrint(error.toString());
      if(!context.mounted)return;
      showAppMessage(context, message: '네이버 계정으로 로그인 중 오류가 발생했습니다.');
    }

    // 안드로이드에서는 .logIn 에서 accessToken을 응답받지 못해서 추가
    if(accessToken == null) {
       try {
        final NaverToken res = await FlutterNaverLogin.getCurrentAccessToken();
        setState(() {
          accessToken = res.accessToken;
        });
      } catch (error) {
        if(!context.mounted)return;
        showAppMessage(context, message: '네이버 계정으로 로그인 중 오류가 발생했습니다.');
        debugPrint('$error');
      }
    }

    try {
      final response = await authApi.verifySnsToken(
        accessToken: accessToken!,
        snsId: userInfo?.id ?? '',
        snsType: 'naver',
      );

      if (response.statusCode == 200) {
        final tokenResponse = TokenResponse.fromJson(response.data);
        UserPrefs.settingLoginResponse(tokenResponse);

        debugPrint('🎉 회원가입 및 로그인 성공');


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

   Future<void> handleNaverJoinAndLogin() async {

    try {
      final response = await authApi.joinAndLoginWithSns(
        snsId: userInfo?.id ?? '',
        snsType: 'naver',
        email: userInfo?.email ?? '',
        name: userInfo?.name ?? '',
        birthday: '${userInfo?.birthYear}-${userInfo?.birthday}',
        nickname: nickname ?? '',
      );

      if (response.statusCode == 200) {
        final tokenResponse = TokenResponse.fromJson(response.data);
        UserPrefs.settingLoginResponse(tokenResponse);

        debugPrint('🎉 회원가입 및 로그인 성공');

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
      builder: (_) => const AgreementBottomBar(),
    );

    if (nickname != null) {
      handleNaverJoinAndLogin();
    }
  }

  @override
  Widget build(BuildContext context) {
    htio = ScreenRatio(context).heightRatio;
    wtio = ScreenRatio(context).widthRatio;
    
    return GestureDetector(
      onTap: () {
        naverLoginButton(context);
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            'assets/widgets/login_btn_naver.svg',
            width: 54 * wtio,
            height: 54 * wtio,
            fit: BoxFit.cover,
          ),
          SizedBox(height: 10 * htio,),
          Text(
            '네이버',
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