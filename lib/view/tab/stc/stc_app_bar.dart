import 'package:flutter/material.dart';

class StcAppBar extends StatefulWidget {
  final int selectedIndex;
  final ValueChanged<int> onTap;

  const StcAppBar({
    super.key,
    required this.selectedIndex,
    required this.onTap,
  });


  @override
  State<StcAppBar> createState() => _StcAppBarState();
}

class _StcAppBarState extends State<StcAppBar> {
  final List<String> tabs = ['체중', '골격근량', '체지방률', '하루평가'];
  final List<GlobalKey> _tabKeys = [];

  late int selectedIndex;
  double underlineLeft = 0;
  double underlineWidth = 0;

  bool _isFirstBuild = true; // 첫빌드인가?

  @override
  void initState() {
    super.initState();
    selectedIndex = widget.selectedIndex;
    _tabKeys.addAll(List.generate(tabs.length, (_) => GlobalKey()));
    // post frame callback: 위치 계산
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateUnderline();
      _isFirstBuild = false;
    });
  }

  void _updateUnderline() {
    final key = _tabKeys[selectedIndex];
    final renderBox = key.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox != null) {
      final position = renderBox.localToGlobal(Offset.zero, ancestor: context.findRenderObject());
      final left = position.dx - 20; // 패딩 보정
      final width = renderBox.size.width;

      setState(() {
        underlineLeft = left;
        underlineWidth = width;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 77,
      child: Padding(
        padding: const EdgeInsets.only(left: 20),
        child: Column(
          children: [
            const Spacer(flex: 22),
            const Expanded(
              flex: 41,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '통계',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontFamily: 'Pretendard',
                    fontWeight: FontWeight.w700,
                    height: 1.50,
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 14,
              child: Align(
                alignment: Alignment.centerLeft,
                child: SizedBox(
                  height: 28,
                  child: Stack(
                    children: [
                      // 회색 하단 선
                      Positioned.fill(
                        child: Container(
                          margin: const EdgeInsets.only(top: 26),
                          height: 2,
                          color: const Color(0xFFEEEEEE),
                        ),
                      ),
                      // 검은 밑줄
                      _buildUnderline(),
                      // 텍스트 탭들
                      Row(
                        children: List.generate(tabs.length, (index) {
                          final isSelected = index == selectedIndex;
                          return Padding(
                            padding: const EdgeInsets.only(right: 20),
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedIndex = index;
                                  widget.onTap(selectedIndex);
                                });
                                WidgetsBinding.instance.addPostFrameCallback((_) {
                                  _updateUnderline();
                                });
                              },
                              child: Container(
                                key: _tabKeys[index],
                                child: Text(
                                  tabs[index],
                                  style: TextStyle(
                                    color: isSelected ? Colors.black : const Color(0xFFAAAAAA),
                                    fontSize: 16,
                                    fontFamily: 'Pretendard',
                                    fontWeight: FontWeight.w700,
                                    height: 1.50,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUnderline() {
  final underline = Container(
    width: underlineWidth,
    height: 2,
    color: Colors.black,
  );

  return _isFirstBuild
      ? Positioned(left: underlineLeft, top: 26, child: underline)
      : AnimatedPositioned(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          left: underlineLeft,
          top: 26,
          child: underline,
        );
}
}
