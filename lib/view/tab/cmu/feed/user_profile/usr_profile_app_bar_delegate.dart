import 'package:flutter/material.dart';
import 'package:my_app/view/tab/cmu/feed/item/cmu_basic_app_bar.dart';

class UsrProfileAppBarDelegate extends SliverPersistentHeaderDelegate {
  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return const CmuBasicAppBar(centerText: '이용자 프로필',);
  }

  @override
  double get maxExtent => 44;

  @override
  double get minExtent => 44;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return false;
  }

}