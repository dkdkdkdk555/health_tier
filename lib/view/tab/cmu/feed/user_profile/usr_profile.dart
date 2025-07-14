import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';

class UsrProfile extends ConsumerWidget {
  final int userId;
  const UsrProfile({
    super.key,
    required this.userId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
          ),
          child: ClipOval(
            child: userId != 1 // (feed.imgPath.isEmpty)
                ? SvgPicture.asset(
                    'assets/widgets/default_user_profile.svg',
                    fit: BoxFit.cover,
                  )
                : Image.network(
                    'feed.imgPath',
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
        Align(
          alignment: Alignment.topLeft,
          child: Row(
            children: [
              const Text(
                'feed.nickname',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 14,
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.w500,
                  height: 1.50,
                ),
              ),
              Container(
                  width: 30,
                  height: 17,
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                  decoration: ShapeDecoration(
                      color: const Color(0x33FAA131),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                  ),
                  child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                          Text(
                              '뱃지',
                              style: TextStyle(
                                  color: Color(0xFFFAA131),
                                  fontSize: 10,
                                  fontFamily: 'Pretendard',
                                  height: 0.15,
                              ),
                          ),
                      ],
                  ),
              ),
            ],
          ),
        )
      ],
    );
  }
}