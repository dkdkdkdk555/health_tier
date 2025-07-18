import 'package:flutter/material.dart';

class GetStartedScreen extends StatelessWidget {
  const GetStartedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 40.0, bottom: 20, left: 20, right: 20),
            child: Icon(
              Icons.accessibility_new,
              size: 48,
              color: Colors.amber.shade800,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 30),
            child: Text(
              '기록하고 소통하며 함께 성장해요!',
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 20,
                color: Colors.amber.shade800
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
              ),
              const SizedBox(width: 20), // 버튼 사이 간격

              Container(
                width: 50,
                height: 50,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.yellow, // 노란색
                ),
              ),
              const SizedBox(width: 20), // 버튼 사이 간격

              Container(
                width: 50,
                height: 50,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black, // 검은색
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}