import 'dart:io' show Platform;

import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_app/main.dart' show rootNavigatorKey;
import 'package:my_app/notifier/tutorial_notifier.dart' show dietTutorialStorageProvider;
import 'package:my_app/util/dialog_utils.dart';
import 'package:my_app/util/firebase_remote_config_service.dart' show RemoteConfigService;
import 'package:my_app/view/tab/doc/diet/doc_diet_main.dart';
import 'package:my_app/view/tab/doc/doc_app_bar.dart' show DocAppBar;
import 'package:my_app/view/tab/doc/body/calendar/doc_calendar_body.dart';
import 'package:my_app/view/tab/simple_cache.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:shared_preferences/shared_preferences.dart' show SharedPreferences;
import 'package:url_launcher/url_launcher.dart';

class DocMain extends ConsumerStatefulWidget {
  const DocMain({
    super.key,
  });

  @override
  ConsumerState<DocMain> createState() => _DocMainState();
}

class _DocMainState extends ConsumerState<DocMain> {
  late int _selectedIndex;
  static bool _remoteChecked = false; 
  final String appStore = "https://apps.apple.com/kr/app/id6753325210";
  final String playStore = "https://play.google.com/store/apps/details?id=com.health.tier&hl=ko";

  late final PageController _pageController;
  
  @override
  void initState() {
    super.initState();
    _selectedIndex = cachedDocTabIndex; // 캐시된 값 불러오기
    _pageController = PageController(initialPage: _selectedIndex);
    _initRemoteConfigOnce();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _initRemoteConfigOnce() async {
    if (_remoteChecked) return; // 이미 체크했으면 스킵
    _remoteChecked = true;

    await Future.delayed(const Duration(milliseconds: 2050)); // 빌드 안정화
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

  void _onTap(int index) async{
    setState(() {
      _selectedIndex = index;
      cachedDocTabIndex = index; // 캐시된 값 불러오기
    });

    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
    
    if(index == 1) {
      final prefs = await SharedPreferences.getInstance();
      final isShown = prefs.getBool("is_diet_tutorial_shown") ?? false;
      if(!isShown) {
        // 100ms 뒤에 트리거 프로바이더에 현재 시간을 넣어 신호를 보냄
        Future.delayed(const Duration(milliseconds: 100), () {
          if (mounted) {
            ref.read(dietTutorialTriggerProvider.notifier).state = DateTime.now();
          }
        });
      }
    }
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
                child: Container(
                  color: const Color(0xFFF5F5F5),
                  child: PageView(
                    controller: _pageController,
                    physics: const BouncingScrollPhysics(), // iOS 느낌
                    onPageChanged: (index) {
                      setState(() {
                        _selectedIndex = index;
                        cachedDocTabIndex = index;
                      });
                  
                      if (index == 1) {
                        SharedPreferences.getInstance().then((prefs) {
                          final isShown = prefs.getBool("is_diet_tutorial_shown") ?? false;
                          if (!isShown) {
                            ref.read(dietTutorialTriggerProvider.notifier).state = DateTime.now();
                          }
                        });
                      }
                    },
                    children: const [
                      DocCalendarBody(),
                      DocDietMain(),
                    ],
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
