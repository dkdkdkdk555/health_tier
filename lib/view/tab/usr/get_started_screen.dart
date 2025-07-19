import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_naver_login/flutter_naver_login.dart';
import 'package:flutter_naver_login/interface/types/naver_account_result.dart';
import 'package:flutter_naver_login/interface/types/naver_login_result.dart';
import 'package:flutter_naver_login/interface/types/naver_login_status.dart';
import 'package:flutter_naver_login/interface/types/naver_token.dart';
import 'package:my_app/service/auth_api_service.dart';
import 'package:my_app/view/tab/usr/sign_progress/agreement_bottom_bar.dart';
import 'package:my_app/view/tab/usr/sns_connect/naver_login.dart';
import 'package:my_app/view/tab/usr/usr_info_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GetStartedScreen extends StatefulWidget {
  const GetStartedScreen({super.key});

  @override
  State<GetStartedScreen> createState() => _GetStartedScreenState();
}

class _GetStartedScreenState extends State<GetStartedScreen> {
  final authApi = AuthApiService();

  // login Naver
  bool isLogin = false;
  String? accessToken;
  String? expiresAt;
  String? tokenType;
  String? name;
  String? refreshToken;
  NaverAccountResult? userInfo;
  String? nickname;

  Future<void> buttonLoginPressed(BuildContext context) async {
    try {
      debugPrint('buttonLoginPressed 호출');
      final NaverLoginResult res = await FlutterNaverLogin.logIn();
      setState(() {
        isLogin = res.status == NaverLoginStatus.loggedIn;
        if (res.account != null) {
          accessToken = res.accessToken?.accessToken;
          debugPrint('$accessToken');
          debugPrint('${res.accessToken?.tokenType}');
          debugPrint('${res.status}');
          debugPrint('${res.errorMessage}');
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
      final response = await authApi.verifyNaverToken(
        accessToken: accessToken!,
        id: userInfo?.id ?? '',
        name: userInfo?.name ?? '',
        birthday: userInfo?.birthday ?? '',
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
      final response = await authApi.joinAndLoginNaver(
        id: userInfo?.id ?? '',
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

   Future<void> buttonLogoutAndDeleteTokenPressed() async {
    try {
      final NaverLoginResult res =
          await FlutterNaverLogin.logOutAndDeleteToken();
      if (res.status == NaverLoginStatus.loggedOut) {
        setState(() {
          isLogin = false;
          accessToken = null;
          refreshToken = null;
          tokenType = null;
          expiresAt = null;
          userInfo = null;
        });
      }
    } catch (error) {
      // _showSnackError(error.toString());
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
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFFFFFFF),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 145.0, bottom: 0, left: 20, right: 20),
            child: Icon(
              Icons.accessibility_new,
              size: 148,
              color: Colors.amber.shade800,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 140),
            child: Text(
              '성장을 눈으로 보는 방법,\n헬스티어',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 20,
                color: Colors.amber.shade800
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(13.0),
            child: Text(
              '- SNS 간편 로그인 -',
              style: TextStyle(
                fontWeight: FontWeight.w300,
                fontFamily: 'Pretendard',
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () {
                  buttonLoginPressed(context);
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
              ),
              const SizedBox(width: 15), // 버튼 사이 간격

              GestureDetector(
                onTap: () {
                  buttonLogoutAndDeleteTokenPressed();
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
              ),
              const SizedBox(width: 15), // 버튼 사이 간격

              GestureDetector(
                onTap: () => _showAgreementBottomBar(context),
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.black, // 검은색
                  ),
                   child: const Align(
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.apple_outlined,
                      color: Color(0xFFFFFFFF),
                      size: 26,
                    )
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

