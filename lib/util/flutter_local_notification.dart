import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart' show Int64List, debugPrint;
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_app_badger/flutter_app_badger.dart' show FlutterAppBadger;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:go_router/go_router.dart';
import 'package:my_app/api/configure_dio.dart' show DIOConfig;
import 'package:my_app/database/app_database.dart';
import 'package:my_app/main.dart' show router;
import 'package:my_app/providers/db_providers.dart'
    show checkTodayRecordComplete;
import 'package:my_app/service/user_api_service.dart' show UserApiService;
import 'package:my_app/util/navigator_key.dart';
import 'package:my_app/view/tab/cmu/feed/dtl/feed_detail.dart';
import 'package:my_app/view/tab/simple_cache.dart' show osType;
import 'package:shared_preferences/shared_preferences.dart'
    show SharedPreferences;

class FlutterLocalNotification{
  FlutterLocalNotification._();

  static FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  // 알림 클릭 시 전달된 payload를 임시 저장
  static String? pendingPayload;

  // 백그라운드/static 컨텍스트에서 안전하게 API 서비스를 생성합니다.
  static Future<UserApiService> _getAuthApiService() async {
    // 1. 저장된 토큰 가져오기
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('accessToken');

    // 2. 인증 헤더가 포함된 Dio 생성 (main.dart에 있던 DIOConfig 활용)
    final dio = DIOConfig().createDioWithAuth(accessToken);

    // 3. Service 반환
    return UserApiService(dio);
  }

  // ==========================================
  // [UPDATE] API 호출 (UserApiService 사용)
  // ==========================================
  static Future<void> switchPushNotification(String pushKey) async {
    try {
      final apiService = await _getAuthApiService();
      await apiService.switchPushNotification(pushKey);
      debugPrint('[API] switchPushNotification success: $pushKey');
    } catch (e) {
      debugPrint('[API Error] switchPushNotification: $e');
    }
  }

  static Future<void> ignorePushNotification(String pushKey) async {
    try {
      final apiService = await _getAuthApiService();
      await apiService.ignorePushNotification(pushKey);
      debugPrint('[API] ignorePushNotification success: $pushKey');
    } catch (e) {
      debugPrint('[API Error] ignorePushNotification: $e');
    }
  }

  static init() async {
    debugPrint("=== FlutterLocalNotification.init() 호출됨 ===");
    // android 설정
    AndroidInitializationSettings initializationSettingsAndroid = const AndroidInitializationSettings('@mipmap/ic_launcher');
    // ios 설정
    DarwinInitializationSettings initializationSettingsIOS =
      const DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true // iOS는 진동만 따로 하는게 없어서 soundPermission을 true로
      );

