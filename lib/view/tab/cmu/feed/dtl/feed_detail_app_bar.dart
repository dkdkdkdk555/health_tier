import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class FeedDetailAppBar extends StatefulWidget {
  const FeedDetailAppBar({super.key});

  @override
  State<FeedDetailAppBar> createState() => _FeedDetailAppBarState();
}

class _FeedDetailAppBarState extends State<FeedDetailAppBar> {
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

          // 우측 아이콘 묶음
          Row(
            children: [
              SvgPicture.asset(
                'assets/icons/feed_detail/ico_share.svg',
                width: 24,
                height: 24,
              ),
              const SizedBox(width: 16),
              SvgPicture.asset(
                'assets/icons/feed_detail/ico_hamberger.svg',
                width: 24,
                height: 24,
              ),
            ],
          ),
        ],
      ),
    );
  }
}