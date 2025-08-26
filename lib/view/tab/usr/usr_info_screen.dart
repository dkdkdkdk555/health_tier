import 'dart:io';

import 'package:firebase_installations/firebase_installations.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:my_app/model/usr/auth/push_token_request.dart';
import 'package:my_app/providers/user_cud_providers.dart';
import 'package:my_app/view/tab/cmu/feed/item/top_blank_area.dart';
import 'package:my_app/view/tab/usr/management/usr_info_management.dart';
import 'package:my_app/view/tab/usr/usr_main/my_badge.dart';
import 'package:my_app/view/tab/usr/usr_main/my_body_info.dart';
import 'package:my_app/view/tab/usr/usr_main/my_wrote_feed.dart';
import 'package:my_app/view/tab/usr/usr_main/profile_card.dart';
import 'package:my_app/view/tab/usr/usr_main/usr_info_tab_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:my_app/extension/screen_ratio_extension.dart';
import 'package:my_app/view/tab/simple_cache.dart' show cachedUsrTabIndex;

class UsrInfoScreen extends ConsumerStatefulWidget {
  const UsrInfoScreen({super.key});

  @override
  ConsumerState<UsrInfoScreen> createState() => _UsrInfoScreenState();
}

class _UsrInfoScreenState extends ConsumerState<UsrInfoScreen> {
  // 어느 하위 탭인지
  late int _selectedIndex;

  final List<Widget> _tabs = [
    const MyBadge(),
    const MyBodyInfo(),
    const MyWroteFeed()
  ];

  @override
  void initState() {
    super.initState();
    _selectedIndex = cachedUsrTabIndex;
    final prefsFuture = SharedPreferences.getInstance();
    _getAndSendPushToken(prefsFuture); // 위젯이 생성될 때 토큰 발급 및 전송 로직 호출
  }

    void _onTap(int index) { // 하위 탭바에서 받을 함수
    setState(() {
      _selectedIndex = index;
      cachedUsrTabIndex = index;
    });
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

    return Container(
      color: Colors.white,
      child: CustomScrollView(
        slivers: [
          // 상단바 위 여백
          const TopBlankArea(),
          // 상단바
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              width: double.infinity,
              height: 82,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                   const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '마이페이지',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                        fontFamily: 'Pretendard',
                        fontWeight: FontWeight.w700,
                        height: 0.07,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {},
                    child: SizedBox(
                      width: 22,
                      height: 22,
                      child: SvgPicture.asset(
                        'assets/icons/alram.svg'
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
          // 프로필 영역
          const SliverToBoxAdapter(
            child: ProfileCard(),
          ),
          // 탭바 영역
          SliverToBoxAdapter(
            child: UsrInfoTabBar(
              selectedIndex: _selectedIndex,
              onTap: _onTap,
            ),
          ),
          // 탭 영역
          SliverToBoxAdapter(
            child: _tabs[_selectedIndex]
          ),
        ],
      ),
    );
  }
}
