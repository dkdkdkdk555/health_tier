import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' show FlutterQuillLocalizations;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:my_app/database/app_database.dart';
import 'package:my_app/view/tab/cmu/cmu_main.dart';
import 'package:my_app/view/tab/cmu/rich_text_editor_page.dart';
import 'package:my_app/view/tab/doc/doc_main.dart';
import 'package:my_app/view/tab/stc/stc_main.dart';
import 'view/navigation_bar.dart';
import 'package:intl/date_symbol_data_local.dart'; 

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('ko');

  final db = AppDatabase();
  await db.insertTestDataIfNeeded(); // ✅ 테스트 데이터 삽입

  runApp(const ProviderScope( // 상태관리 패키지 - Riverpod 설정
    child:MyApp())
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

 
class _MyAppState extends State<MyApp> with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  double islandLeftMargin = 75;

  late AnimationController _fabController;
  late Animation<Offset> _fabSlide;
  late Animation<double> _fabFade;

  final List<Widget> _pages = [
      const DocMain(), 
      const StcMain(),
      const CmuMain(),
      const Center(child: Text('회원')),
  ];

  @override
  void initState() {
    super.initState();
    _fabController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _fabSlide = Tween<Offset>(
      begin: const Offset(-1.0, 0), // 가운데서 시작
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _fabController,
      curve: Curves.easeOut,
    ));

    _fabFade = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fabController,
      curve: Curves.easeOut,
    ));
  }

  @override
  void dispose() {
    _fabController.dispose();
    super.dispose();
  }
    
    void _onTap(int index) {
    setState(() {
      _selectedIndex = index;
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
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        extendBody: true,
        body: _pages[_selectedIndex],
        bottomNavigationBar: Stack(
          alignment: Alignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 400),
              margin: EdgeInsets.only(left: islandLeftMargin, right: 75, bottom: 42),
              height: 52,
              width: 234,
              curve: Curves.easeInOut,
              child: IslandNavigationBar(
                selectedIndex: _selectedIndex,
                onTap: _onTap,
              ),
            ),
            // cmu 작성 버튼
            if(_selectedIndex == 2)
              Positioned(
                height: 52,
                right: 38,
                bottom: 42, // == IslandNavigationBar
                child: SlideTransition(
                  position: _fabSlide,
                  child: FadeTransition(
                    opacity: _fabFade,
                    child: (_selectedIndex == 2)
                        ? FloatingActionButton(
                            onPressed: () {},
                            backgroundColor: const Color(0xFF0D85E7),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: SvgPicture.asset('assets/widgets/create_feed.svg'),
                          )
                        : const SizedBox.shrink(),
                  ), // 빈 위젯로 대체
                ),
              )
          ],
        )
      ),
      localizationsDelegates: const [
       FlutterQuillLocalizations.delegate,
      ],
    );
  }
}
