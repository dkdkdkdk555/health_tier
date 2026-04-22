import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

class ScreenRatio {
  final BuildContext context;
  late final double widthRatio;
  late final double heightRatio;

  static const double baseWidth = 375.0; // 기준 기기 가로 (iPhone X 등)
  static const double baseHeight = 812.0; // 기준 기기 세로

  ScreenRatio(this.context) {
    final screenSize = MediaQuery.of(context).size;
    heightRatio = screenSize.height / baseHeight;
    widthRatio = kIsWeb ? heightRatio : screenSize.width / baseWidth;
  }
}
