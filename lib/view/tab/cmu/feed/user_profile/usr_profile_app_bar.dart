import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class UsrProfileAppBar extends StatefulWidget {
  const UsrProfileAppBar({super.key});

  @override
  State<UsrProfileAppBar> createState() => _UsrProfileAppBarState();
}

class _UsrProfileAppBarState extends State<UsrProfileAppBar> {
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
          const Center(
            child: Text(
              '이용자 프로필',
              style: TextStyle(
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
        ],
      ),
    );
  }
}
