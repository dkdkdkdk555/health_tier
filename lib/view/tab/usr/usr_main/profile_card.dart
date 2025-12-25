import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:my_app/model/cmu/common/result.dart' show Result;
import 'package:my_app/model/usr/user/usr_simple_dto.dart';
import 'package:my_app/providers/user_cud_providers.dart';
import 'package:my_app/util/dialog_utils.dart' show openFullImageView;
import 'package:my_app/util/screen_ratio.dart' show ScreenRatio;
import 'package:my_app/util/spinner_utils.dart' show AppLoadingIndicator;
import 'package:my_app/util/user_prefs.dart';
import 'package:my_app/view/common/error_widget.dart';

class ProfileCard extends ConsumerWidget {
  const ProfileCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final htio = ScreenRatio(context).heightRatio;
    final wtio = ScreenRatio(context).widthRatio;
    
    final userInfoAsync = ref.watch(usrSimpleInfoProvider);

    // 데이터가 들어오면 한 번만 프로필 이미지 갱신
    ref.listen<AsyncValue<Result<UserSimpleDto>>>(usrSimpleInfoProvider, (previous, next) {
      next.whenData((userInfoResult) {
        final imgPath = userInfoResult.data.imgPath;
        if (imgPath != null && imgPath.isNotEmpty) {
          ref.read(usrProfileImgProvider.notifier).state = imgPath;
          UserPrefs.setUserImgUrl(imgPath);
        }
      });
    });

    
    return userInfoAsync.when(
      data: (userInfoResult) {
        final userInfo = userInfoResult.data;

        return SizedBox(
          width: double.infinity,
          child: Padding(
            padding: EdgeInsets.only(top:20 * htio, right: 20 * wtio, left: 20 * wtio, bottom: 44 * htio),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: 200 * wtio,
                  height: 217 * htio,
                  child: Stack(
                    children: [
                      GestureDetector(
                        onTap: () {
                          if (userInfo.imgPath != null && userInfo.imgPath!.isNotEmpty) {
                            openFullImageView(context, userInfo.imgPath!);
                          }
                        },
                        child: Center(
                          child: Container(
                            height: 200 * htio,
                            width: 200 * htio,
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
                        ),
                      ),
                      Positioned(
                        left: 35 * wtio, // 필요에 따라 조정
                        bottom: 0, // 필요에 따라 조정
                        child: GestureDetector(
                          onTap: () {
                            context.push('/usr/info/management');
                          },
                          child: Container(
                            width: 130 * wtio,
                            height: 44 * htio,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(99),
                              border: Border.all(
                                width: 1 * wtio,
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
                                SizedBox(width: 4 * wtio),
                                Text(
                                  '내 정보 관리',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 13 * htio,
                                    fontWeight: FontWeight.w500,
                                    fontFamily: 'Pretendard',
                                    height: 0.11 * htio,
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
                SizedBox(height: 40 * htio),
                Text(
                  userInfo.nickname,
                  style: TextStyle(
                    color: const Color(0xFF333333),
                    fontSize: (userInfo.nickname.length < 10 ? 28 : 22) * htio,
                    fontFamily: 'Pretendard',
                    fontWeight: FontWeight.w600,
                    height: 0.05 * htio,
                  ),
                ),
              ],
            ),
          ),
        );
      },
      loading: () => const Center(child: AppLoadingIndicator()),
      error: (err, stack) {
        return Column(
          children: [
            const ErrorContentWidget(mainText: '프포필 정보를 불러오는데 실패했습니다.',),
            GestureDetector(
              onTap: () {
                context.push('/usr/info/management');
              },
              child: Container(
                width: 130 * wtio,
                height: 44 * htio,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(99),
                  border: Border.all(
                    width: 1 *  wtio,
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
                    SizedBox(width: 4 * wtio),
                    Text(
                      '내 정보 관리',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 13 * htio,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Pretendard',
                        height: 0.11 * htio,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      }
    );
  }
}