import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_app/notifier/srch_keyword_notifier.dart';
import 'package:my_app/util/recent_search_shared_preferences.dart';
import 'package:my_app/util/screen_ratio.dart' show ScreenRatio;
import 'package:my_app/view/common/admob_ads.dart' show AdType, AdmobAds;

class RecentSearchTermsSliver extends ConsumerStatefulWidget {
  const RecentSearchTermsSliver({super.key});

  @override
  ConsumerState<RecentSearchTermsSliver> createState() => _RecentSearchTermsSliverState();
}

class _RecentSearchTermsSliverState extends ConsumerState<RecentSearchTermsSliver> {
  List<String> _recentSearches = [];

  @override
  void initState() {
    super.initState();
    _loadRecentSearches();
  }

  Future<void> _loadRecentSearches() async {
    final searches = await RecentSearchesManager.loadRecentSearches();
    setState(() {
      _recentSearches = searches;
    });
  }

  void _removeSearchTerm(String term) async {
    await RecentSearchesManager.removeSearchKeyword(term);
    await _loadRecentSearches();
    debugPrint('개별 검색어 삭제: $term');
  }

  void _clearAllSearches() async {
    await RecentSearchesManager.clearAllSearches();
    await _loadRecentSearches();
    debugPrint('최근 검색어 전체 삭제');
  }

  void _onSearchTermTap(String term) {
    debugPrint('검색어 클릭: $term');
    ref.read(srchKeywordProvider.notifier).updateKeyword(term);
    // 검색어 클릭 후 검색 바 포커스를 해제하려면:
    // FocusScope.of(context).unfocus(); // 이 코드는 이 위젯이 context에 접근할 수 있을 때만 유효
  }

  @override
  Widget build(BuildContext context) {
    final htio = ScreenRatio(context).heightRatio;
    final wtio = ScreenRatio(context).widthRatio;
    
    // ✅ 여기에서 SliverMainAxisGroup 대신 일반 Widget (Container)을 반환합니다.
    return Container(
      color: Colors.white, // 오버레이의 배경색을 흰색으로 설정
      child: Column( // Column은 RenderBox이므로 Stack의 자식이 될 수 있습니다.
        mainAxisSize: MainAxisSize.min, // 내부 컨텐츠에 맞춰 높이를 최소화
        children: [
          // '최근검색' 타이틀 및 '전체 삭제' 헤더
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20 * wtio, vertical: 12 * htio),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '최근 검색',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 14 * htio,
                    fontFamily: 'Pretendard',
                    fontWeight: FontWeight.w700,
                    height: 1.50 * htio,
                  ),
                ),
                GestureDetector(
                  onTap: _clearAllSearches,
                  child: Text(
                    '전체 삭제',
                    style: TextStyle(
                      color: const Color(0xFF777777),
                      fontSize: 12 * htio,
                      fontFamily: 'Pretendard',
                      fontWeight: FontWeight.w400,
                      height: 1.50 * htio,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 최근 검색어 리스트
          if (_recentSearches.isEmpty)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.0 * wtio, vertical: 20.0 * wtio),
              child: Center(
                child: Text(
                  '최근 검색어가 없습니다.',
                  style: TextStyle(color: Colors.grey[500]),
                ),
              ),
            )
          else
            // ✅ ListView.builder를 Column 내에서 사용하기 위해 Expanded로 감쌉니다.
            // 이렇게 해야 ListView가 Column 내에서 스크롤 가능한 높이를 가질 수 있습니다.
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.zero, // 기본 패딩 제거
                shrinkWrap: true, // 필요한 만큼만 공간 차지 (스크롤 가능하지만 실제 높이는 콘텐츠에 따라 결정)
                itemCount: _recentSearches.length,
                itemBuilder: (context, index) {
                  final String searchTerm = _recentSearches[index];
                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20 * wtio, vertical: 8 * htio),
                    child: Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 16 * htio,
                          color: const Color(0xFFBBBBBB),
                        ),
                        SizedBox(width: 8 * wtio),

                        Expanded(
                          child: GestureDetector(
                            onTap: () => _onSearchTermTap(searchTerm),
                            child: Text(
                              searchTerm,
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 14 * htio,
                                fontFamily: 'Pretendard',
                                fontWeight: FontWeight.w400,
                                height: 1.50 * htio,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),

                        GestureDetector(
                          onTap: () => _removeSearchTerm(searchTerm),
                          child: Icon(
                            Icons.close,
                            size: 16 * htio,
                            color: const Color(0xFFBBBBBB),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            // 배너광고
          if (!kIsWeb)
            const AdmobAds(adType: AdType.banner,),
        ],
      ),
    );
  }
}