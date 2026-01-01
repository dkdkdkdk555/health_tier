import 'package:flutter/material.dart';
import 'package:my_app/view/tab/cmu/feed/dtl/feed_detail_app_bar.dart';

class FeedDetailAppBarDelegate extends SliverPersistentHeaderDelegate {
  bool isFromWriteFeed;
  final int feedId;
  final Function feedDeleteCallback;
  FeedDetailAppBarDelegate(
    this.isFromWriteFeed,
    this.feedId,
    this.feedDeleteCallback,
  );

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return FeedDetailAppBar(
      isFromWriteFeed: isFromWriteFeed,
      feedId: feedId,
      feedDeleteCallback: feedDeleteCallback,
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