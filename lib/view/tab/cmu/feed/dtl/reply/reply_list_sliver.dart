import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_app/model/cmu/feed/reply_response.dart';
import 'package:my_app/notifier/reply_pagination_notifier.dart';
import 'package:my_app/providers/feed_providers.dart';
import 'package:my_app/view/tab/cmu/feed/dtl/reply/reply.dart';

class ReplyListSliver extends ConsumerWidget {
  final int cmuId;
  const ReplyListSliver({super.key, required this.cmuId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repliesAsync = ref.watch(replyPaginationProvider(cmuId));
    final replyNotifier = ref.read(replyPaginationProvider(cmuId).notifier);

    // `repliesAsync.isLoading`은 초기 로딩 또는 fetchNext에서 state가 AsyncValue.loading()으로 바뀔 때만 true
    final bool isInitialLoading = repliesAsync.isLoading && !repliesAsync.hasValue;

    // _buildSliverContent에 isFetchingNext를 전달하지 않음
    return repliesAsync.when(
      loading: () {
        // 초기 로딩 중이고, 아직 데이터가 없을 때만 전체 로딩 인디케이터 표시
        if (isInitialLoading) {
          return const SliverToBoxAdapter(
            child: Center(child: CircularProgressIndicator()),
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
                Reply(reply: reply, isChild: false, cmuId: cmuId,),

                if (reply.children.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(left: 16.0),
                    child: Column(
                      children: reply.children.map((childReply) {
                        return Reply(reply: childReply, isChild: true, cmuId: cmuId,);
                      }).toList(),
                    ),
                  ),
              ],
            );
          }),

          if (hasNext)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Center(
                child: GestureDetector(
                  onTap: () {
                    // `fetchNext` 호출. 이 호출이 상태를 `AsyncValue.data`로 유지하면서
                    // 아이템만 추가하면 스크롤 위치가 유지됩니다.
                    // 만약 `fetchNext`가 `AsyncValue.loading()`으로 전환된다면 스크롤이 튀고,
                    // 이 버튼 자리에 로딩 인디케이터를 보여주려면 외부 플래그가 필요합니다.
                    replyNotifier.fetchNext();
                  },
                  child: Container(
                      padding: const EdgeInsets.only(
                          top: 16,
                          left: 20,
                          right: 20,
                          bottom: 40,
                      ),
                      child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                              Expanded(
                                  child: Container(
                                      height: 43,
                                      decoration: ShapeDecoration(
                                          color: const Color(0xFFE8ECF2),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                      ),
                                      child: const Row(
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          spacing: 10,
                                          children: [
                                              Text(
                                                  '댓글 더보기',
                                                  style: TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 14,
                                                      fontFamily: 'Pretendard',
                                                      fontWeight: FontWeight.w700,
                                                      height: 1.50,
                                                  ),
                                              ),
                                          ],
                                      ),
                                  ),
                              ),
                          ],
                      ),
                  )
                ),
              ),
            ),
        ],
      ),
    );
  }
}