import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_app_badger/flutter_app_badger.dart' show FlutterAppBadger;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:go_router/go_router.dart';
import 'package:my_app/database/app_database.dart';
import 'package:my_app/util/navigator_key.dart';
import 'package:my_app/view/tab/cmu/feed/dtl/feed_detail.dart';

class FlutterLocalNotification{
  FlutterLocalNotification._();

  static FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  // 알림 클릭 시 전달된 payload를 임시 저장
  static String? pendingPayload;

  static init() async {
    debugPrint("=== FlutterLocalNotification.init() 호출됨 ===");
    // android 설정
    AndroidInitializationSettings initializationSettingsAndroid = const AndroidInitializationSettings('@mipmap/ic_launcher');
    // ios 설정
    DarwinInitializationSettings initializationSettingsIOS =
      const DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
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
    );

    // 앱이 완전히 종료된 상태에서 알림 클릭 시: 실행될 때 전달된 메세지를 가져오는 메소드
    RemoteMessage? message = await FirebaseMessaging.instance.getInitialMessage();
      if (message != null) {  
        // 종료 상태에서는 바로 화면 이동 불가 → payload 저장
        pendingPayload = json.encode(message.data);
        if(Platform.isIOS){ // ioㄴ
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
      // db에서 알림 읽음처리
      final db = AppDatabase();
      markNotificationRead(int.parse(data['id']), db);
      // 화면 이동
      final String? feedId = data['feedId']?.toString();
      if (feedId != null &&
          navigatorKey.currentState != null &&
          navigatorKey.currentState!.mounted) {
        debugPrint("currentContext: $navigatorKey.currentContext");
        final ctx = navigatorKey.currentContext!;
        WidgetsBinding.instance.addPostFrameCallback((_) {
           ctx.push('/cmu/feed/${int.parse(feedId)}');
        });
      }
    } catch (e) {
      debugPrint("Error decoding notification payload: $e");
    }
  }

  /// 알림 권한 요청
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
  static Future<void> showNotification(RemoteMessage message, AppDatabase db) async {
    // db insert
    await insertNotificationToDB(message, db);

    // 채널 설정
    const AndroidNotificationDetails androidNotificationDetails = 
      AndroidNotificationDetails('high_importance_channel', 'high_importance_notification',
        channelDescription: 'channel description',
        importance: Importance.max,
        priority: Priority.max,
        showWhen: false,
      );

    FlutterAppBadger.updateBadgeCount(1);
    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: DarwinNotificationDetails(badgeNumber: 0) // 알림 페로에는 뱃지갯수를 담지 않는다.
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
        feedId: Value(int.parse(message.data['feedId'] ?? 0)),
        type: message.data['type'] ?? 'GENERAL',
        receivedAt: DateTime.now().toIso8601String(),
        isRead: Value(message.data['isRead'] ?? 'false'),
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

