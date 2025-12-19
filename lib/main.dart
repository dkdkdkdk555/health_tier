import 'dart:async' show StreamSubscription;
import 'dart:convert';
import 'dart:io';
import 'dart:ui' show ImageFilter;

import 'package:app_links/app_links.dart';
import 'package:app_tracking_transparency/app_tracking_transparency.dart' show AppTrackingTransparency, TrackingStatus;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_installations/firebase_installations.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_quill/flutter_quill.dart' show FlutterQuillLocalizations;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart' show MobileAds;
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:my_app/api/configure_dio.dart';
import 'package:my_app/database/app_database.dart';
import 'package:my_app/model/usr/auth/push_token_request.dart' show PushTokenRequest;
import 'package:my_app/notifier/tutorial_notifier.dart' show mainTutorialStorageProvider;
import 'package:my_app/providers/current_page_provider.dart' show currentPageProvider;
import 'package:my_app/providers/user_cud_providers.dart' show usrProfileImgProvider;
import 'package:my_app/providers/usr_auth_providers.dart';
import 'package:my_app/service/user_api_service.dart';
import 'package:my_app/util/error_message_utils.dart';
import 'package:my_app/util/firebase_remote_config_service.dart';
import 'package:my_app/util/flutter_local_notification.dart';
import 'package:my_app/util/screen_ratio.dart' show ScreenRatio;
import 'package:my_app/util/up_arrow.dart' show UpArrowIndicator;
import 'package:my_app/util/user_prefs.dart';
import 'package:my_app/view/common/webview_page.dart';
import 'package:my_app/view/intro_screen.dart';
import 'package:my_app/view/tab/cmu/cmu_main.dart';
import 'package:my_app/view/tab/cmu/feed/dtl/feed_detail.dart';
import 'package:my_app/view/tab/cmu/feed/srch/cmu_total_srch.dart';
import 'package:my_app/view/tab/cmu/feed/user_profile/cmu_usr_profile.dart';
import 'package:my_app/view/tab/cmu/feed/write/write_feed.dart';
import 'package:my_app/view/tab/doc/diet/doc_diet_main.dart' show createTutorialDiet, dietTutorialTriggerProvider, tutorialCoachMarkDiet;
import 'package:my_app/view/tab/doc/doc_main.dart';
import 'package:my_app/view/tab/simple_cache.dart' show osType;
import 'package:my_app/view/tab/stc/stc_main.dart';
import 'package:my_app/view/tab/usr/admin/admin_manage_list.dart';
import 'package:my_app/view/tab/usr/admin/admin_manage_page.dart';
import 'package:my_app/view/tab/usr/block/block_manage_page.dart';
import 'package:my_app/view/tab/usr/get_started_screen.dart';
import 'package:my_app/view/tab/usr/management/usr_info_management.dart';
import 'package:my_app/view/tab/usr/management/usr_signout_notice_page.dart';
import 'package:my_app/view/tab/usr/notification/notification_manage_page.dart';
import 'package:my_app/view/tab/usr/sign_progress/nicname_input_page.dart';
import 'package:my_app/view/tab/usr/usr_info_screen.dart';
import 'package:my_app/view/tab/usr/usr_main.dart';
import 'package:my_app/view/tutorial/common_functions.dart' show buildTarget, titleDescContent;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import '../firebase_options.dart';
import 'view/navigation_bar.dart';
import 'dart:math' as math;
import 'package:flutter_quill/flutter_quill.dart'; 
import 'package:flutter_localizations/flutter_localizations.dart';

part 'router.dart';
part 'view/tutorial/main_tutorial.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  final db = AppDatabase();
  await FlutterLocalNotification.insertNotificationToDB(message, db);
}

