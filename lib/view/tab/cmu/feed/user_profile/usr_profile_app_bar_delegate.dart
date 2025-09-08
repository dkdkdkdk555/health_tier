import 'package:flutter/material.dart';
import 'package:my_app/view/tab/cmu/feed/item/cmu_basic_app_bar.dart';

class UsrProfileAppBarDelegate extends SliverPersistentHeaderDelegate {
  final double htio;
  
  UsrProfileAppBarDelegate(this.htio);

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return const CmuBasicAppBar(centerText: '이용자 프로필');
  }

  @override
  double get maxExtent => 48 * htio;

  @override
  double get minExtent => 48 * htio;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return false;
  }
}