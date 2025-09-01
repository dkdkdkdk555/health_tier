import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_app/providers/feed_providers.dart';
import 'package:my_app/util/spinner_utils.dart' show AppLoadingIndicator;
import 'package:my_app/view/tab/cmu/feed/list/cmu_feed_item.dart';

class FeedListSliver extends ConsumerWidget {
  final void Function({required int index}) saveLatestIndex;
  const FeedListSliver({super.key
    , required this.saveLatestIndex,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final params = ref.watch(feedParamsProvider); // 외부에서 파라미터 관리 중이라면
    final scrollResponse = ref.watch(feedPaginationProvider(params));

    return scrollResponse.when(
      data: (scrollData) {
        final feeds = scrollData.items;
        saveLatestIndex(index:feeds[0].id);
        return SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              if (index == feeds.length) {
                return scrollData.hasNext
                    ? const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Center(child: AppLoadingIndicator()),
                      )
                    : const SizedBox.shrink();
              }
              return CmuFeedItem(feed: feeds[index]);
            },
            childCount: feeds.length + 1,
          ),
        );
      },
      loading: () => const SliverToBoxAdapter(
        child: Center(child: AppLoadingIndicator()),
      ),
      error: (err, stack) => SliverToBoxAdapter(
        child: Center(child: Text('에러 발생: $err')),
      ),
    );
  }
}
