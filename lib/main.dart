import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' show FlutterQuillLocalizations;
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

 
class _MyAppState extends State<MyApp> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
      const DocMain(), 
      const StcMain(),
      const CmuMain(),
      const Center(child: Text('회원')),
  ];

  void _onTap(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        extendBody: true,
        body: _pages[_selectedIndex],
        bottomNavigationBar: IslandNavigationBar(
          selectedIndex: _selectedIndex,
          onTap: _onTap,
        ),
      ),
      localizationsDelegates: const [
       FlutterQuillLocalizations.delegate,
      ],
    );
  }
}
