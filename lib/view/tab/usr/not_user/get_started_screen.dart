import 'package:flutter/material.dart';

class GetStartedScreen extends StatelessWidget {
  const GetStartedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFFFFFFF),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 145.0, bottom: 0, left: 20, right: 20),
            child: Icon(
              Icons.accessibility_new,
              size: 148,
              color: Colors.amber.shade800,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 140),
            child: Text(
              '성장을 눈으로 보는 방법,\n헬스티어',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 20,
                color: Colors.amber.shade800
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(13.0),
            child: Text(
              '- SNS 간편 로그인 -',
              style: TextStyle(
                fontWeight: FontWeight.w300,
                fontFamily: 'Pretendard',
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 50, // 버튼의 지름
                height: 50, // 버튼의 지름
                decoration: const BoxDecoration(
                  shape: BoxShape.circle, // 원형 모양
                  color: Colors.green, // 초록색
                ),
                child: const Align(
                  alignment: Alignment.center,
                  child: Text(
                    'N',
                    style: TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFFFFFFF),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 15), // 버튼 사이 간격

              Container(
                width: 50,
                height: 50,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.yellow, // 노란색
                ),
                child: const Align(
                  alignment: Alignment.center,
                  child: Text(
                    'Kakao',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 15), // 버튼 사이 간격

              Container(
                width: 50,
                height: 50,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black, // 검은색
                ),
                 child: const Align(
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.apple_outlined,
                    color: Color(0xFFFFFFFF),
                    size: 26,
                  )
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}