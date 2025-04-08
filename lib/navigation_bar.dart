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
        margin: const EdgeInsets.only(left:72, right: 72, bottom:50),
        height: 64,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
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
            _buildTabIcon('assets/icons/static_tab.svg', 1),
            _buildTabIcon('assets/icons/commu_tab.svg', 2),
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
        width: 28,
        height: 28,
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

  // Widget _buildDivider() {
  //   return Container(
  //     width: 1,
  //     height: 24,
  //     color: Colors.black.withOpacity(0.1),
  //   );
  // }
}
