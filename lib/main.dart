import 'package:flutter/material.dart';
import 'package:my_app/service/dbhelper.dart';
import 'package:my_app/view/tab/doc/doc_main.dart';
import 'view/navigation_bar.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized(); // Flutter 앱이 실행되기 전에 필요한 바인딩 초기화 코드, main()에서 비동기 작업(await)을 하려면 Flutter 엔진이 먼저 초기화되어 있어야 함 

  // 앱 시작 시 DB 초기화
  await DBHelper.initDB();
  runApp(const MyApp());
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
      const Center(child: Text('통계')),
      const Center(child: Text('커뮤니티')),
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
    );
  }
}
