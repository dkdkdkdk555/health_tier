import 'package:flutter/material.dart';
import 'package:my_app/view/tab/cmu/feed/dtl/feed_detail_app_bar.dart';

class FeedDetailAppBarDelegate extends SliverPersistentHeaderDelegate {
  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return const FeedDetailAppBar(
    );
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