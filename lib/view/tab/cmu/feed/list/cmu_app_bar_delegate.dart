import 'package:flutter/material.dart';
import 'package:my_app/view/tab/cmu/feed/list/cmu_app_bar.dart';

class CmuAppBarDelegate extends SliverPersistentHeaderDelegate {
  final int selectedIndex;
  final ValueChanged<int> onTap;
  final double htio;
  final bool isVisible;

  CmuAppBarDelegate({
    required this.selectedIndex,
    required this.onTap,
    required this.htio,
    required this.isVisible,
  });

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    // isVisible 상태가 true일 때만 AppBar를 표시
    // 애니메이션 효과를 위해 Opacity와 Transform.translate를 사용합니다.
    return Opacity(
      opacity: isVisible ? 1.0 : 0.0,
      child: Transform.translate(
        // isVisible이 false일 때 헤더를 위로 이동시켜 숨깁니다.
        offset: Offset(0, isVisible ? 0 : -maxExtent),
        child: CmuAppBar(
          selectedIndex: selectedIndex,
          onTap: onTap,
        ),
      ),
    );
  }

  @override
  double get maxExtent => 110 * htio;
  
  @override
  double get minExtent => isVisible ? 110 * htio : 0; // isVisible이 false일 때 0으로 접힘

  @override
  bool shouldRebuild(covariant CmuAppBarDelegate oldDelegate) {
    return selectedIndex != oldDelegate.selectedIndex || isVisible != oldDelegate.isVisible;
  }
}