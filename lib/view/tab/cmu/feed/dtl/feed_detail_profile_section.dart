import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:my_app/model/cmu/feed/badge_info_dto.dart';
import 'package:my_app/model/cmu/feed/user_info_response_dto.dart';
import 'package:my_app/providers/feed_providers.dart'; // feed_providers.dart 경로 확인

class FeedDetailProfileSection extends ConsumerWidget {
  const FeedDetailProfileSection({
    super.key,
    required this.userId,
  });

  final int userId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncUserInfo = ref.watch(userInfoProvider(userId));

    return asyncUserInfo.when(
      data: (userInfo) {
        final hasWeightBadge = userInfo.badges
            .any((badge) => badge.badgeType == 'weight' && badge.badgeId.isNotEmpty);

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: hasWeightBadge ? CrossAxisAlignment.start : CrossAxisAlignment.center,
            children: [
              _buildProfileImageStack(userInfo),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: hasWeightBadge ? MainAxisAlignment.start : MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildWeightTag(userInfo),
                    if (hasWeightBadge) const SizedBox(height: 1),
                    Text(
                      userInfo.nickname,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 14,
                        fontFamily: 'Pretendard',
                        fontWeight: FontWeight.w600,
                        height: 1.50,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('에러: $err')),
    );
  }


  Widget _buildProfileImageStack(UserInfoResponseDto userInfo) {
    final todayBadge = userInfo.badges
        .firstWhere(
          (badge) => badge.badgeType == 'today',
          orElse: () => BadgeInfoDto(badgeId: '', badgeName: '', badgeType: ''),
        );

    return SizedBox(
      width: 44,
      height: 44,
      child: Stack(
        children: [
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
          Positioned(
            left: 2,
            top: 2,
            child: Container(
              width: 40,
              height: 40,
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