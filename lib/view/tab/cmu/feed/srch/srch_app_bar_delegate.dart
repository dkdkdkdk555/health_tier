import 'package:flutter/material.dart';
import 'package:my_app/util/screen_ratio.dart' show ScreenRatio;
import 'package:my_app/view/tab/cmu/feed/srch/srch_app_bar.dart';

class SrchAppBarDelegate extends SliverPersistentHeaderDelegate {
  final bool focusSearchArea;
  final VoidCallback clickBackBtn;
  final double htio;

  SrchAppBarDelegate({
    required this.focusSearchArea,
    required this.clickBackBtn,
    required this.htio
  });

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return SrchAppBar(
      focusSearchArea: focusSearchArea,
      searchAreaControll: clickBackBtn,
    );
  }

  @override
  double get maxExtent => 48 * htio;

  @override
  double get minExtent => 48 * htio;

  @override
  bool shouldRebuild(covariant SrchAppBarDelegate oldDelegate) {
   // return false;  shouldRebuild가 false로 되어있으면 프로퍼티가 바뀌어도 자식 위젯을 다시 빌드하지 않는다.
   return focusSearchArea != oldDelegate.focusSearchArea;
  }

}