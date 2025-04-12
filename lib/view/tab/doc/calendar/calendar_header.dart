import 'package:auto_size_text/auto_size_text.dart' show AutoSizeText;
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

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
    final year = focusedDay.year;
    final month = focusedDay.month;

    return Expanded(
      flex: 32,
      child: Center(
        child: Row(
          children: [
            const Spacer(flex:11),
            Expanded( // 왼쪽 화살표
              flex: 5,
              child: IconButton(
                  icon: SvgPicture.asset('assets/icons/ico_left.svg'),
                  onPressed: onLeftArrow,
                  padding: EdgeInsets.zero,
                ),
              ),
            const Spacer(flex:22),
            Expanded( // 가운데 날짜 텍스트
              flex: 22,
              child: AutoSizeText(
                  '$year년 $month월',
                  maxLines: 1,
                  style: const TextStyle(
                    fontSize: 16,
                    fontFamily: 'Pretendard',
                    color: Colors.black,
                    fontWeight: FontWeight.w500,
                    letterSpacing: -0.3,
                ),
              ),
            ),
            const Spacer(flex:22),
            Expanded( // 오른쪽 화살표
              flex: 5,
              child: IconButton(
                  icon: SvgPicture.asset('assets/icons/ico_right.svg'),
                  onPressed: onRightArrow,
                  padding: EdgeInsets.zero,
                ),
              ),
            const Spacer(flex:11),
          ],
        ),
      ),
    );
  }
}
