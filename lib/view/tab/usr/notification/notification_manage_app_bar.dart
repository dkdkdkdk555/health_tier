import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class NotificationManageAppBar extends StatefulWidget {
  final String centerText;
  const NotificationManageAppBar({
    super.key,
    required this.centerText
  });

  @override
  State<NotificationManageAppBar> createState() => _CmuBasicAppBarState();
}

class _CmuBasicAppBarState extends State<NotificationManageAppBar> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 375,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      color: Colors.white,
      height: 48,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 가운데 텍스트
          Center(
            child: Text(
              widget.centerText,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontFamily: 'Pretendard',
                fontWeight: FontWeight.w700,
                height: 1,
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
                width: 24,
                height: 24,
                child: SvgPicture.asset(
                  'assets/icons/feed_detail/ico_back.svg',
                  width: 24,
                  height: 24,
                ),
              ),
            ),
          ),

          // 오른쪽 설정 버튼
          Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: () {
                // 여기에 설정 화면 이동 로직
              },
              child: SizedBox(
                width: 24,
                height: 24,
                child: SvgPicture.asset(
                  'assets/widgets/setting.svg',
                  width: 24,
                  height: 24,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
