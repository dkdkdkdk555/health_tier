import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_app/providers/api_feed_providers.dart';
import 'package:my_app/view/tab/cmu/feed/dtl/reply/reply.dart';

class ReplyListSliver extends ConsumerWidget {
  final int cmuId;
  const ReplyListSliver({super.key, required this.cmuId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repliesAsync = ref.watch(replyPaginationProvider(cmuId));

    return repliesAsync.when(
      loading: () => const SliverToBoxAdapter(
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (err, stack) => SliverToBoxAdapter(
        child: Center(child: Text('댓글 로딩 실패: $err')),
      ),
      data: (scrollResponse) {
        final replies = scrollResponse.items;
        return SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final reply = replies[index];
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Reply(reply: reply, isChild: false,), // 댓글 위젯

                  // 대댓글(children) 렌더링
                  if (reply.children.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(left: 16.0),
                      child: Column(
                        children: reply.children.map((childReply) {
                          return Reply(reply: childReply, isChild: true);
                        }).toList(),
                      ),
                    ),
                ],
              );
            },
            childCount: replies.length,
          ),
        );
      },
    );
  }
}
