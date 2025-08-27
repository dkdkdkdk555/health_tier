import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:my_app/model/usr/auth/token_response.dart';
import 'package:my_app/service/auth_api_service.dart';
import 'package:my_app/util/user_prefs.dart';
import 'package:my_app/view/tab/usr/sign_progress/agreement_bottom_bar.dart';
import 'package:my_app/view/tab/usr/usr_info_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class KakaoLoginButton extends StatefulWidget {
  const KakaoLoginButton({super.key});

  @override
  State<KakaoLoginButton> createState() => _KakaoLoginButtonState();
}

class _KakaoLoginButtonState extends State<KakaoLoginButton> {
  final authApi = AuthApiService();
  
  String? accessToken;
  User? kakaoUserInfo;
  String? nickname;
  
  Future<void> kakaoLoginButton(BuildContext context) async {
    OAuthToken? token;
    // 카카오톡 실행이 가능하면 카카오톡으로 로그인, 아니면 카카오계정으로 로그인
    if (await isKakaoTalkInstalled()) {
      try {
          token = await UserApi.instance.loginWithKakaoTalk();
          debugPrint('카카오톡으로 로그인 성공');
      } catch (error) {
        debugPrint('카카오톡으로 로그인 실패 $error');

        // 사용자가 카카오톡 설치 후 디바이스 권한 요청 화면에서 로그인을 취소한 경우,
        // 의도적인 로그인 취소로 보고 카카오계정으로 로그인 시도 없이 로그인 취소로 처리 (예: 뒤로 가기)
        if (error is PlatformException && error.code == 'CANCELED') {
            return;
        }
        // 카카오톡에 연결된 카카오계정이 없는 경우, 카카오계정으로 로그인
        try {
            token = await UserApi.instance.loginWithKakaoAccount();
            debugPrint('카카오계정으로 로그인 성공');
        } catch (error) {
            debugPrint('카카오계정으로 로그인 실패 $error');
        }
      }
    } else {
      try {
        token = await UserApi.instance.loginWithKakaoAccount();
        debugPrint('카카오계정으로 로그인 성공');
      } catch (error) {
        debugPrint('카카오계정으로 로그인 실패 $error');
      }
    }

      accessToken = token!.accessToken;
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

          debugPrint('✅ 로그인 성공 → JWT 저장 및 홈 이동');
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const UsrInfoScreen()),
          );

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

        showDialog(
          context: context,
          builder: (_) => const AlertDialog(
            content: Text('로그인 중 서버와의 통신에 실패했습니다.'),
          ),
        );
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
        
        debugPrint('🎉 회원가입 및 로그인 성공');

        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const UsrInfoScreen()),
        );
      } else {
        debugPrint('⚠️ 회원가입 실패: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ 예외 발생: $e');
    }
  }


  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        kakaoLoginButton(context);
      },
      child: Container(
        width: 50,
        height: 50,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.yellow, // 노란색
        ),
        child: const Align(
          alignment: Alignment.center,
          child: Text(
            'Kakao',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }
}