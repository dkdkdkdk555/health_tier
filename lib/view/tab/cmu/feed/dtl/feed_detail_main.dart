
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class FeedDetailMain extends StatelessWidget {
  const FeedDetailMain({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 375,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                    ),
                    child: ClipOval(
                      child: SvgPicture.asset(
                        'assets/widgets/default_user_profile.svg',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '멸치표류기0212',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 14,
                                fontFamily: 'Pretendard',
                                fontWeight: FontWeight.w500,
                                height: 1.50,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
        Container(
            width: 375,
            padding: const EdgeInsets.all(20),
            child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 40,
                children: [
                    SizedBox(
                        child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            spacing: 24,
                            children: [
                                SizedBox(
                                    child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        spacing: 8,
                                        children: [
                                            Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                decoration: ShapeDecoration(
                                                    color: const Color(0xFFF5F5F5),
                                                    shape: RoundedRectangleBorder(
                                                        borderRadius: BorderRadius.circular(99),
                                                    ),
                                                ),
                                                child: const Row(
                                                    mainAxisSize: MainAxisSize.min,
                                                    mainAxisAlignment: MainAxisAlignment.start,
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    spacing: 10,
                                                    children: [
                                                        Row(
                                                            mainAxisSize: MainAxisSize.min,
                                                            mainAxisAlignment: MainAxisAlignment.start,
                                                            crossAxisAlignment: CrossAxisAlignment.center,
                                                            spacing: 4,
                                                            children: [
                                                                Text(
                                                                    '운동부위',
                                                                    style: TextStyle(
                                                                        color: Color(0xFF777777),
                                                                        fontSize: 12,
                                                                        fontFamily: 'Pretendard',
                                                                        fontWeight: FontWeight.w400,
                                                                        height: 1.50,
                                                                    ),
                                                                ),
                                                            ],
                                                        ),
                                                    ],
                                                ),
                                            ),
                                            const SizedBox(
                                                width: 335,
                                                child: Text(
                                                    '오늘 데드리프트 PR 갱신했습니다🔥 오늘 데드리프트',
                                                    style: TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 20,
                                                        fontFamily: 'Pretendard',
                                                        fontWeight: FontWeight.w700,
                                                        height: 1.40,
                                                    ),
                                                ),
                                            ),
                                            const Row(
                                                mainAxisSize: MainAxisSize.min,
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                spacing: 4,
                                                children: [
                                                    Text(
                                                        '방금 전',
                                                        style: TextStyle(
                                                            color: Color(0xFF777777),
                                                            fontSize: 14,
                                                            fontFamily: 'Pretendard',
                                                            fontWeight: FontWeight.w400,
                                                            height: 1.50,
                                                        ),
                                                    ),
                                                    Text(
                                                        '·',
                                                        style: TextStyle(
                                                            color: Color(0xFF777777),
                                                            fontSize: 14,
                                                            fontFamily: 'Pretendard',
                                                            fontWeight: FontWeight.w400,
                                                            height: 1.50,
                                                        ),
                                                    ),
                                                    Text(
                                                        '조회수 140',
                                                        style: TextStyle(
                                                            color: Color(0xFF777777),
                                                            fontSize: 14,
                                                            fontFamily: 'Pretendard',
                                                            fontWeight: FontWeight.w400,
                                                            height: 1.50,
                                                        ),
                                                    ),
                                                ],
                                            ),
                                        ],
                                    ),
                                ),
                                const SizedBox(
                                    width: 335,
                                    child: Text(
                                        '3대 운동 시작한 지 6개월 차인데 드디어 데드리프트 140kg 성공했어요! 폼 체크도 받았는데 괜찮다고 해서 너무 뿌듯합니다.',
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 16,
                                            fontFamily: 'Pretendard',
                                            fontWeight: FontWeight.w400,
                                            height: 1.40,
                                        ),
                                    ),
                                ),
                            ],
                        ),
                    ),
                    SizedBox(
                        width: 335,
                        child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            spacing: 10,
                            children: [
                                Column(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    spacing: 12,
                                    children: [
                                        Row(
                                            mainAxisSize: MainAxisSize.min,
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            spacing: 4,
                                            children: [
                                                Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                                    decoration: ShapeDecoration(
                                                        shape: RoundedRectangleBorder(
                                                            side: const BorderSide(
                                                                width: 1,
                                                                color: Color(0xFFDDDDDD),
                                                            ),
                                                            borderRadius: BorderRadius.circular(99),
                                                        ),
                                                    ),
                                                    child: Row(
                                                        mainAxisSize: MainAxisSize.min,
                                                        mainAxisAlignment: MainAxisAlignment.start,
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        spacing: 10,
                                                        children: [
                                                            Row(
                                                                mainAxisSize: MainAxisSize.min,
                                                                mainAxisAlignment: MainAxisAlignment.start,
                                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                                spacing: 2,
                                                                children: [
                                                                    SizedBox(
                                                                      width: 16,
                                                                      height: 16,
                                                                      child: SvgPicture.asset(
                                                                        'assets/icons/like.svg',
                                                                        width: 16,
                                                                        height: 16,
                                                                        fit: BoxFit.cover,
                                                                      ),
                                                                    ),
                                                                    const Text(
                                                                        '좋아요',
                                                                        style: TextStyle(
                                                                            color: Color(0xFF333333),
                                                                            fontSize: 12,
                                                                            fontFamily: 'Pretendard',
                                                                            fontWeight: FontWeight.w400,
                                                                            height: 1.50,
                                                                        ),
                                                                    ),
                                                                ],
                                                            ),
                                                        ],
                                                    ),
                                                ),
                                            ],
                                        ),
                                    ],
                                ),
                            ],
                        ),
                    ),
                ],
            ),
        ),
      ],
    );
  }
}