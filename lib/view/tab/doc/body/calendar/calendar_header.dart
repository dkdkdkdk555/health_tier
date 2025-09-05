import 'package:auto_size_text/auto_size_text.dart' show AutoSizeText;
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_svg/svg.dart';
import 'package:my_app/util/screen_ratio.dart';

class CustomCalendarHeader extends StatelessWidget {
  final DateTime focusedDay;
  final VoidCallback onLeftArrow;
  final VoidCallback onRightArrow;

  const CustomCalendarHeader({
    super.key,
    required this.focusedDay,
    required this.onLeftArrow,
    required this.onRightArrow,
  });

  @override
  Widget build(BuildContext context) {
    final ratio = ScreenRatio(context);
    final widthRatio = ratio.widthRatio;
    final heightRatio = ratio.heightRatio;

    final year = focusedDay.year;
    final month = focusedDay.month;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 44 * widthRatio, vertical: 24 * heightRatio),
      child: SizedBox(
        height: 16 * heightRatio,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 16 * widthRatio, // 화살표 버튼 가로 크기
              height: 16 * widthRatio, // 화살표 버튼 세로 크기
              child: IconButton(
                icon: SvgPicture.asset(
                  'assets/icons/ico_left.svg',
                ),
                onPressed: onLeftArrow,
                padding: EdgeInsets.zero,
              ),
            ),
            SizedBox(width: 92 * widthRatio), // 좌우 spacer
            Expanded(
              child: Text(
                '$year년 $month월',
                maxLines: 1,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14 * heightRatio, // 폰트도 반응형
                  fontFamily: 'Pretendard',
                  color: Colors.black,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            SizedBox(width: 92 * widthRatio),
            SizedBox(
              width: 16 * widthRatio,
              height: 16 * widthRatio,
              child: IconButton(
                icon: SvgPicture.asset(
                  'assets/icons/ico_right.svg',
                ),
                onPressed: onRightArrow,
                padding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
