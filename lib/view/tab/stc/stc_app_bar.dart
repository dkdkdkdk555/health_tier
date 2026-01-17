import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'
    show ConsumerState, ConsumerStatefulWidget;
import 'package:my_app/util/screen_ratio.dart' show ScreenRatio;
import 'package:my_app/view/tab/stc/stc_main.dart' show stcSubsetPageProvider;

class StcAppBar extends ConsumerStatefulWidget {
  final int selectedIndex;
  final ValueChanged<int> onTap;

  const StcAppBar({
    super.key,
    required this.selectedIndex,
    required this.onTap,
  });

  @override
  ConsumerState<StcAppBar> createState() => _StcAppBarState();
}

class _StcAppBarState extends ConsumerState<StcAppBar> {
  final List<String> tabs = ['체중', '골격근량', '체지방률', '하루평가'];
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
      final position = renderBox.localToGlobal(Offset.zero,
          ancestor: context.findRenderObject());
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
    final htio = ScreenRatio(context).heightRatio;
    final wtio = ScreenRatio(context).widthRatio;

    selectedIndex = ref.read(stcSubsetPageProvider);
    _updateUnderline();

    return Column(
      children: [
        SizedBox(height: 44 * htio), // Spacer 대신
        Padding(
          padding: EdgeInsets.only(left: 20 * wtio, top: 28 * htio),
          child: Align(
            alignment: Alignment.centerLeft,
            child: SizedBox(
              height: 30 * htio,
              child: Text(
                '통계',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20 * htio,
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: 24 * htio),
        SizedBox(
          height: 28 * htio, // 전체 탭 영역
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
              // 검은 밑줄
              _buildUnderline(htio),
              // 텍스트 탭들
              Padding(
                padding: EdgeInsets.only(
                  left: 20 * wtio,
                ),
                child: Row(
                  children: List.generate(tabs.length, (index) {
                    final isSelected = index == selectedIndex;
                    return Padding(
                      padding: EdgeInsets.only(
                        right: 20 * wtio,
                      ),
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
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildUnderline(double htio) {
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
