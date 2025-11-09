import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:my_app/util/screen_ratio.dart' show ScreenRatio;
import 'package:my_app/view/tab/cmu/feed/srch/cmu_total_srch.dart';

class CmuAppBar extends StatefulWidget {
  final int selectedIndex;
  final ValueChanged<int> onTap;

  const CmuAppBar({
    super.key,
    required this.selectedIndex,
    required this.onTap,
  });

  @override
  State<CmuAppBar> createState() => _CmuAppBarState();
}

var htio = 0.0;
var wtio = 0.0;

class _CmuAppBarState extends State<CmuAppBar> {
  final List<String> tabs = ['피드'];
  final List<GlobalKey> _tabKeys = [];

  late int selectedIndex;
  double underlineLeft = 0;
  double underlineWidth = 0;

  bool _isFirstBuild = true;

  @override
  void initState() {
    super.initState();
    selectedIndex = widget.selectedIndex;
    _tabKeys.addAll(List.generate(tabs.length, (_) => GlobalKey()));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateUnderline();
      _isFirstBuild = false;
    });
  }

  void _updateUnderline() {
    final key = _tabKeys[selectedIndex];
    final renderBox = key.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox != null) {
      final position = renderBox.localToGlobal(
        Offset.zero,
        ancestor: context.findRenderObject(),
      );
      final left = position.dx;
      final width = renderBox.size.width;

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

    return Container(
      decoration: const BoxDecoration(color: Colors.white),
      child: Column(
        children: [
          // 상단 타이틀 + 검색 버튼
          SizedBox(
            height: 82 * htio,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20 * wtio),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: 
                    SvgPicture.asset(
                      'assets/icons/icon_svg.svg',
                      width: 44 * wtio,
                      fit: BoxFit.contain,
                    ),
                    // Text(
                    //   '커뮤니티',
                    //   style: TextStyle(
                    //     color: Colors.black,
                    //     fontSize: 20 * htio,
                    //     fontFamily: 'Pretendard',
                    //     fontWeight: FontWeight.w700,
                    //     height: 1.50 * htio,
                    //   ),
                    // ),
                  ),
                  GestureDetector(
                    onTap: () {
                      context.push('/cmu/srch');
                    },
                    child: SizedBox(
                      width: 28 * wtio,
                      height: 28 * htio,
                      child: SvgPicture.asset(
                        'assets/widgets/search_btn.svg',
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
          // 하단 탭 영역
          SizedBox(
            height: 28 * htio,
            child: Align(
              alignment: Alignment.centerLeft,
              child: SizedBox(
                height: 28 * htio, // 👈 반응형 적용
                child: Stack(
                  children: [
                    // 회색 하단 선
                    Positioned.fill(
                      child: Container(
                        margin: EdgeInsets.only(top: 26 * htio),
                        height: 2 * htio,
                        color: const Color(0xFFEEEEEE),
                      ),
                    ),
                    // 검은 underline
                    _buildUnderline(),
                    // 탭 텍스트
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
                                WidgetsBinding.instance
                                    .addPostFrameCallback((_) {
                                  _updateUnderline();
                                });
                              },
                              child: Container(
                                key: _tabKeys[index],
                                child: Text(
                                  tabs[index],
                                  style: TextStyle(
                                    color: isSelected
                                        ? Colors.black
                                        : const Color(0xFFAAAAAA),
                                    fontSize: 16 * htio,
                                    fontFamily: 'Pretendard',
                                    fontWeight: FontWeight.w700,
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
          ),
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
