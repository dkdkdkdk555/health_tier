import 'package:flutter/material.dart';
import 'package:my_app/view/tab/cmu/cmu_app_bar.dart';

class CmuAppBarDelegate extends SliverPersistentHeaderDelegate {
  final int selectedIndex;
  final ValueChanged<int> onTap;

  CmuAppBarDelegate({
    required this.selectedIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return CmuAppBar(
      selectedIndex: selectedIndex,
      onTap: onTap,
    );
  }

  @override
  double get maxExtent => 154; // CmuAppBar 높이에 맞게 조정 (예: 100)
  @override
  double get minExtent => 0; // 스크롤되면 완전히 사라짐

  @override
  bool shouldRebuild(covariant CmuAppBarDelegate oldDelegate) {
    return selectedIndex != oldDelegate.selectedIndex;
  }
}