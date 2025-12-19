import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_app/providers/feed_providers.dart';
import 'package:my_app/util/screen_ratio.dart';
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

    final ratio = ScreenRatio(context);
    final htio = ratio.heightRatio;
    final wtio = ratio.widthRatio;

    return scrollResponse.when(
      data: (scrollData) {
        final feeds = scrollData.items;

        if(feeds.isEmpty){
          return SliverToBoxAdapter(
            child: ErrorContentWidget(
              mainText: '해당 카테고리에 게시글이 없습니다.',
              horizontal: 40 * wtio,
              vertical: 60 * htio,
              isIconView: false,
            ),
          );
        }

        saveLatestIndex(index:feeds[0].id); 
        return SliverPadding(
          padding: EdgeInsets.only(bottom: 100 * htio),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                if (index == feeds.length) {
                  return scrollData.hasNext
                      ? Padding(
                          padding: EdgeInsets.symmetric(vertical: 16 * htio),
                          child: const Center(child: AppLoadingIndicator()),
                        )
                      : const SizedBox.shrink();
                }
                return CmuFeedItem(feed: feeds[index]);
              },
              childCount: feeds.length + 1,
            ),
          ),
        );
      },
      loading: () => const SliverToBoxAdapter(
        child: Center(child: AppLoadingIndicator()),
      ),
      error:(error, stackTrace) {
        return SliverToBoxAdapter(
          child: ErrorContentWidget(
            mainText: '피드를 불러오던 중 오류가 발생했습니다.\n 네트워크 연결상태를 확인하세요.',
            horizontal: 40 * wtio,
            vertical: 60 * htio,
          ),
        );
      },
    );
  }
}