// 무거운 초기화 작업들을 함수로 분리
Future<void> initializeDependencies(WidgetRef ref) async {
  // 유저정보 SharedPreferences -> 캐시 변수에 로드
  await UserPrefs.cleanExpiredPostViewCache();
  await UserPrefs.loadMyUserId();
  await UserPrefs.loadUserImgUrl();
  // 프로필 이미지 Provider 상태변경
  final initialImg = UserPrefs.myUserImgUrl ?? '';
  ref.read(usrProfileImgProvider.notifier).state = initialImg;
  // db 초기화
  final db = AppDatabase();
  // 테스트 데이터 삽입 시만 사용
  // await db.insertTestDataIfNeeded(); 

  // Firebase 초기화
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Firebase Remote Config 초기화 및 설정
  await RemoteConfigService.instance.initialize();
  
  // 현재 디바이스의 OS 타입 가져오기
  final osTypeInit = Platform.isIOS ? 'ios' : 'android';
  osType = osTypeInit;
  
  // FCM 토큰 갱신 리스너 등록
  FirebaseMessaging.instance.onTokenRefresh.listen((fcmToken) async {
    // SharedPreferences에서 accessToken 가져오기
    final prefs = await SharedPreferences.getInstance();
    final jwtToken = prefs.getString('accessToken');
    // installation ID 가져오기
    String? installationId = await FirebaseInstallations.id;
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
  FirebaseMessaging.onMessageOpenedApp.listen((message) async {
    if(Platform.isIOS){
      final db = AppDatabase();
      await FlutterLocalNotification.insertNotificationToDB(message, db);
    }
    FlutterLocalNotification.pendingPayload = json.encode(message.data);
    FlutterLocalNotification.handlePayload(FlutterLocalNotification.pendingPayload!);
    FlutterLocalNotification.pendingPayload = null;
  });

  // 카카오sdk 초기화
  KakaoSdk.init(
    nativeAppKey: 'KAKAO_NATIVE_APP_KEY_REDACTED',
    javaScriptAppKey: 'KAKAO_JAVASCRIPT_APP_KEY_REDACTED',
  );
  // 로컬알림 초기화
  await FlutterLocalNotification.init();
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // 세로 모드만 허용
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  await initializeDateFormatting('ko');
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key,});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> with SingleTickerProviderStateMixin {
  StreamSubscription<Uri>? _linkSubscription; // 딥링크 객체
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    // 앱 시작 후 100ms 지연 후 초기화 작업 시작
    Future.delayed(const Duration(milliseconds: 100), () async {
      await initializeDependencies(ref);
    });

    // Fade out 애니메이션 세팅
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    // 2초 후 인트로 페이드아웃
    Future.delayed(const Duration(milliseconds: 2400), () {
      if (mounted) _fadeController.forward();
    });

    _fadeController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {});
      }
    });

    // 튜토리얼 초기화
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final htio = ScreenRatio(context).heightRatio;
      final wtio = ScreenRatio(context).widthRatio;

      createTutorial(ref: ref,wtio: wtio,htio: htio,);
      createTutorialDiet(ref: ref, wtio: wtio,htio: htio);
    });
  }


  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _initDeepLinks();
      await _requestAuthrizationTracking();
      await FlutterLocalNotification.requestNotificationPermission();
      // 애드몹 광고 sdk 초기화
      await MobileAds.instance.initialize();
    });
  }

  Future<void> _initDeepLinks() async {
    _linkSubscription = AppLinks().uriLinkStream.listen((uri) {
      if(Platform.isIOS) { // 안드는 goRouter에서 리다이렉트 이용
        openAppLink(uri);
      }
    });
  }

  Future<void> _requestAuthrizationTracking() async {
    // 앱 추적 권한 상태 확인 및 요청
    final status = await AppTrackingTransparency.trackingAuthorizationStatus;
    
    if (status == TrackingStatus.notDetermined) {
      await AppTrackingTransparency.requestTrackingAuthorization();
    }
  }

  void openAppLink(Uri uri) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final host = uri.host; // 'cmu'
      String path = uri.path; // '/feed/165' 또는 '///feed/165'
      // 맨 앞의 모든 슬래시 제거
      path = path.replaceAll(RegExp(r'^/+'), '');
      // 전체 경로 조립 → '/cmu/feed/165'
      final fullPath = path.startsWith("/") ? '$host/$path' : '/$host/$path';
      debugPrint(fullPath);
      rootNavigatorKey.currentContext?.push(fullPath);
    });
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      localizationsDelegates: const [
        FlutterQuillLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('ko'), // 한국어도 함께 지원 가능
      ],
      builder: (context, child) {
        return Stack(
          children: [
            child!,
            IgnorePointer(
              ignoring: _fadeController.isCompleted,
              child: FadeTransition(
                opacity: Tween(begin: 1.0, end: 0.0).animate(_fadeAnimation),
                child: const IntroScreen(),
              ),
            ),
          ],
        );
      },
    );
  }
}