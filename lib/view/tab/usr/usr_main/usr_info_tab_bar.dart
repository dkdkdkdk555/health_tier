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
  
  static const double horizontalPadding = 20.0;
  
  bool _isFirstBuild = true;

  @override
  void initState() {
    super.initState();
    selectedIndex = widget.selectedIndex;
  }
  
  @override
  void didUpdateWidget(covariant UsrInfoTabBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedIndex != oldWidget.selectedIndex) {
      selectedIndex = widget.selectedIndex;
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double containerWidth = constraints.maxWidth;
        final double usableWidth = containerWidth - (horizontalPadding * 2);
        final double dynamicTabWidth = usableWidth / tabs.length;
        
        final double underlineLeft = horizontalPadding + (selectedIndex * dynamicTabWidth);
        final double underlineWidth = dynamicTabWidth;

        // Animate only after the first build
        final Duration duration = _isFirstBuild ? Duration.zero : const Duration(milliseconds: 250);
        
        // This flag is updated here to ensure the animation is disabled only for the very first frame.
        _isFirstBuild = false;

        return SizedBox(
          width: double.infinity,
          child: Container(
            margin: const EdgeInsets.only(top: 20),
            height: 44,
            child: Stack(
              children: [
                Positioned.fill(
                  child: Container(
                    margin: const EdgeInsets.only(top: 42),
                    height: 2,
                    color: const Color(0xFFEEEEEE),
                  ),
                ),
                AnimatedPositioned(
                  duration: duration,
                  curve: Curves.easeInOut,
                  left: underlineLeft,
                  top: 42,
                  child: Container(
                    width: underlineWidth,
                    height: 2,
                    color: Colors.black,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: horizontalPadding),
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
                        },
                        child: Container(
                          width: dynamicTabWidth,
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
      },
    );
  }
}