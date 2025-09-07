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

    return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 30),
            child: Align(
              alignment: Alignment.centerRight,
              child: SizedBox(
                width: 30 * widthRatio, // 화살표 버튼 가로 크기
                height: 30 * widthRatio, // 화살표 버튼 세로 크기
                child: IconButton(
                  icon: SvgPicture.asset(
                    'assets/icons/ico_left.svg',
                  ),
                  onPressed: onLeftArrow,
                  padding: EdgeInsets.zero,
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 23 * heightRatio),
            child: SizedBox(
              height: 18 * heightRatio,
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
          ),
          Padding(
            padding: const EdgeInsets.only(right: 30),
            child: Align(
              alignment: Alignment.centerLeft,
              child: SizedBox(
                width: 30 * widthRatio,
                height: 30 * widthRatio,
                child: IconButton(
                  icon: SvgPicture.asset(
                    'assets/icons/ico_right.svg',
                  ),
                  onPressed: onRightArrow,
                  padding: EdgeInsets.zero,
                ),
              ),
            ),
          ),
        ],
      );
  }
}
