import 'package:flutter/material.dart';
import 'package:my_app/view/tab/usr/sign_progress/agreement_bottom_bar.dart';
import 'package:my_app/view/tab/usr/sns_connect/kakao_login_button.dart';
import 'package:my_app/view/tab/usr/sns_connect/naver_login_button.dart';

class GetStartedScreen extends StatefulWidget {
  const GetStartedScreen({super.key});

  @override
  State<GetStartedScreen> createState() => _GetStartedScreenState();
}

class _GetStartedScreenState extends State<GetStartedScreen> {
  // login Naver
  bool isLogin = false;
  String? accessToken;
  String? expiresAt;
  String? tokenType;
  String? name;
  String? refreshToken;
  String? nickname;

  Future<void> _showAgreementBottomBar(BuildContext context) async {
    final result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const AgreementBottomBar(),
    );

    if (result != null) {
      setState(() {
        nickname = result;
      });
      // handleJoinAndLogin(); // 로그인/회원가입 처리
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 145),
              Icon(
                Icons.accessibility_new,
                size: 148,
                color: Colors.amber.shade300,
              ),
              const SizedBox(height: 20),
              Text(
                '성장을 눈으로 보는 방법,\n헬스티어',
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: Colors.amber.shade300,
                  fontFamily: 'Pretendard',
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 140),
              const Padding(
                padding: EdgeInsets.all(13.0),
                child: Text(
                  '- SNS 간편 로그인 -',
                  style: TextStyle(
                    fontWeight: FontWeight.w300,
                    fontFamily: 'Pretendard',
                    color: Colors.black
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const NaverLoginButton(),
                  const SizedBox(width: 15),
                  const KakaoLoginButton(),
                  const SizedBox(width: 15),
                  GestureDetector(
                    onTap: () => _showAgreementBottomBar(context),
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.black,
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.apple_outlined,
                          color: Colors.white,
                          size: 26,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }
}
