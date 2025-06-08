import 'package:flutter/material.dart';
import 'package:my_app/extension/screen_ratio_extension.dart';

class CmuAppBar extends StatefulWidget {
  final int selectedIndex;
  final ValueChanged<int> onTap;

  const CmuAppBar({
    super.key,
    required this.selectedIndex,
    required this.onTap
  });

  @override
  State<CmuAppBar> createState() => _CmuAppBarState();
}

var htio = 0.0;
var wtio = 0.0;

class _CmuAppBarState extends State<CmuAppBar> {
  final List<String> tabs = ['피드', '대결', '랭킹'];
  final List<GlobalKey> _tabKeys = [];

  late int selectedIndex;
  double underlineLeft = 0;
  double underlineWidth = 0;

  bool _isFirstBuild = true;

  @override
  void initState() {
    super.initState();
    selectedIndex = widget.selectedIndex;
    // 1. tabs 맴버별 GlobalKey를 생성
    _tabKeys.addAll(List.generate(tabs.length, (_) => GlobalKey()));

    WidgetsBinding.instance.addPostFrameCallback((_) {
    // WidgetsBinding.instance.addPostFrameCallback 는 UI 가 다 그려진 직후에 실행되는 콜백이다.
    // InitState에서 그냥 실행하면 해당 ui 작업이 UI가 다 그려지기도 전에 실행되므로 안전하지 못해서 여기서 실행해준다.
      _updateUnderline();
      _isFirstBuild = false;
    });
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
  
  @override
  Widget build(BuildContext context) {
    htio = ScreenRatio(context).heightRatio;
    wtio = ScreenRatio(context).widthRatio;    

    return SizedBox(
      height : 110 * htio,
      child: Column(
        children: [
          Expanded(
            flex: 41,
            child: Padding(
              padding: EdgeInsets.only(left: 20 * wtio),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '커뮤니티',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 20 * htio,
                    fontFamily: 'Pretendard',
                    fontWeight: FontWeight.w700,
                    height: 1.50 * htio,
                  ),
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
                        margin: EdgeInsets.only(top:26 * htio),
                        height: 2 * htio,
                        color: const Color(0xFFEEEEEE),
                      ),
                    ),
                    _buildUnderline(),
                    Padding(
                      padding: EdgeInsets.only(left: 20 * wtio),
                      child: Row(
                        children: List.generate(tabs.length, (index) {
                          final isSelected = index == selectedIndex;
                          return Padding(
                            padding: EdgeInsets.only(right: 20 * wtio),
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
                                    fontSize: 16 * htio,
                                    fontFamily: 'Pretendard',
                                    fontWeight: FontWeight.w700,
                                    height: 1.50 * htio,
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
            ),
          )
        ],
      ),
    );
  }

  Widget _buildUnderline() {
  final underline = Container(
    width: underlineWidth,
    height: 2 * htio,
    color: Colors.black,
  );
  /*  Positioned 와 AnimatedPositioned 으로 분기하는 이유는
      페이지 첫 진입시 캐시된 하위 페이지를 불러올때 애니메이션 효과로 underline이 
      움직이면 부자연스러워 보여서다.
  */
  return _isFirstBuild
      ? Positioned(left: underlineLeft, top: 26 * htio, child: underline)
      : AnimatedPositioned(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          left: underlineLeft,
          top: 26 * htio,
          child: underline,
        );
  }
}