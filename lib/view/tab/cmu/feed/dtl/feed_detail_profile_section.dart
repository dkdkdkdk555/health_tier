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
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // userInfo를 _buildProfileImageStack에 전달
              _buildProfileImageStack(userInfo),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // userInfo를 _buildWeightTag에 전달
                    _buildWeightTag(userInfo),
                    const SizedBox(height: 1),
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
    // today 뱃지 ID 찾기
    final todayBadge = userInfo.badges
        .firstWhere( // firstWhereOrNull 사용
          (badge) => badge.badgeType == 'today',
          orElse: () => BadgeInfoDto(badgeId: '', badgeName: '', badgeType: ''),
        );

    return SizedBox(
      width: 44,
      height: 44,
      child: Stack(
        children: [
          // 바깥 원형 테두리 (today 뱃지가 있을 경우에만 표시)
          if (todayBadge.badgeId != '')
            Positioned.fill(
              child: SvgPicture.asset(
                'assets/widgets/${todayBadge.badgeId}.svg', // todayBadgeId.svg
                fit: BoxFit.cover,
                // SVG를 로드할 수 없을 경우를 대비한 errorBuilder (이 경우 아예 안 보이게 하거나, 기본 테두리 이미지 사용)
                errorBuilder: (context, error, stackTrace) {
                  // 뱃지 로드 실패 시 아무것도 보여주지 않음 (또는 다른 폴백 로직 추가)
                  return const SizedBox.shrink();
                },
              ),
            ),
          // 실제 프로필 이미지 (imgPath 유무에 따라 NetworkImage 또는 기본 SVG)
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
                          // 에러 발생 시 기본 SVG 프로필 이미지
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

  // userInfo를 매개변수로 받도록 수정
  Widget _buildWeightTag(UserInfoResponseDto userInfo) {
    // weight 뱃지 ID 찾기
    final weightBadgeId = userInfo.badges
        .firstWhere(
          (badge) => badge.badgeType == 'weight',
          orElse: () => BadgeInfoDto(badgeId: '', badgeName: '', badgeType: ''),
        )
        .badgeId;

    if (weightBadgeId != '') {
      return const SizedBox();
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 1, vertical: 0.2),
      child: SvgPicture.asset(
        'assets/widgets/$weightBadgeId.svg', // weightBadgeId.svg
        fit: BoxFit.cover,
        // SVG를 로드할 수 없을 경우를 대비한 errorBuilder
        errorBuilder: (context, error, stackTrace) {
          // 기본 weight400.svg를 대체 이미지로 사용
          return const SizedBox();
        },
      ),
    );
  }
}