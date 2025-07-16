import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_app/notifier/srch_keyword_notifier.dart';
import 'package:my_app/view/tab/cmu/feed/srch/recent_srch_terms_sliver.dart';
import 'package:my_app/view/tab/cmu/feed/srch/srch_app_bar_delegate.dart';
import 'package:my_app/view/tab/cmu/feed/srch/srch_result_list_sliver.dart';

class CmuTotalSrch extends ConsumerStatefulWidget {
  const CmuTotalSrch({super.key});

  @override
  ConsumerState<CmuTotalSrch> createState() => _CmuTotalSrchState();
}

class _CmuTotalSrchState extends ConsumerState<CmuTotalSrch> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 검색어가 변경될 때마다 이 build 메서드가 다시 실행됩니다.
    final currentSearchKeyword = ref.watch(srchKeywordProvider);
    final isSearchFocused = ref.watch(isSearchFocusedProvider); // 포커스 상태 감지

    // 검색어가 비어있지 않거나 (이미 검색 결과가 있거나), 검색창에 포커스가 있는 경우
    // -> 검색 결과를 보여줘야 함
    final bool showSearchResults = currentSearchKeyword.isNotEmpty;
    
    // 검색어가 비어있거나 검색창에 포커스가 있는 경우
    // -> 최근 검색어를 보여줘야 함
    final bool showRecentSearches = currentSearchKeyword.isEmpty || isSearchFocused; // ✅ 이 부분이 핵심


    
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // 상단바 위 여백
          SliverAppBar(
            pinned: true,
            primary: false,
            toolbarHeight: 44,
            automaticallyImplyLeading: false,
            flexibleSpace: Container(
              decoration: const BoxDecoration(color: Colors.white),
            )
          ),
          // 상단바
          SliverPersistentHeader(
            pinned: true,
            delegate: SrchAppBarDelegate(),
          ),
          
          // ✅ 조건부 렌더링:
          // showRecentSearches는 '검색어가 비어있거나 OR 검색창에 포커스가 있을 때' true가 됩니다.
          if (showRecentSearches)
            const RecentSearchTermsSliver(),
          // showSearchResults는 '검색어가 비어있지 않을 때' true가 됩니다.
          if (showSearchResults)
            SrchResultListSliver(scrollController: _scrollController,),
        ],
      ),
    );
  }
}