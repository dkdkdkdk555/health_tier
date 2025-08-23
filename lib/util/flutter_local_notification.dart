import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class FlutterLocalNotification {
  FlutterLocalNotification._();

  static FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  static init() async {
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
    // 세팅
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
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
      notificationDetails
    );
  }
}
