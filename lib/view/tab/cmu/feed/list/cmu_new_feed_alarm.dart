import 'package:flutter/material.dart';

class CmuNewFeedAlarm extends StatelessWidget {
  const CmuNewFeedAlarm({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
        height: 34,
        width: 85,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: ShapeDecoration(
            color: const Color(0xFF0D85E7),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(99),
            ),
        ),
        child: const Align(
          alignment: Alignment.center,
          child: Text(
              '새 게시글',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.w400,
                  height: 1.50,
                  decoration: TextDecoration.none,
              ),
          ),
        ),
    );
  }
}