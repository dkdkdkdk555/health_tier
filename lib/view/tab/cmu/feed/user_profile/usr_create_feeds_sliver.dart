import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_app/model/cmu/feed/usrs_feed_list_request.dart';
import 'package:my_app/providers/feed_providers.dart';
import 'package:my_app/view/tab/cmu/feed/user_profile/usr_create_feed_item.dart';

class UsrCreateFeedsSliver extends ConsumerStatefulWidget {
  final int userId;
  const UsrCreateFeedsSliver({
    super.key,
    required this.userId,
  });

  @override
  ConsumerState<UsrCreateFeedsSliver> createState() => _UsrCreateFeedsSliverState();
}

class _UsrCreateFeedsSliverState extends ConsumerState<UsrCreateFeedsSliver> {
  final ScrollController _scrollController = ScrollController();
  
  late final UsrsFeedQueryParams _initialParams; // 초기 쿼리 파라미터

  @override
  void initState() {
    super.initState();
    _initialParams = UsrsFeedQueryParams(userId: widget.userId);

    // initState에서 바로 fetchInitial 호출
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(userCreateFeedsProvider(_initialParams).notifier).fetchInitial();
    });

    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    // 스크롤 위치가 맨 아래에서 200px 이내에 도달하면 다음 페이지 로드
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      final notifier = ref.read(userCreateFeedsProvider(_initialParams).notifier);
      notifier.fetchNext();
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final asyncFeeds = ref.watch(userCreateFeedsProvider(_initialParams));

    return SliverMainAxisGroup( // `SliverMainAxisGroup`을 사용하여 여러 슬리버를 그룹화
      slivers: [
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, // 왼쪽 정렬
            children: [
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                child: const Text(
                  '작성한 글',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontFamily: 'Pretendard',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Container(
                  height: 2,
                  decoration: const BoxDecoration(color: Color(0xFFEEEEEE)),
              ),
            ],
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
                      '작성한 글이 없습니다.',
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
                        padding: const EdgeInsets.symmetric(horizontal: 20), // 아이템 좌우 패딩
                        child: UsrCreateFeedItem(feed: items[index]), // 분리한 위젯 사용
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
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
              },
            );
          },
          loading: () => const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 50.0), // 로딩 인디케이터 중앙 정렬
              child: Center(child: CircularProgressIndicator()),
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