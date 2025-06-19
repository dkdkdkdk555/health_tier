import 'package:flutter/material.dart';
import 'package:my_app/view/tab/cmu/feed/list/cmu_category_top_bar.dart';

class CategoryTopBarDelegate extends SliverPersistentHeaderDelegate {
  final double htio;
  final bool isSpread;
  final VoidCallback onToggleSpread;
  final void Function({required int index})onCategoryChange;
  final int selectedCategoryId;

  CategoryTopBarDelegate({
    required this.htio, /* SliverPersistentHeaderDelegate 에서는 context를 바로 활용할 수 없기
     때문에 외부에서 htio를 미리 계산해서 넘겨주는 방식이 안정적이다. <- 처음 페이지 진입시 CmuAppBar
     안보이는 원인 해결 */
     required this.isSpread,
     required this.onToggleSpread,
     required this.onCategoryChange,
     required this.selectedCategoryId,
  });
  
  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.white,
      height: maxExtent,
      child: AnimatedSize(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        alignment: Alignment.topCenter,
        child: CategoryTopBar(
          isSpread: isSpread,
          onToggleSpread: onToggleSpread,
          htio: htio,
          onCategoryChange: onCategoryChange,
          selectedCategoryId: selectedCategoryId,
        ),
      ),
    );
  }
  
  @override
  double get maxExtent => isSpread ? 108 * htio : 58 * htio; // CmuAppBar 높이에 맞게 조정 (예: 100)
  @override
  double get minExtent => isSpread ? 108 * htio : 58 * htio; // 스크롤되면 완전히 사라짐

  @override
  bool shouldRebuild(covariant CategoryTopBarDelegate oldDelegate) {
    return oldDelegate.htio != htio || oldDelegate.isSpread != isSpread;
  }
}