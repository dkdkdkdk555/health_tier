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
      flex: 14,
      child: Container(
        color: const Color(0xFFFFFFFF),
        padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top), // status bar 고려
        alignment: Alignment.center,
        child: Row(
          children: [
            buildTab(title: '체중', isSelected: selectedIndex == 0 ? true : false, index: 0),
            buildTab(title: '식단', isSelected: selectedIndex == 1 ? true : false, index: 1),
          ],
        ),
      ),
    );
  }

  Widget buildTab({ required String title, required bool isSelected, required int index}) {
  return GestureDetector(
    onTap: () => onTap(index),
    behavior: HitTestBehavior.translucent,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 점 표시
        if (isSelected)
          Container(
            width: 4,
            height: 4,
            margin: const EdgeInsets.only(bottom: 2),
            decoration: const BoxDecoration(
              color: Colors.black,
              shape: BoxShape.circle,
            ),
          )
        else
          const SizedBox(height: 6), // 점 없을 때 간격 유지용

        // 텍스트
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            color: isSelected ? Colors.black : const Color(0xFFAAAAAA),
            fontFamily: 'Pretendard',
          ),
        ),
      ],
    ),
  );
}
}