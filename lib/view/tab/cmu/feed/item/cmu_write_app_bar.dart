import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:my_app/util/dialog_utils.dart';
import 'package:my_app/util/screen_ratio.dart' show ScreenRatio;

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
    final htio = ScreenRatio(context).heightRatio;
    final wtio = ScreenRatio(context).widthRatio;

    return Container(
      height: 48 * htio,
      padding: EdgeInsets.symmetric(horizontal: 20 * wtio),
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
              width: 24 * wtio,
              height: 24 * htio,
            ),
          ),

          // 가운데 텍스트
          Text(
            centerText,
            style: TextStyle(
              color: Colors.black,
              fontSize: 16 * htio,
              fontWeight: FontWeight.w600,
              fontFamily: 'Pretendard',
            ),
          ),

          // 오른쪽 '완료' 텍스트 버튼
          GestureDetector(
            onTap: () {
              onSubmit();
            },
            child: Text(
              '완료',
              style: TextStyle(
                color:  Colors.black54,// Color(0xFF0D85E7), -> 글까지 입력하면 색 바뀌기
                fontSize: 16 * htio,
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
