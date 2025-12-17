import 'dart:io' show Platform;

import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:my_app/util/dialog_utils.dart';
import 'package:my_app/util/firebase_remote_config_service.dart' show RemoteConfigService;
import 'package:my_app/view/tab/doc/diet/doc_diet_main.dart';
import 'package:my_app/view/tab/doc/doc_app_bar.dart' show DocAppBar;
import 'package:my_app/view/tab/doc/body/calendar/doc_calendar_body.dart';
import 'package:my_app/view/tab/simple_cache.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:url_launcher/url_launcher.dart';

class DocMain extends StatefulWidget {
  const DocMain({
    super.key,
  });

  @override
  State<DocMain> createState() => _DocMainState();
}

class _DocMainState extends State<DocMain> {
  late int _selectedIndex;
  static bool _remoteChecked = false; 
  final String appStore = "https://apps.apple.com/kr/app/id6753325210";
  final String playStore = "https://play.google.com/store/apps/details?id=com.health.tier&hl=ko";

  
  @override
  void initState() {
    super.initState();
    _selectedIndex = cachedDocTabIndex; // 캐시된 값 불러오기
    _initRemoteConfigOnce();
  }

  Future<void> _initRemoteConfigOnce() async {
    if (_remoteChecked) return; // 이미 체크했으면 스킵
    _remoteChecked = true;

    await Future.delayed(const Duration(milliseconds: 1200)); // 빌드 안정화
    await checkRemoteConfig();
  }

  // 앱이 최신버전인지 확인 -> 아니라면 업데이트 강제
  Future<void> checkRemoteConfig() async {
    final remoteConfigService = RemoteConfigService.instance;
    final remoteConfig = remoteConfigService.config;

    final latestVersion = remoteConfig.getString('latest_version');
    final forceUpdate = remoteConfig.getBool('force_update');

    final currentVersion = (await PackageInfo.fromPlatform()).version;
    debugPrint('업데이트 강제여부 : $forceUpdate');
    debugPrint('최신 앱버전 : $latestVersion');
    debugPrint('현재 앱버전 : $currentVersion');

    // 현재 버전이 최신버전보다 낮으면서 필수 업데이트 해야하면 강제 업데이트 팝업 띄움
    if (forceUpdate && compareVersion(currentVersion, latestVersion) < 0) {
      _showForceUpdateDialog();
    } else if(!forceUpdate && compareVersion(currentVersion, latestVersion) < 0) {
      _showUpdateDialog();
    }
  }

  // 앱 버전 비교
  int compareVersion(String v1, String v2) {
    final a = v1.split('.').map(int.parse).toList(); // 1.0.1 => [1, 0, 1]
    final b = v2.split('.').map(int.parse).toList(); // 1.1.2 => [1, 1, 2]
    for (int i = 0; i < 3; i++) {
      if (a[i] < b[i]) return -1; // 업데이트가 필요한 경우
      if (a[i] > b[i]) return 1; // 현재 버전이 더 최신인경우
    }
    return 0; // 같은경우
  }

  // 앱 업데이트 강제 팝업 띄움
  void _showForceUpdateDialog() {
    if (!context.mounted) return;
    showAppDialog(
      context, 
      title: '업데이트 필요',
      message: "새로운 버전이 출시되었습니다.\n업데이트 후 이용해주세요.",
      barrierDismiss: false,
      confirmText: '업데이트',
      onConfirm: () async {
        final url = Platform.isAndroid 
          ? playStore
          : appStore;
        await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      },
    );
  }

  // 앱 업데이트 권유 팝업 띄움
  void _showUpdateDialog() {
    if (!context.mounted) return;
    showAppDialog(
      context, 
      title: '업데이트 필요',
      message: "새로운 버전이 출시되었습니다.\n업데이트 후 이용해주세요.",
      barrierDismiss: false,
      confirmText: '업데이트',
      cancelText: '그냥 이용할래요',
      onConfirm: () async {
        final url = Platform.isAndroid 
          ? playStore
          : appStore;
        await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      },
    );
  }


  final List<Widget> _pages = [
    const DocCalendarBody(),
    const DocDietMain(),
  ];

  void _onTap(int index) {
    setState(() {
      _selectedIndex = index;
      cachedDocTabIndex = index; // 캐시된 값 불러오기
    });
    if(index == 1) {
      Future.delayed(Duration.zero, showTutorial);
    }
  }

  void showTutorial() {
    tutorialCoachMarkDiet.show(context: context);
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, sizingInformation) {
        // TODO: 모바일, 태블릿 반응형 분기처리
        return Scaffold(
          body: Column(
            children: [
              // AppBar
              DocAppBar(
                  selectedIndex: _selectedIndex,
                  onTap: _onTap,
              ),

              // Body
              Expanded(
                flex: 349,
                child: Container(
                  color: const Color(0xFFF5F5F5),
                  child: Stack(
                    children: List.generate(_pages.length, (index) {
                      return Offstage(
                        offstage: _selectedIndex != index,
                        child: TickerMode(
                          enabled: _selectedIndex == index,
                          child: _pages[index],
                        ),
                      );
                    }),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
