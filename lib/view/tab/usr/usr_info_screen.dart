import 'dart:io';

import 'package:firebase_installations/firebase_installations.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_app/model/usr/auth/push_token_request.dart';
import 'package:my_app/providers/user_cud_providers.dart';
import 'package:my_app/view/tab/usr/management/usr_info_management.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UsrInfoScreen extends ConsumerStatefulWidget {
  const UsrInfoScreen({super.key});

  @override
  ConsumerState<UsrInfoScreen> createState() => _UsrInfoScreenState();
}

class _UsrInfoScreenState extends ConsumerState<UsrInfoScreen> {

  @override
  void initState() {
    super.initState();
    final prefsFuture = SharedPreferences.getInstance();
    _getAndSendPushToken(prefsFuture); // 위젯이 생성될 때 토큰 발급 및 전송 로직 호출
  }

  // FCM 토큰과 installation ID를 발급받아 서버에 전송하는 비동기 함수
  Future<void> _getAndSendPushToken(Future<SharedPreferences> prefsFuture) async {
    final prefs = await prefsFuture;
    bool? fcmTokenUploaded = prefs.getBool('fcmTokenUploaded');
    if(fcmTokenUploaded==null || !fcmTokenUploaded) {
      // 1. FCM 토큰 가져오기
      String? fcmToken = await FirebaseMessaging.instance.getToken();

      if (fcmToken == null) {
        // 토큰 발급 실패 시 로그 기록 후 종료
        debugPrint('FCM Token is null. Cannot proceed.');
        return;
      }

      // 2. installation ID 가져오기 (FCM 토큰과 동일한 라이프사이클)
      String? installationId = await FirebaseInstallations.id;

      // 3. 현재 디바이스의 OS 타입 가져오기
      String osType = Platform.isIOS ? 'ios' : 'android';

      debugPrint('fcm:$fcmToken');
      debugPrint('installation:$installationId');
      debugPrint('os:$osType');

      // 4. 서버로 토큰 정보 전송 (가정된 API 호출)
      try {
        final pushTokenRequest = PushTokenRequest(fcmToken: fcmToken, osType: osType, installationId: installationId);

        final service = await ref.read(userCudServiceProvider.future);
        final response = await service.registerPushToken(pushTokenRequest);

        if(response == 'success') {
          prefs.setBool("fcmTokenUploaded", true);
        }
      } catch (e) {
        debugPrint('Failed tosend push token to server: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const SizedBox(height: 84,),
          GestureDetector(
            onTap: () {
              Navigator.push(context,
               MaterialPageRoute(
                builder: (context) => const UsrInfoManagement()
                )
              );
            },
            child: Text(
              '내정보관리',
              style: TextStyle(
                fontSize: 16,
                color: Colors.blue.shade400
              ),
            ),
          ),
          const SizedBox(height: 20), // 버튼 간 간격 추가
          // FCM 토큰 삭제 테스트 버튼 추가
          ElevatedButton(
            onPressed: () async {
              try {
                await FirebaseMessaging.instance.deleteToken();
                // final prefs = await SharedPreferences.getInstance();
                // await prefs.setBool("fcmTokenUploaded", false); // 플래그 초기화
                debugPrint('FCM 토큰이 삭제되었습니다. onTokenRefresh 리스너가 작동하여 새로운 토큰을 발급하고 서버에 전송할 것입니다.');
                // 삭제 후 재등록 로직을 바로 호출할 수도 있습니다 (선택 사항)
                // _getAndSendPushToken(SharedPreferences.getInstance());
              } catch (e) {
                debugPrint('FCM 토큰 삭제 중 오류 발생: $e');
              }
            },
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white, backgroundColor: Colors.red, // 텍스트 색상
            ),
            child: const Text('FCM 토큰 삭제 및 갱신 테스트'),
          ),
        ],
      ),
    );
  }
}
