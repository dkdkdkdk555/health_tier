import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:my_app/util/screen_ratio.dart';

class CmuBasicAppBar extends StatefulWidget {
  final String centerText;
  const CmuBasicAppBar({
    super.key,
    required this.centerText
  });

  @override
  State<CmuBasicAppBar> createState() => _CmuBasicAppBarState();
}

class _CmuBasicAppBarState extends State<CmuBasicAppBar> {
  @override
  Widget build(BuildContext context) {
    final htio = ScreenRatio(context).heightRatio;
    final wtio = ScreenRatio(context).widthRatio;
    return Container(
      width: 375 * wtio,
      padding: EdgeInsets.symmetric(horizontal: 20 * wtio, vertical: 10 * htio),
      color: Colors.white,
      height: 48 * htio,
      child: Stack(
        children: [
          // 가운데 텍스트
          Center(
            child: Text(
              widget.centerText,
              style: TextStyle(
                color: Colors.black,
                fontSize: 18 * htio,
                fontFamily: 'Pretendard',
                fontWeight: FontWeight.w700,
                height: 1 * htio,
              ),
            ),
          ),

          // 왼쪽 뒤로가기 버튼
          Align(
            alignment: Alignment.centerLeft,
            child: GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: SizedBox(
                width: 24 * wtio,
                height: 24 * wtio,
                child: SvgPicture.asset(
                  'assets/icons/feed_detail/ico_back.svg',
                  width: 24 * wtio,
                  height: 24 * wtio,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
