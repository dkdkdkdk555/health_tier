import 'package:flutter/material.dart';

class MyBadge extends StatefulWidget {
  const MyBadge({super.key});

  @override
  State<MyBadge> createState() => _MyBadgeState();
}

class _MyBadgeState extends State<MyBadge> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildHeader('중량 뱃지'),
          _buildBadgeList(),
          _buildHeader('오운완 뱃지'),
          _buildBadgeList(),
          const SizedBox(height: 100,)
        ],
      ),
    );
  }

  // 반복되는 헤더 부분을 함수로 분리
  Widget _buildHeader(String title) {
    return Container(
      width: double.infinity,
      height: 86,
      padding: const EdgeInsets.only(
        top: 48,
        left: 20,
        right: 20,
        bottom: 8,
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontFamily: 'Pretendard',
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  // 반복되는 배지 목록 부분을 함수로 분리
  Widget _buildBadgeList() {
    // 실제 데이터가 들어갈 리스트
    final List<String> badgeNames = ['삼대삼백', '삼대사백', '삼대오백', '삼대육백', '삼대칠백', '삼대팔백'];
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      // Wrap 위젯을 사용하여 여러 줄에 배지 아이템을 배치
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 16, // 가로 간격
        runSpacing: 24, // 세로 간격 (줄 사이의 간격)
        children: List.generate(badgeNames.length, (index) {
          return _buildBadgeItem(badgeNames[index]);
        }),
      ),
    );
  }

  // 개별 배지 아이템 위젯을 함수로 분리
  Widget _buildBadgeItem(String name) {
    return SizedBox( // 한 아이템의 너비를 고정
      width: 101,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 101,
            height: 100,
            clipBehavior: Clip.antiAlias,
            decoration: const BoxDecoration(color: Color(0xFFDDDDDD)),
          ),
          const SizedBox(height: 16),
          Text(
            name,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 14,
              fontFamily: 'Pretendard',
              fontWeight: FontWeight.w500,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}