import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:my_app/view/tab/usr/sign_progress/agreement_bottom_bar.dart';
import 'package:my_app/view/tab/usr/sns_connect/kakao_login_button.dart';
import 'package:my_app/view/tab/usr/sns_connect/naver_login_button.dart';

class GetStartedScreen extends StatefulWidget {
  const GetStartedScreen({super.key});

  @override
  State<GetStartedScreen> createState() => _GetStartedScreenState();
}

class _GetStartedScreenState extends State<GetStartedScreen> {
  late String _backgroundImage;
  late String _welcomeMeant;

  final List<String> _images = [
    'assets/image/background1.png',
    'assets/image/background2.png',
    'assets/image/background3.png',
  ];

  final List<String> _welcomes = [
    'SNS계정으로 뱃지를 획득하고\n어디서든 기록을 연동해보세요',
    '회원가입으로 다른 유저들과 소통하고\n성장을 눈으로 확인하세요',
    '오늘 운동은 어떠셨나요?\n가입하여 다른 유저들과 나눠보세요'
  ];

  @override
  void initState() {
    super.initState();

    // 화면 방향 세로로 고정
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    _pickRandomBackground();
  }

  @override
  void dispose() {
    // 원래대로 모든 방향 허용
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    super.dispose();
  }

  void _pickRandomBackground() {
    final random = Random();
    final nextInt = random.nextInt(_images.length);
    _backgroundImage = _images[nextInt];
    _welcomeMeant = _welcomes[nextInt];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 배경 이미지
          SizedBox.expand(
            child: Image.asset(
              _backgroundImage,
              fit: BoxFit.cover, // 화면 꽉 채우고 비율 유지
              color: Colors.black.withAlpha(128), // 0~255, 128 = 50% 투명
              colorBlendMode: BlendMode.darken, // 이미지와 색 섞기
            ),
          ),

          // UI 위젯들
          SafeArea(
            child: Stack(
              children: [
                Positioned(
                  top: MediaQuery.of(context).size.height * 0.4, // 화면 상단에서 30% 위치
                  left: 20,
                  right: 20,
                  child: Text(
                    _welcomeMeant,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'Pretendard',
                      color: Colors.white,
                      fontSize: 17,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 202, // 화면 하단에서 80px 위
                  left: 20,
                  right: 20,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Container(
                            height: 1,
                            decoration: const BoxDecoration(
                              color: Color(0xFF777777),
                            ),
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: Text(
                            '다음으로 로그인',
                             textAlign: TextAlign.center,
                             style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontFamily: 'Pretendard',
                              height: 0.09,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            height: 1,
                            decoration: const BoxDecoration(
                              color: Color(0xFF777777),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  bottom: 60,
                  left: 20,
                  right: 20,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    spacing: 26,
                    children: [
                      const KakaoLoginButton(),
                      const NaverLoginButton(),
                      _makeLoginBtn('assets/widgets/login_btn_apple.svg', '애플'),
                    ],
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Column _makeLoginBtn(String svg, String name) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SvgPicture.asset(
          svg,
          width: 54,
          height: 54,
          fit: BoxFit.cover,
        ),
        const SizedBox(height: 10,),
        Text(
          name,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontFamily: 'Pretendard',
          ),
        )
      ],
    );
  }
}
