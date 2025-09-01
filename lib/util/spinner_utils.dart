import 'package:flutter/material.dart';

/// 앱 전역에서 공통으로 사용하는 로딩 인디케이터
class AppLoadingIndicator extends StatelessWidget {
  const AppLoadingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return const CircularProgressIndicator(
      strokeWidth: 3,
      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0D86E7)), // 원하는 색상 지정
    );
  }
}