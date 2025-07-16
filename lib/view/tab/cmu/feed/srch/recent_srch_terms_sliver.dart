import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_app/notifier/srch_keyword_notifier.dart';
import 'package:my_app/util/recent_search_shared_preferences.dart'; 

class RecentSearchTermsSliver extends ConsumerStatefulWidget {
  const RecentSearchTermsSliver({super.key});

  @override
  ConsumerState<RecentSearchTermsSliver> createState() => _RecentSearchTermsSliverState();
}

class _RecentSearchTermsSliverState extends ConsumerState<RecentSearchTermsSliver> {
  List<String> _recentSearches = []; // 초기값을 빈 리스트로 변경

  @override
  void initState() {
    super.initState();
    _loadRecentSearches(); // 위젯 초기화 시 최근 검색어 불러오기
  }

  // 최근 검색어 불러오는 비동기 메서드
  Future<void> _loadRecentSearches() async {
    final searches = await RecentSearchesManager.loadRecentSearches();
    setState(() {
      _recentSearches = searches;
    });
  }

  // 특정 검색어 삭제
  void _removeSearchTerm(String term) async {
    await RecentSearchesManager.removeSearchKeyword(term); // shared_preferences에서 삭제
    await _loadRecentSearches(); // 목록 다시 불러와 UI 업데이트
    debugPrint('개별 검색어 삭제: $term');
  }

  // 전체 검색어 삭제
  void _clearAllSearches() async {
    await RecentSearchesManager.clearAllSearches(); // shared_preferences에서 전체 삭제
    await _loadRecentSearches(); // 목록 다시 불러와 UI 업데이트
    debugPrint('최근 검색어 전체 삭제');
  }

  // 검색어 클릭 시 동작
  void _onSearchTermTap(String term) {
    debugPrint('검색어 클릭: $term');
    // srchKeywordProvider 업데이트 -> SrchAppBar의 TextField에 반영 및 검색 트리거
    ref.read(srchKeywordProvider.notifier).updateKeyword(term);

    // 검색어 클릭 후 키보드를 내리고 싶다면, SrchAppBar의 FocusNode를 제어해야 합니다.
    // 이는 SrchAppBar에서 FocusNode를 노출시키거나,
    // SrchKeywordNotifier에 FocusNode 제어 로직을 추가하는 방식으로 가능합니다.
    // 여기서는 단순히 검색어만 업데이트합니다.
  }

  @override
  Widget build(BuildContext context) {
    // srchKeywordProvider는 이 위젯에서 직접 watch할 필요는 없습니다.
    // _onSearchTermTap에서 read로 한 번만 값을 업데이트하기 때문입니다.

    return SliverMainAxisGroup(
      slivers: [
        // '최근검색' 타이틀 및 '전체 삭제' 헤더
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '최근 검색',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 14,
                    fontFamily: 'Pretendard',
                    fontWeight: FontWeight.w700,
                    height: 1.50,
                  ),
                ),
                GestureDetector(
                  onTap: _clearAllSearches,
                  child: const Text(
                    '전체 삭제',
                    style: TextStyle(
                      color: Color(0xFF777777),
                      fontSize: 12,
                      fontFamily: 'Pretendard',
                      fontWeight: FontWeight.w400,
                      height: 1.50,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // 최근 검색어 리스트
        if (_recentSearches.isEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
              child: Center(
                child: Text(
                  '최근 검색어가 없습니다.',
                  style: TextStyle(color: Colors.grey[500]),
                ),
              ),
            ),
          )
        else
          SliverList.builder(
            itemCount: _recentSearches.length,
            itemBuilder: (context, index) {
              final String searchTerm = _recentSearches[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Row(
                  children: [
                    // 시계 아이콘
                    const Icon(
                      Icons.access_time,
                      size: 16,
                      color: Color(0xFFBBBBBB), // Color를 const로 변경
                    ),
                    const SizedBox(width: 8),

                    // 검색어 텍스트
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _onSearchTermTap(searchTerm), // 검색어 클릭 시 _onSearchTermTap 호출
                        child: Text(
                          searchTerm,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                            fontFamily: 'Pretendard',
                            fontWeight: FontWeight.w400,
                            height: 1.50,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),

                    // X 버튼
                    GestureDetector(
                      onTap: () => _removeSearchTerm(searchTerm),
                      child: const Icon(
                        Icons.close,
                        size: 16,
                        color: Color(0xFFBBBBBB), // Color를 const로 변경
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
      ],
    );
  }
}