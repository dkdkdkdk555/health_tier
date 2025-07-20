import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_naver_login/flutter_naver_login.dart';
import 'package:flutter_naver_login/interface/types/naver_account_result.dart';
import 'package:flutter_naver_login/interface/types/naver_login_result.dart';
import 'package:flutter_naver_login/interface/types/naver_login_status.dart';
import 'package:flutter_naver_login/interface/types/naver_token.dart';
import 'package:my_app/service/auth_api_service.dart';
import 'package:my_app/view/tab/usr/sign_progress/agreement_bottom_bar.dart';
import 'package:my_app/view/tab/usr/usr_info_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NaverLoginButton extends StatefulWidget {
  const NaverLoginButton({super.key});

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


  Future<void> naverLoginButton(BuildContext context) async {
    try {
      debugPrint('buttonLoginPressed 호출');
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
    }

    // 안드로이드에서는 .logIn 에서 accessToken을 응답받지 못해서 추가
    if(accessToken == null) {
       try {
        final NaverToken res = await FlutterNaverLogin.getCurrentAccessToken();
        setState(() {
          accessToken = res.accessToken;
        });
      } catch (error) {
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
        final jwt = response.data['accessToken'];
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('jwt_token', jwt);

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
    } on DioException catch (e) {
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
        final jwt = response.data['accessToken'];
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('jwt_token', jwt);

        debugPrint('🎉 회원가입 및 로그인 성공: $jwt');

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
    return GestureDetector(
      onTap: () {
        naverLoginButton(context);
      },
      child: Container(
        width: 50, // 버튼의 지름
        height: 50, // 버튼의 지름
        decoration: const BoxDecoration(
          shape: BoxShape.circle, // 원형 모양
          color: Colors.green, // 초록색
        ),
        child: const Align(
          alignment: Alignment.center,
          child: Text(
            'N',
            style: TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.bold,
              color: Color(0xFFFFFFFF),
            ),
          ),
        ),
      ),
    );
  }
}