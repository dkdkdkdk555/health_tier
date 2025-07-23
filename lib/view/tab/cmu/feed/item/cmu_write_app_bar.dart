import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class CmuWriteAppBar extends StatelessWidget {
  final String centerText;
  final VoidCallback onSubmit;

  const CmuWriteAppBar({
    super.key,
    required this.centerText,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // ← 뒤로가기 버튼
          GestureDetector(
            onTap: () => Navigator.pop(context), // 취소된다고 얼럴트 띄우기
            child: SvgPicture.asset(
              'assets/icons/feed_detail/ico_back.svg',
              width: 24,
              height: 24,
            ),
          ),

          // 가운데 텍스트
          Text(
            centerText,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 16,
              fontWeight: FontWeight.w600,
              fontFamily: 'Pretendard',
            ),
          ),

          // 오른쪽 '완료' 텍스트 버튼
          GestureDetector(
            onTap: onSubmit,
            child: const Text(
              '완료',
              style: TextStyle(
                color:  Colors.black54,// Color(0xFF0D85E7), -> 글까지 입력하면 색 바뀌기
                fontSize: 16,
                fontWeight: FontWeight.w600,
                fontFamily: 'Pretendard',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
