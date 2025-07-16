import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class LikeAndReplyWidget extends StatelessWidget {
  final int likeCnt;
  final int replyCnt;
  const LikeAndReplyWidget({super.key, required this.likeCnt, required this.replyCnt});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start, // 왼쪽 정렬
        children: [
          Row(
            children: [
              SvgPicture.asset(
                'assets/icons/like.svg',
                width: 16, // 아이콘 크기 명시
                height: 16,
                fit: BoxFit.cover,
              ),
              const SizedBox(width: 2),
              Text(
                '$likeCnt',
                style: const TextStyle(
                  color: Color(0xFF777777),
                  fontSize: 12,
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.w500,
                  height: 1.50,
                ),
              ),
            ],
          ),
          const SizedBox(width: 12), // 좋아요와 댓글 사이 간격
          Row(
            children: [
              SvgPicture.asset(
                'assets/icons/reply.svg',
                width: 16, // 아이콘 크기 명시
                height: 16,
                fit: BoxFit.cover,
              ),
              const SizedBox(width: 2),
              Text(
                '$replyCnt',
                style: const TextStyle(
                  color: Color(0xFF777777),
                  fontSize: 12,
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.w500,
                  height: 1.50,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}