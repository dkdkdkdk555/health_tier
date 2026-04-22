import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:my_app/main.dart' show cmuTabBtn, docTabBtn, stcTabBtn, usrTabBtn;
import 'package:my_app/providers/user_cud_providers.dart' show usrProfileImgProvider;

class IslandNavigationBar extends ConsumerWidget {
  final int selectedIndex;
  final ValueChanged<int> onTap;
  final double wtio;

  const IslandNavigationBar({
    super.key,
    required this.selectedIndex,
    required this.onTap,
    required this.wtio,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final profileImg = ref.watch(usrProfileImgProvider);

    return Container(
        padding: const EdgeInsets.only(left: 8, right: 8),
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
            _buildTabIcon('assets/icons/doc_tab.svg', 0, docTabBtn),
            _buildTabLine([0, 1]),
            _buildTabIcon('assets/icons/static_tab.svg', 1, stcTabBtn),
            _buildTabLine([1, 2]),
            _buildTabIcon('assets/icons/commu_tab.svg', 2, cmuTabBtn),
            _buildTabLine([2, 3]),
            _buildProfileIcon(profileImg, 3, usrTabBtn),
          ],
        ),
    );
  }

  Widget _buildTabIcon(String assetPath, int index, GlobalKey gk) {
    return GestureDetector(
      key: gk,
      onTap: () => onTap(index), // main.dart에 onTap 호출 (build될때 _onTap 함수를 인자로 전달받았음)
      child: SizedBox(
        width: wtio * 0.0747,
        height: wtio * 0.0747,
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

  Widget _buildProfileIcon(String imageUrl, int index, GlobalKey gk) {
    return GestureDetector(
      key: gk,
      onTap: () => onTap(index),
      child: Container(
        width: wtio * 0.0687,
        height: wtio * 0.0687,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
        ),
        child:  ClipOval(
          child: imageUrl == ''
          ? SvgPicture.asset(
              'assets/widgets/default_user_profile.svg',
              fit: BoxFit.cover,
            )
          : Image.network(
              imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return SvgPicture.asset(
                  'assets/widgets/default_user_profile.svg',
                  fit: BoxFit.cover,
                );
              },
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
      width: isActive ? wtio * 0.0027 : 0,
      height: isActive ? wtio * 0.0427 : 0,
      decoration: BoxDecoration(
        color: isActive ? const Color.fromRGBO(0, 0, 0, 0.18) : Colors.transparent,
      ),
    );
  }
}
