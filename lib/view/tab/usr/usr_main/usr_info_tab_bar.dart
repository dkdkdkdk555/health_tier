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
  final List<String> tabs = ['신체 정보', '뱃지', '내가 쓴 글'];
  final List<GlobalKey> _tabKeys = [];
  
  late int selectedIndex;

  double underlineLeft = 0;
  double underlineWidth = 0;

  bool _isFirstBuild = true;

  @override
  void initState() {
    super.initState();
    selectedIndex = widget.selectedIndex;
    // tabs 맴버별 GlobalKey를 생성
    _tabKeys.addAll(List.generate(tabs.length, (_) => GlobalKey()));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateUnderline();
      _isFirstBuild = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: SizedBox(
        height: 28,
        child: Stack(
          children: [
            // 회색 하단 선
            Positioned.fill(
              child: Container(
                margin: const EdgeInsets.only(top:26),
                height: 2,
                color: const Color(0xFFEEEEEE),
              ),
            ),
            _buildUnderline(),
            Padding(
              padding: const EdgeInsets.only(left: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                        WidgetsBinding.instance.addPostFrameCallback((_){
                          _updateUnderline();
                        });
                      },
                      child: Container(
                        // 2. GlobalKey를 Container 위젯에 부여 => Container(=Text)의 위치/렌더링 정보에 접근할 수 있음
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
            )
          ],
        ),
      ),
    );
  }

  void _updateUnderline() {
    // 3. Container(=Text)에 부여된 GlobalKey 꺼냄
    final key = _tabKeys[selectedIndex];
    // 4. GlobalKey로 RenderBox를 가져옴 -> 이게 있어야 위치와 크기 알 수 있음
    final renderBox = key.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox != null) {
      // 해당 탭 텍스트가 스크린 전체에서 어디에 위치해 있는지를 구한다.
      final position = renderBox.localToGlobal(Offset.zero, ancestor: context.findRenderObject());
      final left = position.dx; // 패딩 보정
      final width = renderBox.size.width;
      // underline을 해당 탭이 위치한 위치로 이동시킴
      setState(() {
        underlineLeft = left;
        underlineWidth = width;
      });
    }
  }

  Widget _buildUnderline() {
    final underline = Container(
      width: underlineWidth,
      height: 2,
      color: Colors.black,
    );
    /*  Positioned 와 AnimatedPositioned 으로 분기하는 이유는
        페이지 첫 진입시 캐시된 하위 페이지를 불러올때 애니메이션 효과로 underline이 
        움직이면 부자연스러워 보여서다.
    */
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