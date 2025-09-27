import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:my_app/model/cmu/feed/feed_list_request.dart';
import 'package:my_app/providers/feed_providers.dart' show feedPaginationProvider, feedParamsProvider, replyPaginationProvider, sameCategoryFeedPaginationProvider, searchFeedsProvider;
import 'package:my_app/service/feed_cud_api_service.dart' show FeedCudService;
import 'package:my_app/util/dialog_utils.dart' show showAppDialog;
import 'package:my_app/util/screen_ratio.dart';
import 'package:my_app/view/tab/cmu/feed/dtl/category/category_another_feed_list.dart';
import 'package:my_app/view/tab/cmu/feed/dtl/feed_detail_app_bar_delegate.dart';
import 'package:my_app/view/tab/cmu/feed/dtl/feed_detail_main.dart';
import 'package:my_app/view/tab/cmu/feed/dtl/reply/reply_list_sliver.dart';
import 'package:my_app/view/tab/cmu/feed/dtl/reply_bottom_bar.dart';
import 'package:my_app/view/tab/cmu/feed/item/top_blank_area.dart';

class FeedDetail extends ConsumerStatefulWidget { // StatefulWidget으로 변경
  final int feedId;
  final int? categoryId;
  final bool isFromWriteFeed;
  final bool isFromNotifi;
  const FeedDetail(
    {
    super.key,
    required this.feedId,
    this.categoryId,
    this.isFromWriteFeed = false,
    this.isFromNotifi = false,
    }
  );

  @override
  ConsumerState<FeedDetail> createState() => _FeedDetailState();
}

class _FeedDetailState extends ConsumerState<FeedDetail> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose(); // 컨트롤러 해제
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    if(widget.isFromNotifi) {
      // initState는 위젯이 처음 생성될 때 단 한 번만 호출됩니다.
      // 알림클릭해서 온 경우 댓글 캐시 무효
      Future.microtask(() => ref.invalidate(replyPaginationProvider));
    }
  }


  void _deleteFeedCallback(FeedCudService? feedCudService) async {
    await feedCudService!.deleteFeed(widget.feedId);
    if(!mounted)return;
    showAppDialog(context, message: '피드가 삭제 되었습니다.', confirmText: '확인', onConfirm: () {
      ref.read(feedPaginationProvider(ref.read(feedParamsProvider)).notifier).removeFeed(widget.feedId);
      ref.invalidate(searchFeedsProvider);
      ref.invalidate(sameCategoryFeedPaginationProvider);
      context.pop();
    },);
  }

  @override
  Widget build(BuildContext context) {

    final htio = ScreenRatio(context).heightRatio;
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
              delegate: FeedDetailAppBarDelegate(widget.isFromWriteFeed, widget.feedId, _deleteFeedCallback),
            ),
            // 게시글 본문
            SliverToBoxAdapter(
              child: FeedDetailMain(feedId: widget.feedId),
            ),
            // 댓글리스트
            ReplyListSliver(cmuId: widget.feedId, scrollController: _scrollController,),
            // 같은 카테고리의 다른 글
            widget.categoryId != null ? CategoryAnotherFeedList(categoryId: widget.categoryId!, currentFeedId: widget.feedId) 
            : const SliverToBoxAdapter(child: SizedBox.shrink()),
            // 하단 여백(필요시)
            SliverToBoxAdapter(
              child: SizedBox(height: 128 * htio),
            ),
          ],
        ),
      ),
      bottomNavigationBar: ReplyBottomBar(cmuId: widget.feedId,),
    );
  }
}