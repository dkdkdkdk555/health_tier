import 'package:flutter/material.dart';
import 'package:my_app/view/tab/cmu/feed/dtl/category/category_another_feed_list.dart';
import 'package:my_app/view/tab/cmu/feed/dtl/feed_detail_app_bar_delegate.dart';
import 'package:my_app/view/tab/cmu/feed/dtl/feed_detail_main.dart';
import 'package:my_app/view/tab/cmu/feed/dtl/reply/reply_list_sliver.dart';
import 'package:my_app/view/tab/cmu/feed/dtl/reply_bottom_bar.dart';
import 'package:my_app/view/tab/cmu/feed/item/top_blank_area.dart';

class FeedDetail extends StatefulWidget { // StatefulWidget으로 변경
  final int feedId;
  final int categoryId;
  final bool isFromWriteFeed;
  const FeedDetail(
    {
    super.key,
    required this.feedId,
    required this.categoryId,
    this.isFromWriteFeed = false,
    }
  );

  @override
  State<FeedDetail> createState() => _FeedDetailState();
}

class _FeedDetailState extends State<FeedDetail> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose(); // 컨트롤러 해제
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.white,
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus(); // 포커스 해제 → 키보드 및 바 숨김
        },
        behavior: HitTestBehavior.opaque, // 빈 공간도 인식하게 함
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            // 상단바 위 여백
            const TopBlankArea(),
            // 상단 앱바
            SliverPersistentHeader(
              pinned: true,
              delegate: FeedDetailAppBarDelegate(widget.isFromWriteFeed, widget.feedId),
            ),
            // 게시글 본문
            SliverToBoxAdapter(
              child: FeedDetailMain(feedId: widget.feedId),
            ),
            // 댓글리스트
            ReplyListSliver(cmuId: widget.feedId),
            // 같은 카테고리의 다른 글
            CategoryAnotherFeedList(categoryId: widget.categoryId,),
        
            // 하단 여백(필요시)
            const SliverToBoxAdapter(
              child: SizedBox(height: 20),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const ReplyBottomBar(),
    );
  }
}