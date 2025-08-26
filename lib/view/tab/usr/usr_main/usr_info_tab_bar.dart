import 'package:flutter/material.dart';

class UsrInfoTabBar extends StatefulWidget {
  final int selectedIndex;
  final ValueChanged<int> onTap;

  const UsrInfoTabBar({
    super.key,
    required this.selectedIndex,
    required this.onTap
  });

  @override
  State<UsrInfoTabBar> createState() => _UsrInfoTabBarState();
}

class _UsrInfoTabBarState extends State<UsrInfoTabBar> {
  final List<String> tabs = ['뱃지', '신체 정보', '내가 쓴 글'];
  
  late int selectedIndex;

  double underlineLeft = 0;
  double underlineWidth = 0;

  bool _isFirstBuild = true;

  // 탭의 고정 너비와 간격을 정의합니다.
  final double fixedTabWidth = 111.6; // 탭의 너비를 동일하게 맞추기 위한 임의의 값

  @override
  void initState() {
    super.initState();
    selectedIndex = widget.selectedIndex;
    
    // GlobalKey는 더 이상 텍스트 크기를 측정하는 용도가 아니므로 제거
    // 대신, WidgetsBinding.instance.addPostFrameCallback 내에서 바로 위치를 계산합니다.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateUnderline();
      _isFirstBuild = false;
    });
  }
  
  @override
  void didUpdateWidget(covariant UsrInfoTabBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedIndex != oldWidget.selectedIndex) {
      selectedIndex = widget.selectedIndex;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _updateUnderline();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Container(
        margin: const EdgeInsets.only(top: 20),
        height: 44,
        child: Stack(
          children: [
            // 회색 하단 선
            Positioned.fill(
              child: Container(
                margin: const EdgeInsets.only(top: 42),
                height: 2,
                color: const Color(0xFFEEEEEE),
              ),
            ),
            _buildUnderline(),
            Container(
              padding: const EdgeInsets.only(left: 20, right: 20,),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(tabs.length, (index) {
                  final isSelected = index == selectedIndex;
                  return GestureDetector(
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
                      width: fixedTabWidth, // 탭의 너비를 고정
                      alignment: Alignment.center,
                      child: Align(
                        alignment: Alignment.center,
                        child: Text(
                          tabs[index],
                          style: TextStyle(
                            color: isSelected ? Colors.black : const Color(0xFFAAAAAA),
                            fontSize: 14.5,
                            fontFamily: 'Pretendard',
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            )
          ],
        ),
      ),
    );
  }

  void _updateUnderline() {
    // 탭의 위치를 계산하여 언더라인 위치를 업데이트
    const leftPadding = 20.0;
    final totalSpacing = selectedIndex;
    final totalWidth = selectedIndex * fixedTabWidth;
    final newLeft = leftPadding + totalWidth + totalSpacing;
    
    setState(() {
      underlineLeft = newLeft;
      underlineWidth = fixedTabWidth;
    });
  }

  Widget _buildUnderline() {
    final underline = Container(
      width: underlineWidth,
      height: 2,
      color: Colors.black,
    );
    
    return _isFirstBuild
        ? Positioned(left: underlineLeft, top: 42, child: underline)
        : AnimatedPositioned(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            left: underlineLeft,
            top: 42,
            child: underline,
          );
  }
}