import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:my_app/extension/time_converter.dart';
import 'package:my_app/model/usr/user/notifications_model.dart';

class NotificationItem extends StatelessWidget {
  final NotificationModel notification;
  const NotificationItem({
    super.key,
    required this.notification,
  });

  @override
  Widget build(BuildContext context) {

    Map<String, String> notificationTypeIcon = {
      'COMMUNITY':'assets/widgets/notifi_community.svg',
      'CRTIFI':'assets/widgets/notifi_crtifi.svg',
      'BADGE':'assets/widgets/notifi_badge.svg',
      'PROMOTION': 'assets/widgets/notifi_promotion.svg',
      'GENERAL':'assets/widgets/notifi_doc.svg',
      'REPORT': 'assets/widgets/notifi_report.svg',
    };

    debugPrint('-----------------------');
    debugPrint('ID: ${notification.id}');
    debugPrint('Title: ${notification.title}');
    debugPrint('Body: ${notification.body}');
    debugPrint('FeedId: ${notification.feedId}');
    debugPrint('Type: ${notification.type}');
    debugPrint('ReceivedAt: ${notification.receivedAt}');
    debugPrint('IsRead: ${notification.isRead}');
    debugPrint('-----------------------');

    return Container(
      color: notification.isRead == 'true' ? Colors.white : const Color(0xFFFFF4E9), // 배경색
      padding: const EdgeInsets.all(20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 아이콘
          SizedBox(
            width: 32,
            height: 32,
            child: SvgPicture.asset(
              notificationTypeIcon[notification.type ?? 'GENERAL'] ?? 'assets/widgets/notifi_doc.svg', // 메인 알림 아이콘
              width: 20,
              height: 20,
            ),
          ),
          const SizedBox(width: 12),
          // 텍스트 영역
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 첫 줄 (제목 + 시간)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // 제목
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: notification.prefix,
                              style: const TextStyle(
                                fontFamily: "Pretendard",
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                                color: Colors.black,
                                height: 1.4,
                              ),
                            ),
                            TextSpan(
                              text: notification.title,
                              style: const TextStyle(
                                fontFamily: "Pretendard",
                                fontWeight: FontWeight.w400,
                                fontSize: 14,
                                color: Colors.black,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Text(
                      TimeConverter.convertDisplayTime(notification.receivedAt),
                      style: const TextStyle(
                        fontFamily: "Pretendard",
                        fontWeight: FontWeight.w400,
                        fontSize: 12,
                        color: Color(0xFFAAAAAA),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  notification.body,
                  style: const TextStyle(
                    fontFamily: "Pretendard",
                    fontWeight: FontWeight.w400,
                    fontSize: 14,
                    color: Color(0xFF777777),
                    height: 1.4,
                  ),
                  // 내용길이 제한
                  // maxLines: ,
                  // overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
