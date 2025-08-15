import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' show FlutterQuillLocalizations;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:my_app/database/app_database.dart';
import 'package:my_app/providers/current_page_provider.dart' show currentPageProvider;
import 'package:my_app/providers/usr_auth_providers.dart';
import 'package:my_app/util/navigator_key.dart';
import 'package:my_app/util/user_prefs.dart';
import 'package:my_app/view/tab/cmu/cmu_main.dart';
import 'package:my_app/view/tab/cmu/feed/write/write_feed.dart';
import 'package:my_app/view/tab/doc/doc_main.dart';
import 'package:my_app/view/tab/stc/stc_main.dart';
import 'package:my_app/view/tab/usr/usr_main.dart';
import 'view/navigation_bar.dart';
import 'package:intl/date_symbol_data_local.dart'; 

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('ko');

  await UserPrefs.cleanExpiredPostViewCache();
  await UserPrefs.loadMyUserId(); // 앱 시작 시 사용자 ID 로드

  // 테스트 데이터 삽입 시만 사용
  // final db = AppDatabase();
  // await db.insertTestDataIfNeeded(); // ✅ 테스트 데이터 삽입

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
  int _selectedIndex = 0;
  double islandLeftMargin = 75;

  late AnimationController _fabController;
  late Animation<Offset> _fabSlide;
  late Animation<double> _fabOpacity;
  
  final List<Widget> _pages = [
      const DocMain(), 
      const StcMain(),
      const CmuMain(),
      const UsrMain()
  ];

  @override
  void initState() {
    super.initState();

    _fabController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );

    _fabSlide = Tween<Offset>(
      begin: const Offset(-1.0, 0), // 가운데서 시작
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _fabController,
      curve: Curves.easeOut,
    ));

    _fabOpacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _fabController, 
        curve: Curves.easeIn
    ));

    if(widget.mvIndex!=0) _onTap(widget.mvIndex);
  }

  @override
  void dispose() {
    _fabController.dispose();
    super.dispose();
  }
    
  void _onTap(int index) {
    setState(() {
      _selectedIndex = index;
      ref.read(currentPageProvider.notifier).state = index;
      if(index == 2) {
        islandLeftMargin = 14;
        _fabController.forward(); // FAB 슬라이드 인
      } else {
        islandLeftMargin = 75;
        _fabController.reverse(); // FAB 슬라이드 아웃
      }
    });
  }

  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        extendBody: true,
        body: _pages[_selectedIndex],
        bottomNavigationBar: Stack(
          alignment: Alignment.center,
          children: [
            // cmu 작성 버튼
          if (_selectedIndex == 2)
            Positioned(
              height: 52,
              right: 38,
              bottom: 42,
              child: SlideTransition(
                position: _fabSlide,
                child: FadeTransition(
                  opacity: _fabOpacity,
                  child: Builder(
                    builder: (context) => FloatingActionButton(
                      onPressed: () async {
                        try {
                          final response = await ref.read(jwtTokenVerificationProvider.future);
                          if(response.isValid) {
                            if(!context.mounted)return;
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const WriteFeed(),
                              ),
                            );
                          }
                        } catch (e) {
                          debugPrint('$e');
                        }
                      },
                      backgroundColor: const Color(0xFF0D85E7),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: SvgPicture.asset('assets/widgets/create_feed.svg'),
                    ),
                  ),
                ),
              ),
            )
          else
            Positioned(
              height: 52,
              right: 38,
              bottom: 42,
              child: SlideTransition(
                position: _fabSlide,
                child: FadeTransition(
                  opacity: _fabOpacity,
                  child: Builder(
                    builder: (context) => FloatingActionButton(
                      onPressed: () async {
                       try {
                          final response = await ref.read(jwtTokenVerificationProvider.future);
                          if(response.isValid) {
                            if(!context.mounted)return;
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const WriteFeed(),
                              ),
                            );
                          }
                        } catch (e) {
                          debugPrint('$e');
                        }
                      },
                      backgroundColor: const Color(0xFF0D85E7),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: SvgPicture.asset('assets/widgets/create_feed.svg'),
                    ),
                  ),
                ),
              ),
            ),
            AnimatedContainer( 
              duration: const Duration(milliseconds: 350),
              margin: EdgeInsets.only(left: islandLeftMargin, right: 75, bottom: 42),
              height: 52,
              width: 234,
              curve: Curves.easeInOut,
              child: IslandNavigationBar(
                selectedIndex: _selectedIndex,
                onTap: _onTap,
              ),
            ),
          ],
        )
      ),
      localizationsDelegates: const [
       FlutterQuillLocalizations.delegate,
      ],
    );
  }
}
