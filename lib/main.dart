import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart' show BaseOptions, Dio;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_installations/firebase_installations.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_quill/flutter_quill.dart' show FlutterQuillLocalizations;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:my_app/api/configure_dio.dart';
import 'package:my_app/database/app_database.dart';
import 'package:my_app/model/usr/auth/push_token_request.dart' show PushTokenRequest;
import 'package:my_app/providers/current_page_provider.dart' show currentPageProvider;
import 'package:my_app/providers/usr_auth_providers.dart';
import 'package:my_app/service/user_api_service.dart';
import 'package:my_app/util/flutter_local_notification.dart';
import 'package:my_app/util/navigator_key.dart';
import 'package:my_app/util/user_prefs.dart';
import 'package:my_app/view/tab/cmu/cmu_main.dart';
import 'package:my_app/view/tab/cmu/feed/write/write_feed.dart';
import 'package:my_app/view/tab/doc/doc_main.dart';
import 'package:my_app/view/tab/stc/stc_main.dart';
import 'package:my_app/view/tab/usr/usr_main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'view/navigation_bar.dart';
import 'package:intl/date_symbol_data_local.dart'; 
import '../firebase_options.dart'; // flutterfire configure 하면 생겨나는 설정파일

// top-level 백그라운드 핸들러
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  final db = AppDatabase();
  await FlutterLocalNotification.insertNotificationToDB(message, db);
}

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('ko');
  await UserPrefs.cleanExpiredPostViewCache();
  await UserPrefs.loadMyUserId(); // 앱 시작 시 사용자 ID 로드
  final db = AppDatabase();
  await Firebase.initializeApp( // 파이어베이스 초기화
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // FCM 토큰 갱신 리스너 등록
  FirebaseMessaging.instance.onTokenRefresh.listen((fcmToken) async {
    debugPrint('새토큰 : $fcmToken');

    // SharedPreferences에서 accessToken 가져오기
    final prefs = await SharedPreferences.getInstance();
    final jwtToken = prefs.getString('accessToken');

    // installation ID 가져오기
    String? installationId = await FirebaseInstallations.id;
    // 현재 디바이스의 OS 타입 가져오기
    String osType = Platform.isIOS ? 'ios' : 'android';

    // 인증 헤더를 포함한 Dio 인스턴스 생성
    final dio = DIOConfig().createDioWithAuth(jwtToken);
    final apiService = UserApiService(dio);

    // 서버저장 요청
    try {
      final pushTokenRequest = PushTokenRequest(
        fcmToken: fcmToken,
        osType: osType,
        installationId: installationId,
      );
      final response = await apiService.registerPushToken(pushTokenRequest);

      if (response == 'success') {
        prefs.setBool("fcmTokenUploaded", true);
        debugPrint('FCM 토큰이 서버에 성공적으로 등록되었습니다.');
      }
    } catch (e) {
      debugPrint('FCM 토큰 전송 실패: $e');
    }
  });

  // 백그라운드 알림 : 수신 시 db 저장
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  // 포그라운드 알림: 앱 내 커스텀 알림 
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    FlutterLocalNotification.showNotification(message, db);
  });

  // 백그라운드 클릭 시: 앱 켜지고 handlePayload 호출 (알림 보여주는건 os에서 알아서 해줌 -> 그 알림 클릭시 여기선 페이로드 저장만해둠)
  FirebaseMessaging.onMessageOpenedApp.listen((message) {
    FlutterLocalNotification.pendingPayload = json.encode(message.data);
    FlutterLocalNotification.handlePayload(FlutterLocalNotification.pendingPayload!);
    FlutterLocalNotification.pendingPayload = null;
  });

  // 테스트 데이터 삽입 시만 사용
  // await db.insertTestDataIfNeeded(); // ✅ 테스트 데이터 삽입

  // 카카오sdk 초기화
   KakaoSdk.init(
        nativeAppKey: 'KAKAO_NATIVE_APP_KEY_REDACTED',
        javaScriptAppKey: 'KAKAO_JAVASCRIPT_APP_KEY_REDACTED',
    );

  runApp(const ProviderScope( // 상태관리 패키지 - Riverpod 설정
    child:MyApp())
  );
}

