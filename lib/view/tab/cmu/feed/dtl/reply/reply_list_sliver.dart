import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_app/model/cmu/feed/reply_response.dart';
import 'package:my_app/notifier/reply_pagination_notifier.dart';
import 'package:my_app/providers/feed_providers.dart';
import 'package:my_app/util/spinner_utils.dart' show AppLoadingIndicator;
import 'package:my_app/view/tab/cmu/feed/dtl/reply/reply.dart';

class ReplyListSliver extends ConsumerStatefulWidget {
  final int cmuId;
  final ScrollController scrollController; // <-- scrollController를 전달받도록 수정

  const ReplyListSliver({
    super.key,
    required this.cmuId,
    required this.scrollController, // <-- 생성자에 추가
  });

  @override
  ConsumerState<ReplyListSliver> createState() => _ReplyListSliverState();
}

class _ReplyListSliverState extends ConsumerState<ReplyListSliver> {
  @override
  void initState() {
    super.initState();
    // 부모로부터 받은 컨트롤러에 리스너 등록
    widget.scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    // 위젯이 제거될 때 리스너 해제 (컨트롤러 자체는 부모 위젯에서 해제)
    widget.scrollController.removeListener(_onScroll);
    super.dispose();
  }

  void _onScroll() {
    final replyNotifier = ref.read(replyPaginationProvider(widget.cmuId).notifier);
    final repliesState = ref.read(replyPaginationProvider(widget.cmuId));
    
    // 다음 페이지가 있고, 스크롤 위치가 맨 아래에 근접했을 때 (200px 남았을 때)
    if (repliesState.asData?.value.hasNext == true && widget.scrollController.position.extentAfter < 200) {
      // `fetchNext`가 현재 로딩 중이 아니라면 호출
      if (!repliesState.isLoading) {
        replyNotifier.fetchNext();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final repliesAsync = ref.watch(replyPaginationProvider(widget.cmuId));
    final replyNotifier = ref.read(replyPaginationProvider(widget.cmuId).notifier);

    // `repliesAsync.isLoading`은 초기 로딩 또는 fetchNext에서 state가 AsyncValue.loading()으로 바뀔 때만 true
    final bool isInitialLoading = repliesAsync.isLoading && !repliesAsync.hasValue;

    // _buildSliverContent에 isFetchingNext를 전달하지 않음
    return repliesAsync.when(
      loading: () {
        // 초기 로딩 중이고, 아직 데이터가 없을 때만 전체 로딩 인디케이터 표시
        if (isInitialLoading) {
          return const SliverToBoxAdapter(
            child: Center(child: AppLoadingIndicator()),
          );
        }
        // 이미 데이터가 있다면, 기존 데이터 표시
        final currentData = repliesAsync.asData!.value;
        return _buildSliverContent(context, currentData.items, currentData.hasNext, replyNotifier);
      },
      error: (err, stack) => SliverToBoxAdapter(
        child: Center(child: Text('댓글 로딩 실패: $err')),
      ),
      data: (scrollResponse) {
        final replies = scrollResponse.items;
        final hasNext = scrollResponse.hasNext;
        final int? cursorId = replyNotifier.cursorId;

        if (replies.isEmpty && cursorId == null) {
          return SliverToBoxAdapter(
            child: Column(
              children: [
                Container(
                  height: 2.5,
                  decoration: const BoxDecoration(color: Color(0xFFF5F5F5)),
                ),
                const Padding(
                  padding: EdgeInsets.only(top: 70.0, bottom: 85,  right: 20, left: 20),
                  child: Center(
                    child: Text(
                      '아직 댓글이 없습니다.\n 댓글을 입력해주세요.',
                      style: TextStyle(fontSize: 15, color: Colors.grey),
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        return _buildSliverContent(context, replies, hasNext, replyNotifier);
      },
    );
  }

  Widget _buildSliverContent(
      BuildContext context,
      List<ReplyResponseDto> replies,
      bool hasNext,
      ReplyPaginationNotifier replyNotifier,
      ) {
        
    return SliverList(
      delegate: SliverChildListDelegate(
        [
          ...replies.map((reply) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Reply(reply: reply, isChild: false, cmuId: widget.cmuId,),

                if (reply.children.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(left: 16.0),
                    child: Column(
                      children: reply.children.map((childReply) {
                        return Reply(reply: childReply, isChild: true, cmuId: widget.cmuId,);
                      }).toList(),
                    ),
                  ),
              ],
            );
          }),

          if (hasNext)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(
                child: AppLoadingIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}