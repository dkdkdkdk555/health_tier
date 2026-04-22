import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_app/notifier/srch_keyword_notifier.dart';
import 'package:my_app/providers/feed_providers.dart';
import 'package:my_app/util/screen_ratio.dart' show ScreenRatio;
import 'package:my_app/util/spinner_utils.dart' show AppLoadingIndicator;
import 'package:my_app/view/common/error_widget.dart';
import 'package:my_app/view/tab/cmu/feed/srch/srch_result_feed_item.dart';

class SrchResultListSliver extends ConsumerStatefulWidget {
  final ScrollController scrollController;
  const SrchResultListSliver({
    super.key,
    required this.scrollController
  });

  @override
  ConsumerState<SrchResultListSliver> createState() => _SrchResultListSliverState();
}

class _SrchResultListSliverState extends ConsumerState<SrchResultListSliver> {

  @override
  void initState() {
    super.initState();
    widget.scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (widget.scrollController.position.pixels >= widget.scrollController.position.maxScrollExtent - 200) {
      final keyword = ref.read(srchKeywordProvider);
      final notifier = ref.read(searchFeedsProvider(keyword).notifier);
      notifier.fetchNext();
    }
  }

  @override
  void dispose() {
    widget.scrollController.removeListener(_onScroll);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final keyword = ref.watch(srchKeywordProvider);
    final asyncFeeds = ref.watch(searchFeedsProvider(keyword));
    final htio = ScreenRatio(context).heightRatio;
    final wtio = ScreenRatio(context).widthRatio;

    return SliverMainAxisGroup( // `SliverMainAxisGroup`을 사용하여 여러 슬리버를 그룹화
      slivers: [
        SliverToBoxAdapter(
          child: Container(
              margin: EdgeInsets.only(top:14 * htio),
              height: 2 * htio,
              decoration: const BoxDecoration(color: Color(0xFFEEEEEE)),
          ),
        ),
        // 데이터 로딩 상태에 따라 다른 슬리버를 보여줌
        asyncFeeds.when(
          data: (data) {
            final items = data.items;
            if (items.isEmpty) {
              return SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20 * wtio, vertical: 20 * htio),
                  child: const Center(
                    child: Text(
                      '검색결과가 없습니다.',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                ),
              );
            }
            return SliverList.builder( // SliverList.builder 사용
              itemCount: items.length + (data.hasNext ? 1 : 0), // 다음 페이지가 있으면 1 추가
              itemBuilder: (context, index) {
                if (index < items.length) {
                  return Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20 * wtio),
                        child: SrchResultFeedItem(feed: items[index], searchKeyword: keyword,),
                      ),
                      Container(
                          height: 1 * htio,
                          decoration: const BoxDecoration(color: Color(0xFFEEEEEE)),
                      ),
                    ],
                  );
                } else {
                  // 다음 페이지 로딩 중
                  return Padding(
                    padding: EdgeInsets.symmetric(vertical: 20 * htio),
                    child: const Center(child: AppLoadingIndicator()),
                  );
                }
              },
            );
          },
          loading: () => SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 50.0 * htio), // 로딩 인디케이터 중앙 정렬
              child: const Center(child: AppLoadingIndicator()),
            ),
          ),
          error: (error, stackTrace) {
            debugPrint('Error fetching user feeds: $error');
            debugPrint('Stack trace: $stackTrace');
            return SliverToBoxAdapter(
              child: ErrorContentWidget(horizontal: 40 * wtio, vertical: 40 * htio,)
            );
          },
        ),
        // ListView.builder가 아니라 CustomScrollView 전체 스크롤을 관리하므로
        // 맨 아래 여백은 필요에 따라 추가합니다.
        SliverToBoxAdapter(
          child: SizedBox(height: 20 * htio),
        ),
      ],
    );
  }
}