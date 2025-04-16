import 'package:flutter/material.dart';

extension ScreenRatio on BuildContext {
  double get widthRatio => MediaQuery.of(this).size.width / 375.0;
  double get heightRatio => MediaQuery.of(this).size.height / 812.0;
}
