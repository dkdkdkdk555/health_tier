import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:my_app/util/screen_ratio.dart' show ScreenRatio;
import 'package:my_app/view/tab/simple_cache.dart';
import 'package:my_app/view/tab/usr/sns_connect/apple_login_button.dart';
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

  var htio = 0.0;
  var wtio = 0.0;

  @override
  Widget build(BuildContext context) {
    htio = ScreenRatio(context).heightRatio;
    wtio = ScreenRatio(context).widthRatio;

    final osT = osType;
    debugPrint('os타입 : $osType');

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
          Stack(
            children: [
              Positioned(
                top: MediaQuery.of(context).size.height * 0.432, // 화면 상단에서 30% 위치
                left: 20 * wtio,
                right: 20 * wtio,
                child: Text(
                  _welcomeMeant,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    color: Colors.white,
                    fontSize: 17 * htio,
                  ),
                ),
              ),
              Positioned(
                top: MediaQuery.of(context).size.height * 0.632, // 화면 상단에서 30% 위치
                left: 20 * wtio,
                right: 20 * wtio,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20 * wtio),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Container(
                          height: 1 * htio,
                          decoration: const BoxDecoration(
                            color: Color(0xFF777777),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20 * wtio),
                        child: Text(
                          '다음으로 로그인',
                           textAlign: TextAlign.center,
                           style: TextStyle(
                            color: Colors.white,
                            fontSize: 14 * htio,
                            fontFamily: 'Pretendard',
                            height: 0.09 * htio,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          height: 1 * htio,
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
                top: MediaQuery.of(context).size.height * 0.712, 
                left: 20 * wtio,
                right: 20 * wtio,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  spacing: 26 * wtio,
                  children: [
                    const KakaoLoginButton(),
                    const NaverLoginButton(),
                    if(osT == 'ios')
                    const AppleLoginButton(),
                  ],
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}
