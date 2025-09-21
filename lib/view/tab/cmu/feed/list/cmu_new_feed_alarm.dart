import 'package:flutter/material.dart';
import 'package:my_app/util/screen_ratio.dart';

class CmuNewFeedAlarm extends StatelessWidget {
  final VoidCallback onTap;

  const CmuNewFeedAlarm({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final ratio = ScreenRatio(context);
    final htio = ratio.heightRatio;
    final wtio = ratio.widthRatio;
    return GestureDetector(
      onTap: onTap,
      child: Container(
          height: 34 * htio,
          width: 85 * wtio,
          padding: EdgeInsets.symmetric(horizontal: 20 * wtio, vertical: 8 * htio),
          decoration: ShapeDecoration(
              color: const Color(0xFF0D85E7),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(99),
              ),
          ),
          child: Align(
            alignment: Alignment.center,
            child: Text(
                '새 게시글',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 11.5 * htio,
                    fontFamily: 'Pretendard',
                    fontWeight: FontWeight.w600,
                    decoration: TextDecoration.none,
                ),
            ),
          ),
      ),
    );
  }
}