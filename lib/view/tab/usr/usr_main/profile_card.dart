import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:my_app/providers/user_cud_providers.dart';
import 'package:my_app/util/spinner_utils.dart' show AppLoadingIndicator;
import 'package:my_app/view/tab/usr/management/usr_info_management.dart';

class ProfileCard extends ConsumerWidget {
  const ProfileCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userInfoAsync = ref.watch(usrSimpleInfoProvider);
    
    return userInfoAsync.when(
      data: (userInfoResult) {
        final userInfo = userInfoResult.data;

        return SizedBox(
          width: double.infinity,
          child: Padding(
            padding: const EdgeInsets.only(top:20, right: 20, left: 20, bottom: 44),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: 200,
                  height: 217,
                  child: Stack(
                    children: [
                      Container(
                        width: 200,
                        height: 200,
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
                      Positioned(
                        left: 35, // 필요에 따라 조정
                        bottom: 0, // 필요에 따라 조정
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(context,
                            MaterialPageRoute(
                              builder: (context) => UsrInfoManagement(userInfo: userInfo,)
                              )
                            );
                          },
                          child: Container(
                            width: 130,
                            height: 44,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(99),
                              border: Border.all(
                                width: 1,
                                color: const Color(0xFFCCCCCC),
                              ),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x28000000),
                                  blurRadius: 12,
                                  offset: Offset(0, 4),
                                  spreadRadius: 0,
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                SvgPicture.asset(
                                  'assets/icons/reply/update_feed.svg',
                                  fit: BoxFit.cover,
                                ),
                                const SizedBox(width: 4),
                                const Text(
                                  '내 정보 관리',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    fontFamily: 'Pretendard',
                                    height: 0.11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                Text(
                  userInfo.nickname,
                  style: const TextStyle(
                    color: Color(0xFF333333),
                    fontSize: 28,
                    fontFamily: 'Pretendard',
                    fontWeight: FontWeight.w600,
                    height: 0.05,
                  ),
                ),
              ],
            ),
          ),
        );
      },
      loading: () => const Center(child: AppLoadingIndicator()),
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