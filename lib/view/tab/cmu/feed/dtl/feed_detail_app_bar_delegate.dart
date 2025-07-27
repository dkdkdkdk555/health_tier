import 'package:flutter/material.dart';
import 'package:my_app/view/tab/cmu/feed/dtl/feed_detail_app_bar.dart';

class FeedDetailAppBarDelegate extends SliverPersistentHeaderDelegate {
  bool isFromWriteFeed;
  final int feedId;
  FeedDetailAppBarDelegate(
    this.isFromWriteFeed,
    this.feedId
  );

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return FeedDetailAppBar(
      isFromWriteFeed: isFromWriteFeed,
      feedId: feedId,
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