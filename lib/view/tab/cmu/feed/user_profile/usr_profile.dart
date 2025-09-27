import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:my_app/model/cmu/feed/badge_info_dto.dart';
import 'package:my_app/model/cmu/feed/user_info_response_dto.dart';
import 'package:my_app/providers/feed_providers.dart';
import 'package:my_app/util/spinner_utils.dart' show AppLoadingIndicator;

class UsrProfile extends ConsumerWidget {
  final int userId;
  const UsrProfile({
    super.key,
    required this.userId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userInfoAsync = ref.watch(userInfoProvider(userId));

    return userInfoAsync.when(
      data: (userInfo) {
        return Column(
          children: [
            Container(
              padding: const EdgeInsets.only(left: 20, right: 20, top: 25, bottom: 26),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProfileImageStack(userInfo, context),
                  const SizedBox(width: 16),
                  // 닉네임 + 뱃지 리스트
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 3),
                        Text(
                          userInfo.nickname,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 15,
                            fontFamily: 'Pretendard',
                            fontWeight: FontWeight.w500,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 1),
                        _buildWeightTag(userInfo),
                        const SizedBox(height: 2),
                        Text(
                          userInfo.createDttm != null ? '${userInfo.createDttm} 가입' : '',
                          style: const TextStyle(
                            color: Color(0xFF777777),
                            fontSize: 12.2,
                            fontFamily: 'Pretendard',
                            height: 2,
                          ),
                        ),
                      ],
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
      loading: () => const Center(child: AppLoadingIndicator()),
      error: (err, stack) {
        debugPrint('$err');
        debugPrint('$stack');
        return const SizedBox.shrink();
      }
    );
  }

  Widget _buildProfileImageStack(UserInfoResponseDto userInfo, BuildContext context) {
    final todayBadge = userInfo.badges
        .firstWhere(
          (badge) => badge.badgeType == 'today',
          orElse: () => BadgeInfoDto(badgeId: '', badgeName: '', badgeType: ''),
        );

    return SizedBox(
      width: 86,
      height: 86,
      child: Stack(
        children: [
          Positioned(
            left: 2,
            top: 2,
            child: Container(
              width: 82,
              height: 82,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
              ),
              child: ClipOval(
                child: (userInfo.imgPath != null && userInfo.imgPath!.isNotEmpty)
                    ? Image.network(
                        userInfo.imgPath!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return SvgPicture.asset(
                            'assets/widgets/default_user_profile.svg',
                            fit: BoxFit.cover,
                          );
                        },
                      )
                    : SvgPicture.asset(
                        'assets/widgets/default_user_profile.svg',
                        fit: BoxFit.cover,
                      ),
              ),
            ),
          ),
          if (todayBadge.badgeId.isNotEmpty) // .isNotEmpty 대신 != ''
            Positioned.fill(
              child: SvgPicture.asset(
                'assets/widgets/${todayBadge.badgeId}.svg',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const SizedBox.shrink();
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildWeightTag(UserInfoResponseDto userInfo) {
    final weightBadge = userInfo.badges
        .firstWhere(
          (badge) => badge.badgeType == 'weight',
          orElse: () => BadgeInfoDto(badgeId: '', badgeName: '', badgeType: ''),
        );

    // badgeId가 비어있으면 뱃지를 표시하지 않음
    if (weightBadge.badgeId.isEmpty) { // != '' 대신 .isEmpty 사용
      return const SizedBox.shrink(); // 공간도 차지하지 않도록 SizedBox.shrink() 사용
    }

    debugPrint(weightBadge.badgeId); // 디버그 프린트 유지
    debugPrint('??'); // 디버그 프린트 유지

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 1, vertical: 0.2),
      child: SvgPicture.asset(
        'assets/widgets/${weightBadge.badgeId}.svg',
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return const SizedBox.shrink(); // 에러 시에도 공간 차지하지 않음
        },
      ),
    );
  }
}

