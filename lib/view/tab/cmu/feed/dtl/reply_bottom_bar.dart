import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class ReplyBottomBar extends StatelessWidget {
  const ReplyBottomBar({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        width: 375,
        height: 106,
        child: Stack(
      children: [
          Positioned(
              left: 0,
              top: 0,
              child: Container(
                  width: 375,
                  height: 106,
                  decoration: const ShapeDecoration(
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                          side: BorderSide(
                              width: 1,
                              color: Color(0xFFEEEEEE),
                          ),
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(40),
                              topRight: Radius.circular(40),
                          ),
                      ),
                  ),
              ),
          ),
          Positioned(
              left: 20,
              top: 23,
              child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  spacing: 8,
                  children: [
                      Container(
                          width: 24,
                          height: 24,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                          ),
                          child: SvgPicture.asset(
                            'assets/widgets/default_user_profile.svg',
                            fit: BoxFit.cover,
                          ),
                      ),
                      Container(
                          width: 303,
                          height: 37,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: ShapeDecoration(
                              color: Colors.white,
                              shape: RoundedRectangleBorder(
                                  side: const BorderSide(
                                      width: 1,
                                      color: Color(0xFFDDDDDD),
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                              ),
                          ),
                          child: const TextField(
                            decoration: InputDecoration(
                              hintText: '댓글 달기',
                              border: InputBorder.none,
                              hintStyle: TextStyle(
                                  color: Color(0xFF999999),
                                  fontSize: 14,
                                  fontFamily: 'Pretendard',
                                  fontWeight: FontWeight.w400,
                                  height: 1.50,
                              ),
                            ),
                            style: TextStyle(
                                color: Color(0xFF000000),
                                fontSize: 14,
                                fontFamily: 'Pretendard',
                                fontWeight: FontWeight.w400,
                                height: 1.50,
                            ),
                          ),
                      ),
                  ],
              ),
          ),
          Positioned(
              left: 0,
              top: 69,
              child: SizedBox(
                  width: 375,
                  height: 37,
                  child: Stack(
                      children: [
                          Positioned(
                              left: 121,
                              top: 23,
                              child: Container(
                                  width: 134,
                                  height: 5,
                                  decoration: ShapeDecoration(
                                      color: Colors.black,
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(100),
                                      ),
                                  ),
                              ),
                          ),
                      ],
                  ),
              ),
          ),
      ],
        ),
    );
  }
}