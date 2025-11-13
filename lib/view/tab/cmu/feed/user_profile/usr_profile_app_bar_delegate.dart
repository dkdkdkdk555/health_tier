import 'package:flutter/material.dart';
import 'package:my_app/view/tab/cmu/feed/item/cmu_usr_detail_app_bar.dart' show CmuUsrDetailAppBar;

class UsrProfileAppBarDelegate extends SliverPersistentHeaderDelegate {
  final double htio;
  final int userId;
  
  UsrProfileAppBarDelegate(this.htio, this.userId);

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return CmuUsrDetailAppBar(centerText: '이용자 프로필', userId: userId,);
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