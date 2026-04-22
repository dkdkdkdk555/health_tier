import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class LikeAndReplyWidget extends StatelessWidget {
  final int likeCnt;
  final int replyCnt;
  final double htio;
  final double wtio;
  const LikeAndReplyWidget({
    super.key, 
    required this.likeCnt, 
    required this.replyCnt,
    required this.htio,
    required this.wtio,
  });

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
                width: 16 * wtio, // 아이콘 크기 명시
                height: 16 * htio,
                fit: BoxFit.cover,
              ),
              SizedBox(width: 2 * wtio),
              Text(
                '$likeCnt',
                style: TextStyle(
                  color: const Color(0xFF777777),
                  fontSize: 12 * htio,
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.w500,
                  height: 1.50 * htio,
                ),
              ),
            ],
          ),
          SizedBox(width: 12 * wtio), // 좋아요와 댓글 사이 간격
          Row(
            children: [
              SvgPicture.asset(
                'assets/icons/reply.svg',
                width: 16 * wtio, // 아이콘 크기 명시
                height: 16 * htio,
                fit: BoxFit.cover,
              ),
              SizedBox(width: 2 *wtio),
              Text(
                '$replyCnt',
                style: TextStyle(
                  color: const Color(0xFF777777),
                  fontSize: 12 * htio,
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.w500,
                  height: 1.50 * htio,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}