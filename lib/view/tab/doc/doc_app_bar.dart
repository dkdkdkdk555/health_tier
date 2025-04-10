import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
    return SizedBox(
      height: 114.h,
      child: Column(
        children: [
          SizedBox(height: 64.h,), // 상단 여백 (64px 비율 대응)
          SizedBox(
            height: 33.h,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(child: Container()), // 좌측 여백 (좌우 127px 대체)
                buildTab(
                  title: '체중',
                  isSelected: selectedIndex == 0,
                  index: 0,
                ),
                SizedBox(width: 52.w), // 탭 간격 (54px 대신 비율 감안한 고정)
                buildTab(
                  title: '식단',
                  isSelected: selectedIndex == 1,
                  index: 1,
                ),
                Expanded(child: Container()), // 우측 여백
              ],
            ),
          ),
          SizedBox(height: 16.h,), // 하단 여백 (16px 대응)
        ],
      ),
    );
  }

  Widget buildTab({
    required String title,
    required bool isSelected,
    required int index,
  }) {
    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.translucent,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isSelected)
            Container(
              width: 4.w,
              height: 4.h,
              margin: EdgeInsets.only(bottom: 7.h),
              decoration: const BoxDecoration(
                color: Colors.black,
                shape: BoxShape.circle,
              ),
            )
          else
          SizedBox(height: 11.h),
          Text(
            title,
            style: TextStyle(
              fontSize: 20,
              height: 1,
              fontWeight: FontWeight.w700,
              color: isSelected ? Colors.black : const Color(0xFFAAAAAA),
              fontFamily: 'Pretendard',
            ),
          ),
        ],
      ),
    );
  }
}
