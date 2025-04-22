import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class IslandNavigationBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTap;

  const IslandNavigationBar({
    super.key,
    required this.selectedIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: const EdgeInsets.only(left:75, right: 75, bottom:42),
        padding: const EdgeInsets.only(left: 8, right: 8),
        height: 52,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: Color(0x28000000),
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildTabIcon('assets/icons/doc_tab.svg', 0),
            _buildTabLine([0, 1]),
            _buildTabIcon('assets/icons/static_tab.svg', 1),
            _buildTabLine([1, 2]),
            _buildTabIcon('assets/icons/commu_tab.svg', 2),
            _buildTabLine([2, 3]),
            _buildProfileIcon('assets/icons/Ellipse1.png', 3),
          ],
        ),
    );
  }

  Widget _buildTabIcon(String assetPath, int index) {
    return GestureDetector(
      onTap: () => onTap(index), // main.dart에 onTap 호출 (build될때 _onTap 함수를 인자로 전달받았음)
      child: SizedBox(
        width: 28,
        height: 28,
        child: SvgPicture.asset(
        assetPath,
        colorFilter: ColorFilter.mode(
            selectedIndex == index ? const Color(0xFF333333) : const Color(0xFFAAAAAA),
            BlendMode.srcIn, // ← 핵심 포인트!
          ),
        ),
      ),
    );
  }

  Widget _buildProfileIcon(String imageUrl, int index) {
    return GestureDetector(
      onTap: () => onTap(index),
      child: Container(
        width: 25,
        height: 25,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          image: DecorationImage(
            // image: NetworkImage(imageUrl), -> 회원이미지를 네트워크에서 가져올때 적용하자
            image: Image.asset(imageUrl).image,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
  
  Widget _buildTabLine(List<int> indexes) {
    final isActive = indexes.contains(selectedIndex);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      margin: isActive ? const EdgeInsets.symmetric(horizontal: 3) : EdgeInsets.zero,
      width: isActive ? 1 : 0,
      height: isActive ? 16 : 0,
      decoration: BoxDecoration(
        color: isActive ? const Color.fromRGBO(0, 0, 0, 0.18) : Colors.transparent,
      ),
    );
  }
}
