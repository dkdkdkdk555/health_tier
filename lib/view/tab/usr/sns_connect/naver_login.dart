import 'package:flutter/material.dart';
import 'package:flutter_naver_login/interface/types/naver_login_result.dart';
import 'package:flutter_naver_login/interface/types/naver_login_status.dart';
import 'package:flutter_naver_login/interface/types/naver_token.dart';
import 'package:flutter_naver_login/flutter_naver_login.dart';
import 'package:flutter_naver_login/interface/types/naver_account_result.dart';



class NaverLogin extends StatefulWidget {
  const NaverLogin({super.key});

  @override
  State<NaverLogin> createState() => _NaverLoginState();
}

class _NaverLoginState extends State<NaverLogin> {

  bool isLogin = false;
  String? accessToken;
  String? expiresAt;
  String? tokenType;
  String? name;
  String? refreshToken;
  NaverAccountResult? userInfo;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: SizedBox(
        height: 1000,
        child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '로그인 상태',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text('isLogin: $isLogin'),
                      const Divider(),
                      const Text(
                        '토큰 정보',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text('accessToken: $accessToken'),
                      Text('refreshToken: $refreshToken'),
                      Text('tokenType: $tokenType'),
                      Text('expiresAt: $expiresAt'),
                      const Divider(),
                      const Text(
                        '사용자 정보',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      if (userInfo != null) ...[
                        Text('ID: ${userInfo?.id}'),
                        Text('이름: ${userInfo?.name}'),
                        Text('닉네임: ${userInfo?.nickname}'),
                        Text('이메일: ${userInfo?.email}'),
                        Text('성별: ${userInfo?.gender}'),
                        Text('나이: ${userInfo?.age}'),
                        Text('생일: ${userInfo?.birthday}'),
                        Text('출생년도: ${userInfo?.birthYear}'),
                        Text('프로필 이미지: ${userInfo?.profileImage}'),
                        Text('휴대폰 번호: ${userInfo?.mobile}'),
                        Text('E164 형식 휴대폰 번호: ${userInfo?.mobileE164}'),
                      ] else
                        const Text('사용자 정보 없음'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: buttonLoginPressed,
                child: const Text("로그인"),
              ),
              ElevatedButton(
                onPressed: buttonLogoutPressed,
                child: const Text("로그아웃"),
              ),
              ElevatedButton(
                onPressed: buttonLogoutAndDeleteTokenPressed,
                child: const Text("로그아웃 및 토큰 삭제"),
              ),
              ElevatedButton(
                onPressed: buttonTokenPressed,
                child: const Text("토큰 정보 가져오기"),
              ),
              ElevatedButton(
                onPressed: buttonGetUserPressed,
                child: const Text("사용자 정보 가져오기"),
              ),
            ]
        ),
      ),
    );
  }

   Future<void> buttonLoginPressed() async {
    try {
      final NaverLoginResult res = await FlutterNaverLogin.logIn();
      setState(() {
        isLogin = res.status == NaverLoginStatus.loggedIn;
        if (res.account != null) {
          userInfo = res.account;
        }
      });
    } catch (error) {
      // _showSnackError(error.toString());
    }
  }

  Future<void> buttonTokenPressed() async {
    try {
      final NaverToken res = await FlutterNaverLogin.getCurrentAccessToken();
      setState(() {
        refreshToken = res.refreshToken;
        accessToken = res.accessToken;
        tokenType = res.tokenType;
        expiresAt = res.expiresAt;
        isLogin = res.isValid();
      });
    } catch (error) {
      // _showSnackError(error.toString());
    }
  }

  Future<void> buttonLogoutPressed() async {
    try {
      final NaverLoginResult res = await FlutterNaverLogin.logOut();
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

  Future<void> buttonGetUserPressed() async {
    try {
      final NaverAccountResult res =
          await FlutterNaverLogin.getCurrentAccount();
      setState(() => userInfo = res);
    } catch (error) {
      // _showSnackError(error.toString());
    }
  }
}