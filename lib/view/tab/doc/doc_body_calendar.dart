import 'package:flutter/material.dart';
import 'package:my_app/view/tab/doc/doc_app_bar.dart' show DocAppBar;
import 'package:my_app/view/tab/simple_cache.dart';
import 'package:responsive_builder/responsive_builder.dart';

class DocBodyCalendar extends StatefulWidget {
  const DocBodyCalendar({
    super.key,
  });

  @override
  State<DocBodyCalendar> createState() => _DocBodyCalendarState();
}

class _DocBodyCalendarState extends State<DocBodyCalendar> {
  late int _selectedIndex;

  
  @override
  void initState() {
    super.initState();
    _selectedIndex = cachedDocTabIndex; // 캐시된 값 불러오기
  }


  final List<Widget> _pages = [
    const Center(child: Text('체중')),
    const Center(child: Text('식단')),
  ];


  void _onTap(int index) {
    setState(() {
      _selectedIndex = index;
      cachedDocTabIndex = index; // 캐시된 값 불러오기
    });
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, sizingInformation) {
        // TODO: 모바일, 태블릿 반응형 분기처리
        return Scaffold(
          body: Column(
            children: [
              // AppBar 대체 영역 (flex: 14)
              DocAppBar(
                  selectedIndex: _selectedIndex,
                  onTap: _onTap,
              ),

              // Body 영역 (flex: 49) with Offstage + TickerMode
              Expanded(
                flex: 201,
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

              // BottomSheet 대체 영역 (flex: 36)
              Expanded(
                flex: 148,
                child: Container(
                  color: Colors.grey[200],
                  child: const Center(child: Text('Bottom Sheet Area')),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
