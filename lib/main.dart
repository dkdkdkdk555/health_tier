import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:my_app/view/tab/doc/doc_body_calendar.dart';
import 'view/navigation_bar.dart';

void main() {
  runApp(
    ScreenUtilInit(
      designSize: const Size(375, 812), // 기준사이즈
      minTextAdapt: true,
      builder: (context, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          home: child!,
        );
      },
      child: const MyApp(), // ✅ 여기서부터는 screenUtil 사용 안전!
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}


class _MyAppState extends State<MyApp> {
  int _selectedIndex = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      // ignore: prefer_const_constructors
      DocBodyCalendar(), // ✅ const 제거 — build 이후에 생성
      const Center(child: Text('통계')),
      const Center(child: Text('커뮤니티')),
      const Center(child: Text('회원')),
    ];
  }

  void _onTap(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: _pages[_selectedIndex],
      bottomNavigationBar: IslandNavigationBar(
        selectedIndex: _selectedIndex,
        onTap: _onTap,
      ),
    );
  }
}
