import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:my_app/providers/user_cud_providers.dart';

class UsrInfoProfile extends ConsumerWidget {
  const UsrInfoProfile({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userInfoAsync = ref.watch(usrSimpleInfoProvider);

    return userInfoAsync.when(
      data: (userInfoResult) {
        final userInfo = userInfoResult.data;
        
        return Column(
          children: [
            Container(
                height: 1,
                decoration: const BoxDecoration(color: Color(0xFFEEEEEE)),
            ),
            Container(
              padding: const EdgeInsets.only(left: 20, right: 20, top: 25, bottom: 26),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                        ),
                        child: ClipOval(
                          child: userInfo.imgPath == null
                          ? SvgPicture.asset(
                              'assets/widgets/default_user_profile.svg',
                              fit: BoxFit.cover,
                            )
                          : Image.network(
                              userInfo.imgPath!,
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
                      // 우측 하단 카메라 아이콘
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.grey.shade300,
                              width: 1,
                            ),
                          ),
                          child: Icon(
                            Icons.camera,
                            color: Colors.grey.shade600,
                            size: 20,
                          ),
          //                   SvgPicture.asset(
          //   'assets/icons/profile/ico_camera.svg', // 카메라 아이콘 경로
          //   fit: BoxFit.scaleDown,
          // ),
                        ),
                      ),
                    ],
                  ),
                  // 연동 sns + 닉네임
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            userInfo.snsType != null ? '${userInfo.snsType!.displayName} 계정 연결 중' : '',
                            style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 14,
                              fontFamily: 'Pretendard',
                              fontWeight: FontWeight.w600,
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            spacing: 6,
                            children: [
                              Text(
                                userInfo.nickname,
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 20,
                                  fontFamily: 'Pretendard',
                                  fontWeight: FontWeight.bold,
                                  height: 1.6,
                                ),
                              ),
                              SizedBox(
                                width: 18,
                                height: 18,
                                child: SvgPicture.asset(
                                  'assets/icons/reply/update_feed.svg',
                                  fit: BoxFit.cover,
                                  colorFilter: ColorFilter.mode(
                                    Colors.grey.shade900,        // 적용할 색
                                    BlendMode.srcIn,    // 원래 svg 색을 덮어씀
                                  ),
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
            Container(
                height: 8,
                decoration: const BoxDecoration(color: Color(0xFFEEEEEE)),
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) {
        debugPrint('$err');
        debugPrint('$stack');
        return Text(
          '$err'
        );
      }
    );
  }
}
