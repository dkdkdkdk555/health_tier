import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:my_app/util/dialog_utils.dart';

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
            onTap: () {
              showAppDialog(context, message: '나가기를 누르시면 작성이 취소되고 내용이 삭제됩니다.',
                confirmText: '나가기', cancelText: '머물기', onConfirm: () => context.pop(),);
            },
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
            onTap: () {
              onSubmit();
            },
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
