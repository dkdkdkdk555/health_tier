import 'package:flutter/material.dart';
import 'package:my_app/view/tab/cmu/cmu_app_bar.dart';

class CmuAppBarDelegate extends SliverPersistentHeaderDelegate {
  final int selectedIndex;
  final ValueChanged<int> onTap;
  final double htio;

  CmuAppBarDelegate({
    required this.selectedIndex,
    required this.onTap,
    required this.htio, /* SliverPersistentHeaderDelegate 에서는 context를 바로 활용할 수 없기
     때문에 외부에서 htio를 미리 계산해서 넘겨주는 방식이 안정적이다. <- 처음 페이지 진입시 CmuAppBar
     안보이는 원인 해결 */
  });
  
  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return CmuAppBar(
      selectedIndex: selectedIndex,
      onTap: onTap,
    );
  }

  @override
  double get maxExtent => 154 * htio; // CmuAppBar 높이에 맞게 조정 (예: 100)
  @override
  double get minExtent => 0; // 스크롤되면 완전히 사라짐

  @override
  bool shouldRebuild(covariant CmuAppBarDelegate oldDelegate) {
    return selectedIndex != oldDelegate.selectedIndex;
  }
}