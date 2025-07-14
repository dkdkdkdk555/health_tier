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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 좌측 아이콘
          GestureDetector(
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
        ],
      ),
    );
  }
}