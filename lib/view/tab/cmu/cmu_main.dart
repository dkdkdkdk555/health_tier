import 'package:flutter/material.dart';
import 'package:my_app/view/tab/simple_cache.dart' show cachedCmuTabIndex;

class CmuMain extends StatefulWidget {
  const CmuMain({super.key});

  @override
  State<CmuMain> createState() => _CmuMainState();
}

class _CmuMainState extends State<CmuMain> {
  // 어느 하위 탭인지
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = cachedCmuTabIndex; // 캐시된 값 불러오기
  }

  void _onTap(int index) {
    setState(() {
      _selectedIndex = index;
      cachedCmuTabIndex = index; // 캐싱
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}