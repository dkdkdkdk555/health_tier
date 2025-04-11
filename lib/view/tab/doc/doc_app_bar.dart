import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

class DocAppBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTap;

  const DocAppBar({
    super.key,
    required this.selectedIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 57,
      child: Column(
        children: [
          const Spacer(flex: 32),
          Expanded(
            flex: 17,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(flex:127, child: Container()), // 좌측 여백 (좌우 127px 대체)
                buildTab(
                  title: '체중',
                  isSelected: selectedIndex == 0,
                  index: 0,
                ),
                const Spacer(flex: 52),
                buildTab(
                  title: '식단',
                  isSelected: selectedIndex == 1,
                  index: 1,
                ),
                Expanded(flex:127, child: Container()), // 우측 여백
              ],
            ),
          ),
          const Spacer(flex: 8)
        ],
      ),
    );
  }

  Widget buildTab({
    required String title,
    required bool isSelected,
    required int index,
  }) {
    return Expanded(
      flex: 35,
      child: GestureDetector(
        onTap: () => onTap(index),
        behavior: HitTestBehavior.translucent,
        child: Column(
            children: [
              if (isSelected)...[ // ...[] 는 조건문 안에 여러 위젯을 넣을때 사용되는 스프레드 문법 이다.
                Expanded(
                  flex: 8,
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.black,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                const Expanded(flex: 1,child: SizedBox.expand()),
              ]else
                const Expanded(flex: 9,child: SizedBox.expand()),
                Expanded(
                  flex: 52,
                  child: AutoSizeText(
                    title,
                    maxLines: 1,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 20,
                      color: isSelected ? Colors.black : const Color(0xFFAAAAAA),
                      fontFamily: 'Pretendard',
                    ),
                  ),
                ),
            ],
        ),
      ),
    );
  }
}
