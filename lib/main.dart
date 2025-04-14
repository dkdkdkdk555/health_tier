import 'package:flutter/material.dart';
import 'package:my_app/database/app_database.dart';
import 'package:my_app/view/tab/doc/doc_main.dart';
import 'view/navigation_bar.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();

  final db = AppDatabase();
  await db.insertTestDataIfNeeded(); // ✅ 테스트 데이터 삽입

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