class MyApp extends ConsumerStatefulWidget {
  final int mvIndex;
  const MyApp({
    super.key,
    this.mvIndex = 0
  });

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

 
class _MyAppState extends ConsumerState<MyApp> with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  double islandLeftMargin = 75;

  late AnimationController _fabController;
  late Animation<Offset> _fabSlide;
  late Animation<double> _fabOpacity;
  
  final List<Widget> _pages = [
      const DocMain(), 
      const StcMain(),
      const CmuMain(),
      const UsrMain()
  ];

  @override
  void initState() {
    // 로컬알림 초기화
    _initNotifications();
    // 알림 권한요청
    Future.delayed(const Duration(seconds: 3), FlutterLocalNotification.requestNotificationPermission());
    super.initState();

    _fabController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );

    _fabSlide = Tween<Offset>(
      begin: const Offset(-1.0, 0), // 가운데서 시작
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _fabController,
      curve: Curves.easeOut,
    ));

    _fabOpacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _fabController, 
        curve: Curves.easeIn
    ));

    if(widget.mvIndex!=0) _onTap(widget.mvIndex);

  }

  void _initNotifications() async {
    await FlutterLocalNotification.init();
  }

  @override
  void dispose() {
    _fabController.dispose();
    super.dispose();
  }
    
  void _onTap(int index) {
    setState(() {
      _selectedIndex = index;
      ref.read(currentPageProvider.notifier).state = index;
      if(index == 2) {
        islandLeftMargin = 14;
        _fabController.forward(); // FAB 슬라이드 인
      } else {
        islandLeftMargin = 75;
        _fabController.reverse(); // FAB 슬라이드 아웃
      }
    });
  }

  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        extendBody: true,
        body: _pages[_selectedIndex],
        bottomNavigationBar: Stack(
          alignment: Alignment.center,
          children: [
            // cmu 작성 버튼
          if (_selectedIndex == 2)
            Positioned(
              height: 52,
              right: 38,
              bottom: 42,
              child: SlideTransition(
                position: _fabSlide,
                child: FadeTransition(
                  opacity: _fabOpacity,
                  child: Builder(
                    builder: (context) => FloatingActionButton(
                      onPressed: () async {
                        try {
                          final response = await ref.read(jwtTokenVerificationProvider.future);
                          if(response.isValid) {
                            if(!context.mounted)return;
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const WriteFeed(),
                              ),
                            );
                          }
                        } catch (e) {
                          debugPrint('$e');
                        }
                      },
                      backgroundColor: const Color(0xFF0D85E7),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: SvgPicture.asset('assets/widgets/create_feed.svg'),
                    ),
                  ),
                ),
              ),
            )
          else
            Positioned(
              height: 52,
              right: 38,
              bottom: 42,
              child: SlideTransition(
                position: _fabSlide,
                child: FadeTransition(
                  opacity: _fabOpacity,
                  child: Builder(
                    builder: (context) => FloatingActionButton(
                      onPressed: () async {
                       try {
                          final response = await ref.read(jwtTokenVerificationProvider.future);
                          if(response.isValid) {
                            if(!context.mounted)return;
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const WriteFeed(),
                              ),
                            );
                          }
                        } catch (e) {
                          debugPrint('$e');
                        }
                      },
                      backgroundColor: const Color(0xFF0D85E7),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: SvgPicture.asset('assets/widgets/create_feed.svg'),
                    ),
                  ),
                ),
              ),
            ),
            AnimatedContainer( 
              duration: const Duration(milliseconds: 350),
              margin: EdgeInsets.only(left: islandLeftMargin, right: 75, bottom: 42),
              height: 52,
              width: 234,
              curve: Curves.easeInOut,
              child: IslandNavigationBar(
                selectedIndex: _selectedIndex,
                onTap: _onTap,
              ),
            ),
          ],
        )
      ),
      localizationsDelegates: const [
       FlutterQuillLocalizations.delegate,
      ],
    );
  }
}
