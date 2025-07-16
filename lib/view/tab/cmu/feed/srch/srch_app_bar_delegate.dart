import 'package:flutter/material.dart';
import 'package:my_app/view/tab/cmu/feed/srch/srch_app_bar.dart';

class SrchAppBarDelegate extends SliverPersistentHeaderDelegate {
  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return const SrchAppBar();
  }

  @override
  double get maxExtent => 48;

  @override
  double get minExtent => 48;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return false;
  }

}