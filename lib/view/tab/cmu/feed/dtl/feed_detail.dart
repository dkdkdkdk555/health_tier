import 'package:flutter/material.dart';
import 'package:my_app/view/tab/cmu/feed/dtl/feed_detail_app_bar_delegate.dart';
import 'package:my_app/view/tab/cmu/feed/dtl/feed_detail_main.dart';
import 'package:my_app/view/tab/cmu/feed/dtl/reply/reply.dart';
import 'package:my_app/view/tab/cmu/feed/dtl/reply/reply_list_sliver.dart';
import 'package:my_app/view/tab/cmu/feed/dtl/reply_bottom_bar.dart';

class FeedDetail extends StatelessWidget {
  final int feedId;
  const FeedDetail({
    super.key,
    required this.feedId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          // 상단바 위 여백
          SliverAppBar(
            pinned: true,
            primary: false,
            toolbarHeight: 44,
            automaticallyImplyLeading: false,
            flexibleSpace: Container(
              decoration: const BoxDecoration(color: Colors.white),
            )
          ),
          // 상단 앱바
          SliverPersistentHeader(
            pinned: true,
            delegate: FeedDetailAppBarDelegate(),
          ),

          // 🔷 게시글 본문
          SliverToBoxAdapter(
            child: FeedDetailMain(feedId: feedId),
          ),

          // 🔷 댓글 리스트
          ReplyListSliver(cmuId: feedId),

          // 🔷 하단 여백 (필요시)
          const SliverToBoxAdapter(
            child: SizedBox(height: 20),
          ),
        ],
      ),
      bottomNavigationBar: const ReplyBottomBar(),
    );
  }
}
