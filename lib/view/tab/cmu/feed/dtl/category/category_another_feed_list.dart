import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_app/providers/api_feed_providers.dart';
import 'package:my_app/view/tab/cmu/feed/dtl/category/category_another_feed_item.dart';

class CategoryAnotherFeedList extends ConsumerStatefulWidget {
  const CategoryAnotherFeedList({super.key});

  @override
  ConsumerState<CategoryAnotherFeedList> createState() => _CategoryAnotherFeedListState();
}

class _CategoryAnotherFeedListState extends ConsumerState<CategoryAnotherFeedList> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(() {
      // 현재 스크롤 위치가 maxScrollExtent(맨 우측) 근처에 도달하면
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
        // 다음 페이지 호출
        final params = ref.read(feedParamsProvider2);
        ref.read(sameCategoryFeedPaginationProvider(params).notifier).fetchNext();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final feedCategoryId = ref.watch(feedMainChangeNotifierProvider.select((notifier) => notifier.categoryId));
    final feedCategoryNm = ref.watch(feedMainChangeNotifierProvider.select((notifier) => notifier.categoryNm));

    final params = ref.watch(feedParamsProvider2);
    params.categoryId = feedCategoryId;

    final feedState = ref.watch(sameCategoryFeedPaginationProvider(params));

    return SliverToBoxAdapter(
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
            decoration: const BoxDecoration(color: Color(0xFFF5F5F5)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: feedCategoryNm,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const TextSpan(
                        text: '의 다른 글',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
                const Text(
                  '전체보기',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 260, // 아이템 높이 + padding 고려
            child: feedState.when(
              data: (data) {
                final items = data.items;
                return ListView.builder(
                  controller: _scrollController,
                  scrollDirection: Axis.horizontal,
                  itemCount: items.length + (data.hasNext ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index < items.length) {
                      return Padding(
                        padding: const EdgeInsets.only(left: 20, bottom: 20),
                        child: CategoryAnotherFeedItem(feed: items[index]),
                      );
                    } else {
                      // 로딩 인디케이터 표시
                      return const Padding(
                        padding: EdgeInsets.all(20),
                        child: SizedBox(
                          width: 50,
                          height: 50,
                          child: Center(child: CircularProgressIndicator()),
                        ),
                      );
                    }
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stackTrace) => Center(child: Text('오류: $error')),
            ),
          ),
        ],
      ),
    );
  }
}
