import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart'; // SVG 아이콘 사용시 필요

class RecentSearchTermsSliver extends StatefulWidget {
  const RecentSearchTermsSliver({super.key});

  @override
  State<RecentSearchTermsSliver> createState() => _RecentSearchTermsSliverState();
}

class _RecentSearchTermsSliverState extends State<RecentSearchTermsSliver> {
  // 하드코딩된 예시 최근 검색어 목록
  List<String> _recentSearches = [
    'ㅇㅇ', '햄스터', '너였다면', '러브', '태닝', '태닝로션', '알바', '웡세', 'lg그램',
  ];

  // 특정 검색어 삭제
  void _removeSearchTerm(String term) {
    setState(() {
      _recentSearches.remove(term);
    });
    debugPrint('개별 검색어 삭제: $term');
  }

  // 전체 검색어 삭제
  void _clearAllSearches() {
    setState(() {
      _recentSearches.clear();
    });
    debugPrint('최근 검색어 전체 삭제');
  }

  @override
  Widget build(BuildContext context) {
    return SliverMainAxisGroup( // 여러 슬리버를 그룹화
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
                    fontWeight: FontWeight.w700, // 볼드 처리
                    height: 1.50,
                  ),
                ),
                GestureDetector(
                  onTap: _clearAllSearches, // 전체 삭제 기능
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
                      color: const Color(0xFFBBBBBB),
                    ),
                    const SizedBox(width: 8), // 아이콘과 텍스트 사이 간격

                    // 검색어 텍스트
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          // 검색어 클릭 시 동작 (예: 검색 입력 필드에 채우기)
                          debugPrint('검색어 클릭: $searchTerm');
                          // setState를 통해 _recentSearches 리스트를 업데이트할 수 있지만
                          // 현재 이 위젯은 검색어 입력을 받는 UsrProfileAppBar와 직접 연결되어 있지 않음.
                          // 만약 연동이 필요하다면 Callbacks 또는 Provider(Riverpod/Provider 패키지) 사용을 고려해야 함.
                        },
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
                      onTap: () => _removeSearchTerm(searchTerm), // 개별 검색어 삭제 기능
                      child: const Icon(
                        Icons.close,
                        size: 16,
                        color: Color(0xFFBBBBBB),
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