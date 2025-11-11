import 'dart:async' show Timer;
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' show ConsumerState, ConsumerStatefulWidget;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:my_app/extension/cmu_invalidate_collect.dart' show CmuInvalidateCollect;
import 'package:my_app/model/usr/auth/token_response.dart' show TokenResponse;
import 'package:my_app/service/auth_api_service.dart' show AuthApiService;
import 'package:my_app/util/screen_ratio.dart' show ScreenRatio;
import 'package:my_app/util/user_prefs.dart' show UserPrefs;
import 'package:my_app/view/tab/simple_cache.dart';
import 'package:my_app/view/tab/usr/sns_connect/apple_login_button.dart';
import 'package:my_app/view/tab/usr/sns_connect/kakao_login_button.dart';
import 'package:my_app/view/tab/usr/sns_connect/naver_login_button.dart';

class GetStartedScreen extends ConsumerStatefulWidget {
  const GetStartedScreen({super.key});

  @override
  ConsumerState<GetStartedScreen> createState() => _GetStartedScreenState();
}

class _GetStartedScreenState extends ConsumerState<GetStartedScreen> {
  final authApi = AuthApiService();
  var htio = 0.0;
  var wtio = 0.0;
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
  
  // 텍스트가 눌렸는지 상태를 관리하는 변수
  bool _isPressed = false;
  // 3초 팝업을 위한 타이머
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _pickRandomBackground();
  }

  @override
  void dispose() {
    // 원래대로 모든 방향 허용
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    // 위젯이 제거될 때 타이머가 남아있으면 반드시 취소
    _timer?.cancel();
    super.dispose();
  }

  void _pickRandomBackground() {
    final random = Random();
    final nextInt = random.nextInt(_images.length);
    _backgroundImage = _images[nextInt];
    _welcomeMeant = _welcomes[nextInt];
  }

  // 팝업을 띄우는 함수
  void _showGuestLoginDialog(BuildContext context) {
    // 이미 타이머가 실행되어 팝업을 띄우면, 다시 타이머를 null로 설정하여 중복 실행을 방지합니다.
    _timer = null; 
    final TextEditingController idController = TextEditingController();
    final TextEditingController pwController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        String errorText = ''; // 로컬 에러 메시지 상태

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('관리자/게스트 로그인'),
              content: SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[
                    const Text('숨겨진 기능을 활성화했습니다.'),
                    const SizedBox(height: 20),
                    // 로컬 에러 메시지 표시 (빨간색)
                    if (errorText.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: Text(
                          errorText,
                          style: const TextStyle(color: Colors.red, fontSize: 13),
                        ),
                      ),
                    // 아이디 입력 필드
                    TextField(
                      controller: idController,
                      decoration: const InputDecoration(
                        labelText: '아이디 입력',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    // 비밀번호 입력 필드
                    TextField(
                      obscureText: true,
                      controller: pwController,
                      decoration: const InputDecoration(
                        labelText: '비밀번호 입력',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('취소'),
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                  },
                ),
                TextButton(
                  // 실제 로그인 로직을 여기에 구현
                  onPressed: () async {
                     setState(() {
                        errorText = ''; // 로그인 시도 시 에러 메시지 초기화
                      });
                      
            
                    final String loginId = idController.text.trim();
                    final String password = pwController.text.trim();
            
                    // 1. 입력값 검증 (아이디 또는 비밀번호가 비어있는 경우)
                    if (loginId.isEmpty || password.isEmpty || loginId == '' || password == '') {
                      setState(() {
                        errorText = '아이디와 비밀번호를 모두 입력해주세요.'; 
                      });
                      return; // 로그인 시도 중단
                    }
            
                    // 2. API 요청
                    try {
                      // AuthApiService 객체 생성
                      final authApi = AuthApiService(); 
                      
                      // 요청 함수 호출
                      final response = await authApi.loginWithIdAndPw(
                        loginId: loginId,
                        password: password,
                      );
                      if(!context.mounted) return;
                      if (response.statusCode == 200) {
                        final tokenResponse = TokenResponse.fromJson(response.data);
                        if(tokenResponse.accessToken == 'NOT_USER'){
                          setState(() {
                            errorText = '비밀번호가 일치하지 않습니다.';
                          });
                          return;
                        }
                        UserPrefs.settingLoginResponse(tokenResponse);
                        CmuInvalidateCollect().cmuInvalidateCache(ref); // 캐시 날리기
                        // 성공 시: 팝업 닫고 > 컨트롤러 해제 > 페이지 이동
                        Navigator.of(dialogContext).pop();
                        // 컨트롤러 수동 해제
                        // idController.dispose();
                        // pwController.dispose();
                        await Future.microtask(() {
                          if(!context.mounted) return;
                          context.go('/usr/info'); 
                        });
                      } else {
                        // API 실패 시
                          setState(() {
                             errorText = '로그인 실패: ${response.statusMessage.toString()}'; // 로컬 에러 메시지 업데이트
                          });
                      }
                    } catch (e) {
                      debugPrint('로그인 실패: $e');
                      setState(() {
                        if(e.toString().contains('DioException')) {
                          errorText = '등록되지 않은 사용자입니다.'; // 로컬 에러 메시지 업데이트
                        }
                      });
                    }
                  },
                  child: const Text('로그인'),
                ),
              ],
            );
          }
        );
      },
    );
  }

  // 탭 다운 시 (손가락을 누르는 순간) 처리
  void _handleTapDown(TapDownDetails details) {
    // 1. 색상 변경 (흰색 -> 파란색)
    setState(() {
      _isPressed = true;
    });
    // 2. 4초 타이머 시작
    _timer = Timer(const Duration(milliseconds: 3800), () {
      // 4초 후 실행될 때 색상 상태를 다시 흰색으로 변경
      setState(() {
        _isPressed = false;
      });
      // 팝업 표시
      _showGuestLoginDialog(context);
    });
  }

   // 탭 업/취소 시 (손가락을 떼거나 탭이 취소되는 순간) 처리
  void _handleTapUpOrCancel() {
    // 1. 타이머가 존재하면 취소 (3초가 되기 전에 뗀 경우)
    if (_timer != null) {
      _timer!.cancel();
      _timer = null;
    }
    // 2. 색상 변경 (파란색 -> 흰색)
    setState(() {
      _isPressed = false;
    });
  }


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
                        padding: EdgeInsets.symmetric(horizontal: 20 * wtio,),
                        child: GestureDetector(
                          onTapDown: _handleTapDown,
                          onTapUp: (details) => _handleTapUpOrCancel(),
                          onTapCancel:  _handleTapUpOrCancel,
                          child: TextButton(
                            style: ButtonStyle(
                              tapTargetSize: MaterialTapTargetSize.padded,
                              padding: WidgetStateProperty.all<EdgeInsetsGeometry>(
                                const EdgeInsets.all(0),
                              ),
                            ),
                            onPressed: (){},
                            child: Text(
                              '다음으로 로그인',
                               textAlign: TextAlign.center,
                               style: TextStyle(
                                color: _isPressed ? Colors.blue : Colors.white,
                                fontSize: 14 * htio,
                                fontFamily: 'Pretendard',
                                height: 0.09 * htio,
                              ),
                            ),
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
