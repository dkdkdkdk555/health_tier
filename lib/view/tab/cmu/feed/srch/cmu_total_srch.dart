import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:my_app/notifier/srch_keyword_notifier.dart';
import 'package:my_app/util/screen_ratio.dart' show ScreenRatio;
import 'package:my_app/view/tab/cmu/feed/item/top_blank_area.dart';
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

  // 상단 고정 헤더들의 총 높이를 정의합니다. (SliverAppBar + SrchAppBarDelegate)
  static const double _sliverAppBarHeight = 44.0;
  static const double _srchAppBarDelegateHeight = 48.0; // SrchAppBar의 Container height와 일치해야 합니다.
  static const double _fixedHeaderTotalHeight = _sliverAppBarHeight + _srchAppBarDelegateHeight;

  bool isClickBackBtn = false;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _searchAreaControll(){
    setState(() {
      isClickBackBtn = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentSearchKeyword = ref.watch(srchKeywordProvider);
    final isSearchFocused = ref.watch(isSearchFocusedProvider);
    final htio = ScreenRatio(context).heightRatio;

    // 검색어가 비어있지 않으면 검색 결과를 보여줍니다.
    // final bool showSearchResults = currentSearchKeyword.isNotEmpty;
    
    // 검색어가 비어있거나 검색창에 포커스가 있는 경우 최근 검색어 오버레이를 보여줍니다.
    final bool showRecentSearchesOverlay = (currentSearchKeyword.isEmpty || isSearchFocused) && !isClickBackBtn;
    
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack( // ✅ Stack을 사용하여 여러 위젯을 겹쳐서 배치합니다.
        children: [
          // 1. 기본 레이어: CustomScrollView (검색 결과 목록)
          // 이 위젯이 아래에 깔리고, 그 위에 블러 및 최근 검색어 오버레이가 올라옵니다.
          CustomScrollView(
            controller: _scrollController,
            slivers: [
              // 상단바 위 여백 (SliverAppBar)
              const TopBlankArea(),
              // 상단바 (SrchAppBarDelegate)
              SliverPersistentHeader(
                pinned: true,
                delegate: SrchAppBarDelegate(focusSearchArea: showRecentSearchesOverlay, 
                  clickBackBtn: _searchAreaControll, htio:htio),
              ),
              SrchResultListSliver(scrollController: _scrollController,),
            ],
          ),

          // 3. 최근 검색어 목록 오버레이 레이어 (조건부)
          // 블러 및 어둡게 처리하는 레이어 위에 위치합니다.
          if (showRecentSearchesOverlay)
            Positioned(
              top: _fixedHeaderTotalHeight * htio, // 상단 고정 헤더 아래에 배치
              left: 0,
              right: 0,
              bottom: 0, // 화면 하단까지 확장하거나 특정 높이로 제한할 수 있습니다.
              child: const RecentSearchTermsSliver(), // 이 위젯은 이제 일반 Widget을 반환합니다.
            ),
        ],
      ),
    );
  }
}