import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:my_app/model/cmu/feed/badge_info_dto.dart';
import 'package:my_app/model/cmu/feed/reply_response.dart';
import 'package:my_app/providers/feed_providers.dart';
import 'package:my_app/view/tab/cmu/feed/user_profile/cmu_usr_profile.dart';

class Reply extends StatelessWidget {
  final ReplyResponseDto reply;
  final bool isChild;
  const Reply({
    super.key,
    required this.reply,
    required this.isChild,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 375,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: reply.likeCnt >=5 ? const Color(0xFFFFF4E9) : Colors.white,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 12,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 8,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _buildProfileImageStack(reply.imgPath, reply.badges, context),
                  Padding(
                    padding: const EdgeInsets.only(left:8.0, right:4.5),
                    child: Text(
                      reply.nickname,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 14,
                        fontFamily: 'Pretendard',
                        fontWeight: FontWeight.w600,
                        height: 0.11,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: _buildWeightTag(reply.badges),
                  ),
                  Consumer(
                    builder: (context, ref, child) {
                      final feedWriterUserId = ref.watch(feedMainChangeNotifierProvider.select((notifier) => notifier.userId));
                  
                      return reply.userId == feedWriterUserId
                        ? Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                          decoration: ShapeDecoration(
                            color: const Color(0x33333333),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                          ),
                          child: const Text(
                            '작성자',
                            style: TextStyle(
                              color: Color(0xFF333333),
                              fontSize: 10,
                              fontFamily: 'Pretendard',
                              fontWeight: FontWeight.w700,
                              height: 1.50,
                            ),
                          ),
                        )
                        : Container();
                    }
                  ),
                  const Spacer(),
                  Text(
                    reply.displayDttm,
                    style: const TextStyle(
                      color: Color(0xFFAAAAAA),
                      fontSize: 12,
                      fontFamily: 'Pretendard',
                      fontWeight: FontWeight.w400,
                      height: 1.50,
                    ),
                  ),
                ],
              ),
              Text(
                reply.ctnt,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 14,
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.w400,
                  height: 1.50,
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.center,
                spacing: 12,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    spacing: 2,
                    children: [
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: SvgPicture.asset(
                          'assets/icons/like.svg',
                          width: 16,
                          height: 16,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Text(
                        '${reply.likeCnt}',
                        style: const TextStyle(
                          color: Color(0xFF777777),
                          fontSize: 12,
                          fontFamily: 'Pretendard',
                          fontWeight: FontWeight.w500,
                          height: 1.50,
                        ),
                      ),
                    ],
                  ),
                  const Text(
                    '답글 쓰기',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 12,
                      fontFamily: 'Pretendard',
                      fontWeight: FontWeight.w700,
                      height: 1.50,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProfileImageStack(String imgPath, List<BadgeInfoDto>? badges, BuildContext context) {
    final todayBadge = badges!
        .firstWhere(
          (badge) => badge.badgeType == 'today',
          orElse: () => BadgeInfoDto(badgeId: '', badgeName: '', badgeType: ''),
        );

    return GestureDetector(
      onTap: (){
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CmuUsrProfile(userId: reply.userId),
          ),
        );
      },
      child: SizedBox(
        width: 26,
        height: 26,
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
              left: 1.09,
              top: 1.09,
              child: Container(
                width: 24,
                height: 24,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                ),
                child: ClipOval(
                  child: (imgPath.isNotEmpty)
                      ? Image.network(
                          imgPath,
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
      ),
    );
  }

    Widget _buildWeightTag(List<BadgeInfoDto>? badges) {
    final weightBadge = badges!
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