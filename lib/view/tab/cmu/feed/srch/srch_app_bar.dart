import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:my_app/notifier/srch_keyword_notifier.dart';
import 'package:my_app/util/screen_ratio.dart' show ScreenRatio;

class SrchAppBar extends ConsumerStatefulWidget {
  final bool focusSearchArea;
  final VoidCallback searchAreaControll;
  const SrchAppBar({
    super.key,
    required this.focusSearchArea,
    required this.searchAreaControll,
  });

  @override
  ConsumerState<SrchAppBar> createState() => _SrchAppBarState();
}

class _SrchAppBarState  extends ConsumerState<SrchAppBar> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // 초기 검색어 설정: 프로바이더의 현재 값을 컨트롤러에 반영
    _searchController.text = ref.read(srchKeywordProvider);
     // FocusNode 리스너 추가: 포커스 상태 변경을 감지합니다.
    _searchFocusNode.addListener(_onFocusChanged);
  }

  void _onFocusChanged() {
    // isSearchFocusedProvider의 상태를 업데이트합니다.
    // _searchFocusNode.hasFocus는 현재 TextField가 포커스를 가지고 있는지 여부를 반환합니다.
    ref.read(isSearchFocusedProvider.notifier).state = _searchFocusNode.hasFocus;
  }

  @override
  void dispose() {
    // FocusNode 리스너 제거: 메모리 누수 방지를 위해 필수입니다.
    _searchFocusNode.removeListener(_onFocusChanged);
    // 컨트롤러와 포커스 노드 해제
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  // 검색어를 프로바이더에 업데이트하고 키보드를 내리는 공통 함수
  void _performSearch() async{
    // 현재 TextField의 텍스트를 가져와 프로바이더 업데이트
    ref.read(srchKeywordProvider.notifier).updateKeyword(_searchController.text);
    // 키보드 내리기
    _searchFocusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final htio = ScreenRatio(context).heightRatio;
    final wtio = ScreenRatio(context).widthRatio;
    
    final srchKeyword = ref.watch(srchKeywordProvider);
    _searchController.text = srchKeyword;

    return Container(
      width: 375 * wtio,
      padding: EdgeInsets.symmetric(horizontal: 20 * wtio, vertical: 10 * htio),
      color: Colors.white,
      height: 48 * htio,
      child: Stack(
        alignment: Alignment.center,
        children: [

          // 왼쪽 뒤로가기 버튼
          Align(
            alignment: Alignment.centerLeft,
            child: GestureDetector(
              onTap: () {
                if(widget.focusSearchArea){
                  widget.searchAreaControll();
                  _searchFocusNode.unfocus();
                } else {
                  context.pop();
                }
              },
              child: SizedBox(
                width: 24 * wtio,
                height: 24 * htio,
                child: SvgPicture.asset(
                  'assets/icons/feed_detail/ico_back.svg',
                ),
              ),
            ),
          ),

          // 검색어 입력칸
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 40.0 * wtio), // 뒤로가기/검색 버튼 공간 확보
            child: TextField(
              controller: _searchController,
              focusNode: _searchFocusNode,
              textAlignVertical: TextAlignVertical.center, // 텍스트를 세로 중앙 정렬
              decoration: InputDecoration(
                hintText: '검색어를 입력하세요',
                hintStyle: TextStyle(
                  color: const Color(0xFFAAAAAA),
                  fontSize: 14 * htio,
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.w400,
                ),
                filled: true,
                fillColor: const Color(0xFFF5F5F5), // 배경색
                contentPadding: EdgeInsets.symmetric(horizontal: 12 * wtio, vertical: 0), // 내부 패딩 조절
                border: OutlineInputBorder( // 테두리 설정
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none, // 테두리 선 없음
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: const Color(0xFF0D86E7), width: 1 * wtio), // 포커스 시 테두리 색상 변경
                ),
              ),
              style: TextStyle(
                color: Colors.black,
                fontSize: 14 * htio,
                fontFamily: 'Pretendard',
                fontWeight: FontWeight.w400,
              ),
              cursorColor: const Color(0xFF0D86E7), // 커서 색상
              onSubmitted: (_) => _performSearch(), // 엔터 시 _performSearch 호출
            ),
          ),

          // 우측 검색 버튼
          Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: () {
               _performSearch(); // 검색 버튼 탭 시 _performSearch 호출
              },
              child: SizedBox(
                width: 28 * wtio,
                height: 28 * htio,
                child: SvgPicture.asset(
                  'assets/widgets/search_btn.svg',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
