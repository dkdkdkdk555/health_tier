import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class ReplyHamburger extends StatelessWidget {
  const ReplyHamburger({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
        width: 103,
        height: 87,
        padding: const EdgeInsets.all(12),
        decoration: ShapeDecoration(
            color: Colors.white,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
            ),
            shadows: const [
                BoxShadow(
                    color: Color(0x28000000),
                    blurRadius: 12,
                    offset: Offset(0, 4),
                    spreadRadius: 0,
                )
            ],
        ),
        child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                        Padding(
                            padding: const EdgeInsets.only(top: 2.41,left: 1.68,right: 2.29,bottom: 0.97,),
                            child: SizedBox(
                              width: 16,
                              height: 16,
                              child: SvgPicture.asset(
                                'assets/icons/update_feed.svg',
                                fit: BoxFit.cover,
                              ),
                            ),
                        ),
                        const SizedBox(width: 2),
                        const Text(
                            '수정',
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 14,
                                fontFamily: 'Pretendard',
                                height: 0.11,
                            ),
                        ),
                    ],
                ),
                Container(
                    width: double.infinity,
                    height: 1,
                    decoration: const BoxDecoration(color: Color(0xFFEEEEEE)),
                ),
                Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                        Padding(
                            padding: const EdgeInsets.only(top: 3.25,left: 3.75,right: 3.75,bottom: 2.95,),
                            child: SizedBox(
                              width: 16,
                              height: 16,
                              child: SvgPicture.asset(
                                'assets/icons/delete_feed.svg',
                                fit: BoxFit.cover,
                              ),
                            ),
                        ),
                        const SizedBox(width: 2),
                        const Text(
                            '삭제',
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 14,
                                fontFamily: 'Pretendard',
                                height: 0.11,
                            ),
                        ),
                    ],
                ),
            ],
        ),
    );
  }
}