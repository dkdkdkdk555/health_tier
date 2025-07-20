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
import 'package:my_app/view/tab/usr/sns_connect/naver_login_button.dart';
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
      // handleNaverJoinAndLogin();
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
              const NaverLoginButton(),
              const SizedBox(width: 15), // 버튼 사이 간격
              GestureDetector(
                onTap: () {

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

