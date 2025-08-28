import 'dart:convert';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:my_app/util/navigator_key.dart';
import 'package:my_app/view/tab/cmu/feed/dtl/feed_detail.dart';

class FlutterLocalNotification with WidgetsBindingObserver{
  FlutterLocalNotification._();

  static FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  // 알림 클릭 시 전달된 payload를 임시 저장
  static String? _pendingPayload;

  static init() async {
    debugPrint("=== FlutterLocalNotification.init() 호출됨 ===");
     // 앱 라이프사이클 감시자 등록
    WidgetsBinding.instance.addObserver(_NotificationLifecycleObserver());
    
    // android 설정
    AndroidInitializationSettings initializationSettingsAndroid = const AndroidInitializationSettings('@mipmap/ic_launcher');
    // ios 설정
    DarwinInitializationSettings initializationSettingsIOS =
      const DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false);

    //알림 플러그인을 초기화
    InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );
    // 알림을 탭했을 때 실행될 콜백 함수 설정
    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: onDidReceiveNotificationResponse,
      onDidReceiveBackgroundNotificationResponse: onDidReceiveBackgroundNotificationResponse,
    );
  }

  /// 포그라운드 상태에서 알림 클릭 시
  static void onDidReceiveNotificationResponse(
      NotificationResponse notificationResponse) async {
    final String? payload = notificationResponse.payload;
    if (payload != null) {
      handlePayload(payload);
    }
  }
  /// 백그라운드 상태에서 알림 클릭 시 → payload만 저장
  static void onDidReceiveBackgroundNotificationResponse(
      NotificationResponse notificationResponse) async {
    final String? payload = notificationResponse.payload;
    if (payload != null) {
      // final prefs = await SharedPreferences.getInstance();
      // prefs.setString('pushPayload', payload);
      // debugPrint('Background notification payload saved: $payload'); --> 안되는듯
      _pendingPayload = payload;
    }
  }

  /// 앱 resume 시, 저장된 payload 있으면 페이지 이동 처리
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    debugPrint("??didChangeAppLifecycleState??");
    if (state == AppLifecycleState.resumed && _pendingPayload != null) {
      debugPrint("App resumed. Handling pending notification payload.");
      handlePayload(_pendingPayload!);
      _pendingPayload = null; // 사용 후 초기화
    }
  }

  /// 실제 payload 처리 (FeedDetail로 이동)
  static void handlePayload(String payload) {
    try {
      final Map<String, dynamic> data = json.decode(payload);
      final String? feedId = data['feedId']?.toString();

      if (feedId != null &&
          navigatorKey.currentState != null &&
          navigatorKey.currentState!.mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          navigatorKey.currentState?.push(
            MaterialPageRoute(
              builder: (context) =>
                  FeedDetail(feedId: int.parse(feedId), isFromWriteFeed: false),
            ),
          );
        });
      }
    } catch (e) {
      debugPrint("Error decoding notification payload: $e");
    }
  }

  static requestNotificationPermission() {
    String osType = Platform.isIOS ? 'ios' : 'android';
    if(osType == 'ios') {
      flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: true, sound: true);
    } else {
      flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
    }
  }

  // 푸시알림 내용
  static Future<void> showNotification(RemoteMessage message) async {
    const AndroidNotificationDetails androidNotificationDetails = 
      AndroidNotificationDetails('channelId', 'channelName',
        channelDescription: 'channel description',
        importance: Importance.max,
        priority: Priority.max,
        showWhen: false,
      );
    
    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: DarwinNotificationDetails(badgeNumber: 1)
    );

    await flutterLocalNotificationsPlugin.show(
      message.data.hashCode, 
      message.data['title'] ?? '알림', 
      message.data['body'] ?? '새로운 메시지가 도착했습니다.', 
      notificationDetails,
      payload: json.encode(message.data),
    );
  }
}


/// 앱 라이프사이클을 감시하고, 백그라운드에서 클릭된 알림 처리
class _NotificationLifecycleObserver with WidgetsBindingObserver {
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed &&
        FlutterLocalNotification._pendingPayload != null) {
      debugPrint("App resumed. Handling pending notification payload.");
      FlutterLocalNotification.handlePayload(
          FlutterLocalNotification._pendingPayload!);
      FlutterLocalNotification._pendingPayload = null;
    }
  }
}
