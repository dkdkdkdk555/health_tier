import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart' show BaseOptions, Dio;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_installations/firebase_installations.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_quill/flutter_quill.dart' show FlutterQuillLocalizations;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:my_app/api/configure_dio.dart';
import 'package:my_app/database/app_database.dart';
import 'package:my_app/model/usr/auth/push_token_request.dart' show PushTokenRequest;
import 'package:my_app/model/usr/user/usr_simple_dto.dart';
import 'package:my_app/providers/current_page_provider.dart' show currentPageProvider;
import 'package:my_app/providers/usr_auth_providers.dart';
import 'package:my_app/service/user_api_service.dart';
import 'package:my_app/util/error_message_utils.dart';
import 'package:my_app/util/flutter_local_notification.dart';
import 'package:my_app/util/navigator_key.dart';
import 'package:my_app/util/user_prefs.dart';
import 'package:my_app/view/common/webview_page.dart';
import 'package:my_app/view/tab/cmu/cmu_main.dart';
import 'package:my_app/view/tab/cmu/feed/dtl/feed_detail.dart';
import 'package:my_app/view/tab/cmu/feed/srch/cmu_total_srch.dart';
import 'package:my_app/view/tab/cmu/feed/user_profile/cmu_usr_profile.dart';
import 'package:my_app/view/tab/cmu/feed/write/write_feed.dart';
import 'package:my_app/view/tab/doc/doc_main.dart';
import 'package:my_app/view/tab/stc/stc_main.dart';
import 'package:my_app/view/tab/usr/get_started_screen.dart';
import 'package:my_app/view/tab/usr/management/usr_info_management.dart';
import 'package:my_app/view/tab/usr/management/usr_signout_notice_page.dart';
import 'package:my_app/view/tab/usr/notification/notification_manage_page.dart';
import 'package:my_app/view/tab/usr/sign_progress/nicname_input_page.dart';
import 'package:my_app/view/tab/usr/usr_info_screen.dart';
import 'package:my_app/view/tab/usr/usr_main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'view/navigation_bar.dart';
import 'package:intl/date_symbol_data_local.dart'; 
import '../firebase_options.dart'; // flutterfire configure 하면 생겨나는 설정파일

part 'router.dart';

// top-level 백그라운드 핸들러
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  final db = AppDatabase();
  await FlutterLocalNotification.insertNotificationToDB(message, db);
}

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  // 세로 모드만 허용
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
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
  await db.insertTestDataIfNeeded(); // ✅ 테스트 데이터 삽입

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

  @override
  void initState() {
    // 로컬알림 초기화
    _initNotifications();
    // 알림 권한요청
    Future.delayed(const Duration(seconds: 3), FlutterLocalNotification.requestNotificationPermission());
    super.initState();
  }

  void _initNotifications() async {
    await FlutterLocalNotification.init();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      localizationsDelegates: const [
        FlutterQuillLocalizations.delegate,
      ],
    );
  }
}
