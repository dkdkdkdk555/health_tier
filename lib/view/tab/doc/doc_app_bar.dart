import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:my_app/util/screen_ratio.dart';

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
    final ratio = ScreenRatio(context);

    final heightRatio = ratio.heightRatio;
    final widthRatio = ratio.widthRatio;

    return Container(
      color: Colors.white,
      alignment: Alignment.center,
      child: Column(
        children: [
          SizedBox(height: 64 * heightRatio), // 상단 여백
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              buildTab(
                title: '체중',
                isSelected: selectedIndex == 0,
                index: 0,
                widthRatio: widthRatio,
                heightRatio: heightRatio,
              ),
              SizedBox(width: 52 * widthRatio),
              buildTab(
                title: '식단',
                isSelected: selectedIndex == 1,
                index: 1,
                widthRatio: widthRatio,
                heightRatio: heightRatio,
              ),
            ],
          ),
          SizedBox(height: 16 * heightRatio), // 하단 여백
        ],
      ),
    );
  }

  Widget buildTab({
    required String title,
    required bool isSelected,
    required int index,
    required double widthRatio,
    required double heightRatio,
  }) {
    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.translucent,
      child: Column(
        children: [
          if (isSelected) ...[
            Container(
              width: 4 * widthRatio, // 원 크기 비율
              height: 4 * widthRatio,
              decoration: const BoxDecoration(
                color: Colors.black,
                shape: BoxShape.circle,
              ),
            ),
          ] else
            SizedBox(height: 4 * heightRatio),
          SizedBox(
            height: 30 * heightRatio,
            child: Center(
              child: AutoSizeText(
                title,
                maxLines: 1,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 19 * widthRatio, // 글자 크기도 가로 기준으로
                  color: isSelected ? Colors.black : const Color(0xFFAAAAAA),
                  fontFamily: 'Pretendard',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
