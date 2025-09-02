import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_app/providers/feed_providers.dart';
import 'package:my_app/util/spinner_utils.dart' show AppLoadingIndicator;
import 'package:my_app/view/common/error_widget.dart' show ErrorContentWidget;
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
        // 새피드 불러오기 기능때문에 저장하는건데 카테고리 + 지금뜨는 누르면 여기서 feeds null이라고 오류남 -> 지금 뜨는 게시글 조건이 바뀌어서그런가? 불러와지는게 0임
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
      error:(error, stackTrace) {
        return const SliverToBoxAdapter(
          child: ErrorContentWidget(
            mainText: '피드를 불러오던 중 오류가 발생했습니다.\n 네트워크 연결상태를 확인하세요.',
            horizontal: 40,
            vertical: 60,
          ),
        );
      },
    );
  }
}
