import 'package:flutter/material.dart';
import 'package:my_app/view/tab/usr/block/block_manage_app_bar.dart';

class BlockManageAppBarDelegatte extends SliverPersistentHeaderDelegate {
  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return const BlockManageAppBar(centerText: '차단사용자 관리',);
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