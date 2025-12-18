import 'package:flutter/material.dart';
import 'package:my_app/util/screen_ratio.dart' show ScreenRatio;

/// 앱 전역에서 공통으로 사용하는 로딩 인디케이터
class AppLoadingIndicator extends StatelessWidget {
  const AppLoadingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    final wtio = ScreenRatio(context).widthRatio;
    return CircularProgressIndicator(
      strokeWidth: 3*wtio,
      valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF0D86E7)), // 원하는 색상 지정
    );
  }
}