    //알림 플러그인을 초기화
    InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );
    // 알림을 탭했을 때 실행될 콜백 함수 설정
    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: onDidReceiveNotificationResponse,
    );

    // 앱이 완전히 종료된 상태에서 알림 클릭 시: 실행될 때 전달된 메세지를 가져오는 메소드
    RemoteMessage? message = await FirebaseMessaging.instance.getInitialMessage();
      if (message != null) {  
        // 종료 상태에서는 바로 화면 이동 불가 → payload 저장
        pendingPayload = json.encode(message.data);
        if(Platform.isIOS){ // ios는 백그라운드/종료 상태에서 dart코드 실행이 불가해서 클릭한 경우만 넣어주자.
          final db = AppDatabase();
          await FlutterLocalNotification.insertNotificationToDB(message, db);
        }
      }

      /// 앱이 초기화 되고 위젯 트리가 mount된 이후
      /// _pendingPayload가 있으면 화면 이동 처리
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (pendingPayload != null) {
          handlePayload(pendingPayload!);
          pendingPayload = null;
        }
      });
  }

  /// 포그라운드 상태에서 알림 클릭 시
  static void onDidReceiveNotificationResponse(
      NotificationResponse notificationResponse) async {
    final String? payload = notificationResponse.payload;
    if (payload != null) {
      handlePayload(payload);
    }
  }

  /// 실제 payload 처리 (FeedDetail로 이동)
  static void handlePayload(String payload) {
    try {
      final Map<String, dynamic> data = json.decode(payload);

      // push_key가 있다면 전환율 측정 API 호출 (사용자가 클릭함)
      if (data.containsKey('push_key') && data['push_key'] != null) {
        switchPushNotification(data['push_key']);
      }
      
      // db에서 알림 읽음처리
      final db = AppDatabase();
      markNotificationRead(int.parse(data['id']), db);
      // 화면 이동
      final String? feedId = data['feedId']?.toString();
      if (feedId != null && data['type'] != 'REPORT') {
        debugPrint("currentContext: $navigatorKey.currentContext");
        WidgetsBinding.instance.addPostFrameCallback((_) {
           router.push('/cmu/feed/${int.parse(feedId)}?isFromNotifi=true');
        });
      } else if(data['type'] == 'BADGE') {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          router.go('/usr/info?isFromNotifi=true');
        });
      } else if(data['type'] == 'REPORT') {
         WidgetsBinding.instance.addPostFrameCallback((_) {
          router.push('/usr/info/management/notifications');
        });
      }
    } catch (e) {
      debugPrint("Error decoding notification payload: $e");
    }
  }

  /// 알림 권한 요청
  static requestNotificationPermission() {
    if(osType == 'ios') {
      flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: true, sound: true);
    } else {
      flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
    }
  }

  // 푸시알림 내용
  static Future<void> showNotification(RemoteMessage message, AppDatabase db) async {
    final data = message.data;
    final pushKey = data['push_key'];

    // [Logic] Trigger 푸시인 경우 (push_key 존재)
    if (pushKey != null) {
      // 1. 로컬 DB 확인 (db_providers.dart에 추가한 함수 사용)
      bool isComplete = await checkTodayRecordComplete(db);

      if (isComplete) {
        // 2-A. 기록이 이미 있으면 -> 알림 무시 API 호출 후 리턴 (알림 표시 X)
        debugPrint('오늘 기록 완료로 알림 무시: $pushKey');
        await ignorePushNotification(pushKey);

        // *중요* DB에 알림 내역은 저장했더라도(insertNotificationToDB는 main에서 호출됨),
        // 사용자에게 팝업은 띄우지 않고 함수 종료.
        // 만약 '알림 센터'에도 남기지 않으려면 insertNotificationToDB 호출 시점도 조정해야 합니다.
        // 현재 구조상 insert는 main.dart에서 먼저 하므로, 여기서는 '팝업'만 막습니다.
        return;
      }
      // 2-B. 기록이 없으면 -> 아래 로직 진행 (알림 표시)
    }

    // db insert
    await insertNotificationToDB(message, db);

    // 채널 설정
    AndroidNotificationDetails androidNotificationDetails = 
      AndroidNotificationDetails('high_importance_channel', 'high_importance_notification',
        channelDescription: 'channel description',
        importance: Importance.max,
        priority: Priority.max,
        showWhen: false,
        playSound: true,                // 소리까지 같이 낼 거면
        enableVibration: true,  // 진동사용
        vibrationPattern: Int64List.fromList([0, 100]), // 바로시작, 0.1초간 지속
      );

    FlutterAppBadger.updateBadgeCount(1);
    NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: const DarwinNotificationDetails(
        badgeNumber: 0, // 알림 페로에는 뱃지갯수를 담지 않는다.
        presentSound: true, // 사운드 → 진동 동반
      )
    );

    // 알림 띄우기
    await flutterLocalNotificationsPlugin.show(
      message.hashCode,
      message.data['head'] ?? '알림', 
      message.data['body'] ?? '새로운 메시지가 도착했습니다.', 
      notificationDetails,
      payload: json.encode(message.data),
    );
  }

  // 알림 insert (id 반환)
  static Future<void> insertNotificationToDB(RemoteMessage message, AppDatabase db) async {
    await db.into(db.notifications).insert(
      NotificationsCompanion.insert(
        id : Value(int.parse(message.data['id'])),
        prefix: Value(message.data['prefix']),
        title: message.data['title'] ?? '알림',
        body: message.data['body'] ?? '새로운 메시지가 도착했습니다.',
        feedId: Value(int.parse(message.data['feedId'] ?? '0')),
        type: message.data['type'] ?? 'GENERAL',
        receivedAt: DateTime.now().toIso8601String(),
        isRead: Value(message.data['isRead'] ?? 'false'),
        userId: int.parse(message.data['userId']),
      ),
    );
  }

  // 알림 읽음처리
  static Future<void> markNotificationRead(int id, AppDatabase db) async {
    await (db.update(db.notifications)..where((tbl) => tbl.id.equals(id))).write(
      const NotificationsCompanion(
        isRead: Value('true'),
      ),
    );
  }
 
}

