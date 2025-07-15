import 'package:flutter/material.dart';
import 'package:my_app/view/tab/cmu/feed/user_profile/usr_profile_app_bar.dart';

class SrchAppBarDelegate extends SliverPersistentHeaderDelegate {
  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return const UsrProfileAppBar();
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