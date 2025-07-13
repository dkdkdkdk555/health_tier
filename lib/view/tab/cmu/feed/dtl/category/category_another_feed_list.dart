import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:my_app/model/cmu/feed/feed_list_request.dart';
import 'package:my_app/providers/api_feed_providers.dart';
import 'package:my_app/view/tab/cmu/feed/dtl/category/category_another_feed_item.dart';

class CategoryAnotherFeedList extends ConsumerStatefulWidget {
  final int categoryId;

  const CategoryAnotherFeedList({
    super.key,
    required this.categoryId,
  });

  @override
  ConsumerState<CategoryAnotherFeedList> createState() => _CategoryAnotherFeedListState();
}

class _CategoryAnotherFeedListState extends ConsumerState<CategoryAnotherFeedList> {
  final ScrollController _scrollController = ScrollController();

  late final FeedQueryParams _initialParams;

  @override
  void initState() {
    super.initState();

    _initialParams = FeedQueryParams(categoryId: widget.categoryId);

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
        ref.read(sameCategoryFeedPaginationProvider(_initialParams).notifier).fetchNext();
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
    final feedCategoryNm = ref.watch(feedMainChangeNotifierProvider.select((notifier) => notifier.categoryNm));

    final feedState = ref.watch(sameCategoryFeedPaginationProvider(_initialParams));

    return SliverToBoxAdapter(
      child: Column(
        children: [
          Container(
            width: 375,
            padding: const EdgeInsets.only(
                top: 20,
                left: 20,
                right: 20,
                bottom: 12,
            ),
            decoration: const BoxDecoration(color: Color(0xFFF5F5F5)),
            child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 12,
                children: [
                    SizedBox(
                        width: 335,
                        child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            spacing: 8,
                            children: [
                                Text.rich(
                                    TextSpan(
                                        children: [
                                            TextSpan(
                                                text: feedCategoryNm,
                                                style: const TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 14,
                                                    fontFamily: 'Pretendard',
                                                    fontWeight: FontWeight.w700,
                                                    height: 1.50,
                                                ),
                                            ),
                                            const TextSpan(
                                                text: '의 다른 글',
                                                style: TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 14,
                                                    fontFamily: 'Pretendard',
                                                    fontWeight: FontWeight.w400,
                                                    height: 1.50,
                                                ),
                                            ),
                                        ],
                                    ),
                                ),
                                Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    spacing: 4,
                                    children: [
                                        const Text(
                                            '전체보기',
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 12,
                                                fontFamily: 'Pretendard',
                                                fontWeight: FontWeight.w400,
                                                height: 1.50,
                                            ),
                                        ),
                                        Container(
                                            width: 16,
                                            height: 16,
                                            clipBehavior: Clip.antiAlias,
                                            decoration: const BoxDecoration(),
                                            child: IconButton(
                                              icon: SvgPicture.asset('assets/icons/ico_right.svg'),
                                              onPressed: (){
                                                
                                              },
                                              padding: EdgeInsets.zero,
                                            ),
                                        ),
                                    ],
                                ),
                            ],
                        ),
                    ),
                ],
            ),
        ),
          Container(
            padding: const EdgeInsets.only(left:20),
            decoration: const BoxDecoration(
              color: Color(0xFFF5F5F5)
            ),
            child: SizedBox(
              height: 192,
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
                          padding: const EdgeInsets.only(right: 10, bottom: 20),
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
                error: (error, stackTrace) {
                  debugPrint('$error');
                  debugPrint('$stackTrace');
                  return null;
                }
              ),
            ),
          ),
        ],
      ),
    );
  }
}
