import 'package:flutter/material.dart';
import 'package:flutter_naver_login/flutter_naver_login.dart';
import 'package:flutter_naver_login/interface/types/naver_account_result.dart';
import 'package:flutter_naver_login/interface/types/naver_login_result.dart';
import 'package:flutter_naver_login/interface/types/naver_login_status.dart';
import 'package:flutter_naver_login/interface/types/naver_token.dart';
import 'package:my_app/view/tab/usr/not_user/agreement_bottom_bar.dart';

class GetStartedScreen extends StatefulWidget {
  const GetStartedScreen({super.key});

  @override
  State<GetStartedScreen> createState() => _GetStartedScreenState();
}

class _GetStartedScreenState extends State<GetStartedScreen> {
  bool isLogin = false;
  String? accessToken;
  String? expiresAt;
  String? tokenType;
  String? name;
  String? refreshToken;
  NaverAccountResult? userInfo;

  void _showAgreementBottomBar(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const AgreementBottomBar(),
    );
  }


  @override
  Widget build(BuildContext context) {
    return 
    // Container(
      // decoration: const BoxDecoration(
      //   color: Color(0xFFFFFFFF),
      // ),
      // child: Column(
      //   children: [
          // Padding(
          //   padding: const EdgeInsets.only(top: 145.0, bottom: 0, left: 20, right: 20),
          //   child: Icon(
          //     Icons.accessibility_new,
          //     size: 148,
          //     color: Colors.amber.shade800,
          //   ),
          // ),
          // Padding(
          //   padding: const EdgeInsets.only(bottom: 140),
          //   child: Text(
          //     '성장을 눈으로 보는 방법,\n헬스티어',
          //     textAlign: TextAlign.center,
          //     style: TextStyle(
          //       fontFamily: 'Pretendard',
          //       fontSize: 20,
          //       color: Colors.amber.shade800
          //     ),
          //   ),
          // ),
          // const Padding(
          //   padding: EdgeInsets.all(13.0),
          //   child: Text(
          //     '- SNS 간편 로그인 -',
          //     style: TextStyle(
          //       fontWeight: FontWeight.w300,
          //       fontFamily: 'Pretendard',
          //     ),
          //   ),
          // ),
          // Row(
          //   mainAxisAlignment: MainAxisAlignment.center,
          //   children: [
          //     GestureDetector(
          //       onTap: () => _showAgreementBottomBar(context),
          //       child: Container(
          //         width: 50, // 버튼의 지름
          //         height: 50, // 버튼의 지름
          //         decoration: const BoxDecoration(
          //           shape: BoxShape.circle, // 원형 모양
          //           color: Colors.green, // 초록색
          //         ),
          //         child: const Align(
          //           alignment: Alignment.center,
          //           child: Text(
          //             'N',
          //             style: TextStyle(
          //               fontSize: 21,
          //               fontWeight: FontWeight.bold,
          //               color: Color(0xFFFFFFFF),
          //             ),
          //           ),
          //         ),
          //       ),
          //     ),
          //     const SizedBox(width: 15), // 버튼 사이 간격

          //     GestureDetector(
          //       onTap: () => _showAgreementBottomBar(context),
          //       child: Container(
          //         width: 50,
          //         height: 50,
          //         decoration: const BoxDecoration(
          //           shape: BoxShape.circle,
          //           color: Colors.yellow, // 노란색
          //         ),
          //         child: const Align(
          //           alignment: Alignment.center,
          //           child: Text(
          //             'Kakao',
          //             style: TextStyle(
          //               fontSize: 14,
          //               fontWeight: FontWeight.w400,
          //             ),
          //           ),
          //         ),
          //       ),
          //     ),
          //     const SizedBox(width: 15), // 버튼 사이 간격

          //     GestureDetector(
          //       onTap: () => _showAgreementBottomBar(context),
          //       child: Container(
          //         width: 50,
          //         height: 50,
          //         decoration: const BoxDecoration(
          //           shape: BoxShape.circle,
          //           color: Colors.black, // 검은색
          //         ),
          //          child: const Align(
          //           alignment: Alignment.center,
          //           child: Icon(
          //             Icons.apple_outlined,
          //             color: Color(0xFFFFFFFF),
          //             size: 26,
          //           )
          //         ),
          //       ),
          //     ),
          //   ],
          // ),
          getNaverLogin();
        // ],
      // ),
    // );
  }

  getNaverLogin() {
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

