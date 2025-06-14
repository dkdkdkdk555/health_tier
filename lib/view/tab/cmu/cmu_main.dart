import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_app/model/cmu/feed/feed_list_request.dart';
import 'package:my_app/notifier/feed_pagination_notifier.dart';
import 'package:my_app/providers/api_feed_providers.dart';
import 'package:my_app/view/tab/cmu/cmu_category_top_bar_delegate.dart';
import 'package:my_app/view/tab/simple_cache.dart' show cachedCmuTabIndex;
import 'package:my_app/view/tab/cmu/cmu_app_bar_delegate.dart';
import 'package:my_app/extension/screen_ratio_extension.dart';

class CmuMain extends ConsumerStatefulWidget {
  const CmuMain({super.key});

  @override
  ConsumerState<CmuMain> createState() => _CmuMainState();
}

 var htio = 0.0;

class _CmuMainState extends ConsumerState<CmuMain> {
  // 어느 하위 탭인지
  late int _selectedIndex;
  // 스크롤 상태관리
  late ScrollController _scrollController;
  bool _scrolledDown = false;
  // 카테고리바 펼쳐짐 여부
  bool isSpread = false;
  // 피드목록 조회조건
  FeedQueryParams params = FeedQueryParams(
    categoryId: null,
    hotYn: 'N',
    cursorId: null,
    limit: 10,
  );
  

  void toggleSpread() {
    setState(() {
      isSpread = !isSpread;
    });
  }

  @override
  void initState() {
    super.initState();
    _selectedIndex = cachedCmuTabIndex; // 캐시된 값 불러오기
    _scrollController = ScrollController();
    _scrollController.addListener(() {
      // f1 : 스크롤 방향 감지
      if (_scrollController.position.userScrollDirection == ScrollDirection.reverse) {
        // 아래로 스크롤 시작
        if (!_scrolledDown) {
          setState(() {
            _scrolledDown = true;
          });
        }
      } else if (_scrollController.position.userScrollDirection == ScrollDirection.forward) {
        // 위로 스크롤 시작
        if (_scrolledDown) {
          setState(() {
            _scrolledDown = false;
          });
        }
      }

      // f2 : 무한스크롤 감지
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 300) {
        // 거의 바닥 근처까지 스크롤됐을 때 다음 페이지 로드
        ref.read(feedPaginationProvider(params).notifier).fetchNext();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onTap(int index) {
    setState(() {
      _selectedIndex = index;
      cachedCmuTabIndex = index; // 캐싱
    });
  }

  @override
  Widget build(BuildContext context) {
    htio = ScreenRatio(context).heightRatio;
    
    final scrollResponse = ref.watch(feedPaginationProvider(params)); // 이때 fetchInitial 이 내부적으로 최초 실행됨

    return scrollResponse.when(
      data : (scrollData) {
        final feeds = scrollData.feeds;
        params.cursorId = scrollData.lastCursorId;

        return Container(
          color: Colors.white,
          child: CustomScrollView( 
            controller: _scrollController,
            slivers: [
              // 상단바 접혔을때 생기는 여백
              SliverAppBar(
                pinned: true,
                primary: false,
                toolbarHeight: 44,
                flexibleSpace: Container(
                  decoration: const BoxDecoration(color: Colors.white),
                )
              ),
              // 상단바
              SliverPersistentHeader(
                pinned: !_scrolledDown,
                delegate: CmuAppBarDelegate(
                  selectedIndex: _selectedIndex, 
                  onTap: _onTap, 
                  htio: htio,
                  isVisible: !_scrolledDown
                )
              ),
              // 카테고리바
              SliverPersistentHeader(
                pinned: true,
                delegate: CategoryTopBarDelegate(
                  htio: htio,
                  isSpread: isSpread,
                  onToggleSpread : toggleSpread,
                )
              ),

              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    // 마지막 인덱스엔 로딩 인디케이터
                    if (index == feeds.length) {
                      return scrollData.hasNext
                        ? const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: Center(child: CircularProgressIndicator()),
                          )
                        : const SizedBox.shrink();
                    }
                    return SizedBox(
                      height: 100,

                      child: Row(
                        children: [
                          Text(
                            feeds[index].title
                          ),
                          Text(
                            '${feeds[index].id}'
                          )
                        ]
                      ),
                    );
                  },
                  childCount: feeds.length + 1,
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) {
        debugPrintStack(stackTrace: stack);
        return Center(child: Text('에러 발생: $err'));
      }
    );
  }
}