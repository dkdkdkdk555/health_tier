import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:my_app/providers/api_feed_providers.dart';

class UsrProfile extends ConsumerWidget {
  final int userId;
  const UsrProfile({
    super.key,
    required this.userId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    debugPrint('빌드메서드 내부 : $userId');
    final userInfoAsync = ref.watch(userInfoProvider(userId));

    return userInfoAsync.when(
      data: (userInfo) {
        return Column(
          children: [
            // Container(
            //     height: 1,
            //     decoration: const BoxDecoration(color: Color(0xFFEEEEEE)),
            // ),
            Container(
              padding: const EdgeInsets.only(left: 20, right: 20, top: 25, bottom: 26),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 프로필 이미지
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
                  const SizedBox(width: 16),
                  // 닉네임 + 뱃지 리스트
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          userInfo.nickname,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                            fontFamily: 'Pretendard',
                            fontWeight: FontWeight.w500,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Wrap(
                          spacing: 6,
                          runSpacing: 4,
                          children: userInfo.badges.map((badge) {
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0x33FAA131),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                badge.badgeName,
                                style: const TextStyle(
                                  color: Color(0xFFFAA131),
                                  fontSize: 10,
                                  fontFamily: 'Pretendard',
                                ),
                              ),
                            );
                          }).toList(),
                        ),
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
