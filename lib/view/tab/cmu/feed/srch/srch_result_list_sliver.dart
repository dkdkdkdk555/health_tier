import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_app/notifier/srch_keyword_notifier.dart';
import 'package:my_app/providers/feed_providers.dart';
import 'package:my_app/util/spinner_utils.dart' show AppLoadingIndicator;
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

    return SliverMainAxisGroup( // `SliverMainAxisGroup`을 사용하여 여러 슬리버를 그룹화
      slivers: [
        SliverToBoxAdapter(
          child: Container(
              margin: const EdgeInsets.only(top:14),
              height: 2,
              decoration: const BoxDecoration(color: Color(0xFFEEEEEE)),
          ),
        ),
        // 데이터 로딩 상태에 따라 다른 슬리버를 보여줌
        asyncFeeds.when(
          data: (data) {
            final items = data.items;
            if (items.isEmpty) {
              return const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Center(
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
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: SrchResultFeedItem(feed: items[index], searchKeyword: keyword,),
                      ),
                      Container(
                          height: 1,
                          decoration: const BoxDecoration(color: Color(0xFFEEEEEE)),
                      ),
                    ],
                  );
                } else {
                  // 다음 페이지 로딩 중
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20.0),
                    child: Center(child: AppLoadingIndicator()),
                  );
                }
              },
            );
          },
          loading: () => const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 50.0), // 로딩 인디케이터 중앙 정렬
              child: Center(child: AppLoadingIndicator()),
            ),
          ),
          error: (error, stackTrace) {
            debugPrint('Error fetching user feeds: $error');
            debugPrint('Stack trace: $stackTrace');
            return SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Center(child: Text('데이터 로딩 중 오류가 발생했습니다: $error')),
              ),
            );
          },
        ),
        // ListView.builder가 아니라 CustomScrollView 전체 스크롤을 관리하므로
        // 맨 아래 여백은 필요에 따라 추가합니다.
        const SliverToBoxAdapter(
          child: SizedBox(height: 20),
        ),
      ],
    );
  }
}